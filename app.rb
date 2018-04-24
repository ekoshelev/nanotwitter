require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
require 'faker'
require 'rubygems'
require 'uri'
require 'newrelic_rpm'
require 'graphql'
require 'json'
require 'redis'
require 'bcrypt'
#require 'byebug'
require './controllers/follower_controller.rb'
require './controllers/return_timeline.rb'
require './controllers/twitter_functionality.rb'
require_relative './temp/fry_seeding.rb'
require './routs/test_interface_routs.rb'
require './routs/graphql_routs.rb'
Dir["./types/*.rb"].each {|file| require file}
Dir["./models/*.rb"].each {|file| require file}
#Dir["./controllers/*.rb"].each {|file| require file}

require_relative 'temp/fry_test_001.rb'
require_relative './temp/fry_seeding.rb'
configure do
  enable :sessions
end

helpers do
  def authenticate!
    halt(401, 'Not Authorized') unless session[:user]
    session[:original_request] = request.path_info
  end
end

before do
  @redis = Redis.new(url: ENV["REDIS_URL"], connect_timeout: 0.2,
  read_timeout: 1.0,
  write_timeout: 0.5
)
  @redis.quit
  @tweets= Tweet.all
  @followers=Follower.all
  @users = User.all
  @followercontroller=FollowerController.new(@redis, @users)
	@timeclass=ReturnTimeline.new(@redis, @tweets, @followers,@followercontroller)
	@twitter_functionality = TwitterFunctionality.new
  @testuser = User.find_by(name: "TestUser")
  if @testuser == nil
    @testuser = @twitter_functionality.create_test_user
  end

end

get '/' do
  #@hometweets= @timeclass.return_recent_tweets
  @timeclass.connectRedis
  if (@redis._client.connected?)
  @hometweets=   @timeclass.get_main_timeline
  @timeclass.quitRedis
end
	erb :index
end

get '/test_search' do
  erb :test_search
end

post '/test_search' do
  @users = User.all
  @tweets = Tweet.all

  @user_search = @users.select {|user| user.name.include?(params[:search_term])}
  @tweet_search = @tweets.select {|tweet| tweet.text.include?(params[:search_term])}

  erb :test_search_success
end

get '/search' do
	erb :search
end

get '/post' do
	erb :post
end

post '/retweet' do
	@retweet = params[:retweet]
	@result = Tweet.new(@retweet)
	@result.save
  @timeclass.connectRedis
  if (@redis._client.connected?)
	@tweets = @timeclass.return_timeline_by_user( session[:user])
  @timeclass.quitRedis
end
	@followers = Follower.all
	erb :display
end

post '/followprofile' do
	@follow = params[:follow]
	@result = Follower.new(@follow)
	@result.save
  @user = User.find_by_id( @follow[:user_id])
  @timeclass.connectRedis
  if (@redis._client.connected?)
  @followercontroller.incr_following(session[:user].id,@follow[:user_id])
	@usertweets = @timeclass.return_tweets_by_user( @follow[:user_id])
	@followers = @followercontroller.get_followers( @follow[:user_id])
	@following = @followercontroller.get_following(  @follow[:user_id])
  @timeclass.add_user_timeline(@usertweets,session[:user])
  @timeclass.quitRedis
end
	erb :profile
end

post '/unfollowprofile' do
	@unfollow = params[:unfollow]
	follower =  Follower.find_by(follower: @unfollow[:follower_id], user_id: @unfollow[:user_id])
	follower.delete
  @timeclass.connectRedis
  if (@redis._client.connected?)
  @followercontroller.decr_following(@unfollow[:follower_id],@unfollow[:user_id])
  @user = User.find_by_id( @unfollow[:user_id])
	@usertweets = @timeclass.return_tweets_by_user( @unfollow[:user_id])
	@followers = @followercontroller.get_followers( @unfollow[:user_id])
	@following = @followercontroller.get_following( @unfollow[:user_id])
  @timeclass.remove_user_timeline(@user,session[:user])
  @timeclass.quitRedis
end
	erb :profile
end

get '/display' do
	#@tweets = @timeclass.return_timeline_by_user( session[:user])
  @timeclass.connectRedis
  if (@redis._client.connected?)
  @tweets = @timeclass.get_user_timeline(session[:user])
  @timeclass.quitRedis
end
	erb :display
end

post '/api/token/new' do
  @token=Faker::Crypto.unique.md5
		session[:user].api_token = @token
		session[:user].save
  @user=session[:user]
  @timeclass.connectRedis
  if (@redis._client.connected?)
  @usertweets = @timeclass.return_tweets_by_user( session[:user].id)
  @followers = @followercontroller.get_followers( session[:user].id)
  @following = @followercontroller.get_following( session[:user].id)
  @timeclass.quitRedis
end
	erb :profile
end

get '/profile/:id' do

  @user = User.find_by_id(params[:id])
  @timeclass.connectRedis
  if (@redis._client.connected?)
    @followercontroller
  @usertweets = @timeclass.return_tweets_by_user(params[:id])
	@followers =@followercontroller.get_followers(params[:id])
	@following = @followercontroller.get_following(params[:id])
  @timeclass.quitRedis
end
  @token = ""
  if session[:user] != nil && session[:user].id==(params[:id]).to_i
		@token = session[:user].api_token
  end
	erb :profile
end

post '/login' do
	user = User.find_by(name: "#{params[:username]}")
	password = "#{params[:password]}"

	if !user.nil? && (BCrypt::Password.new(user.password).is_password? password)
		session[:user] = user
		redirect to('/display')
	else
		redirect to('login_fail')
	end
end

get '/login_fail' do
    @timeclass.connectRedis
  if (@redis._client.connected?)
  @hometweets= @timeclass.return_recent_tweets
  @timeclass.quitRedis
end
  erb :login_fail
end

get '/logout' do
	session.clear
	redirect '/'
end

post '/post_tweet' do
	@tweet = params[:tweet]
	@result = Tweet.new(@tweet)
	@result.save
  @twitter_functionality.add_hashtags(@result)
  @twitter_functionality.add_mentions(@result)
  @result.text = @twitter_functionality.display_tweet(@result)
  @timeclass.connectRedis
if (@redis._client.connected?)
  @timeclass.post_tweet_home_timeline(@result)
  @timeclass.post_tweet_redis(@result)
  @timeclass.quitRedis
end

	redirect '/display'
end

get '/hashtags/:id' do
  @hashtag = Hashtag.find_by(id: params[:id])
  @hashtagtweets = @hashtag.tweets.sort_by{ |k| k["time_created"] }.reverse!
  erb :hashtags
end

post '/register' do
	user_check = User.find_by(name: "#{params[:user]['name']}")

	if !user_check.nil? || (params[:user]['password'] != params[:user]['confirm-password'])
		redirect '/'
	end
	params[:user].delete('confirm-password')

	@user = User.new(params[:user])
	@user.password = BCrypt::Password.create(@user.password)
	@user.save
session[:user] = @user
	redirect to('/display')
end

post '/search' do
    redirect '/search'
end

class TestApp < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets
end

#Test Interface HTTP calls



get '/loaderio-b824862f1b513a533572fb2d3c56d0b3/' do
	 'loaderio-b824862f1b513a533572fb2d3c56d0b3'
end



#Root of GraphQL Based API
post '/api/v1/graphql' do

		request_payload = JSON.parse(request.body.read)

	  result = NanoTwitterAPI.execute(request_payload['query'])

	  result.to_json

end
