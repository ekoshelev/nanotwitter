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
require './controllers/return_timeline.rb'
require './controllers/twitter_functionality.rb'
require './controllers/return_timeline_redis.rb'
require './controllers/follower_controller_redis.rb'
require_relative './temp/fry_seeding.rb'
require './routs/test_interface_routs.rb'
require './types/schema.rb'
Dir["./models/*.rb"].each {|file| require file}

require_relative 'temp/fry_test_001.rb'
require_relative './temp/fry_seeding.rb'
require_relative 'temp/rabbit_authorization.rb'

configure do
  enable :sessions
  $redis = Redis.new(url: ENV["REDIS_URL"], connect_timeout: 0.2,
  read_timeout: 1.0,
  write_timeout: 0.5
  )
  $testuser = User.find_by(name: "TestUser")
  tw = TwitterFunctionality.new
  if $testuser == nil
    $testuser = tw.create_test_user
  end
  $testuser_id = $testuser.id
end

helpers do
  def authenticate!
    halt(401, 'Not Authorized') unless session[:user]
    session[:original_request] = request.path_info
  end
end

before do
  @tweets= Tweet.all
  @followers=Follower.all
  @followercontroller=FollowerController.new()
  @timeline_class=ReturnTimeline.new(@tweets,@followers)
	@redis_timeline=ReturnTimelineRedis.new(@followercontroller)
	@twitter_functionality = TwitterFunctionality.new
end

get '/' do

  if @redis_timeline.startRedis
    @users = JSON.parse(User.all.to_json)
    @hometweets = @redis_timeline.get_main_timeline
    @redis_timeline.quitRedis
    erb :redisindex
  else
    @users = User.all
    @hometweets= @timeline_class.return_recent_tweets
    erb :index
  end

end

get '/search' do
  @search_term = params[:search_term]

  if @search_term[0..5] == "user: "
    @users = User.all
    @user_results = @users.select {|user| user.name.include?(params[:search_term][6..-1])}
    puts "#{params[:search_term][6..-1]}"
  else
    "tweets"
    @tweets = Tweet.all
    @tweet_results = @tweets.select {|tweet| tweet.text.include?(params[:search_term])}
    puts "TWEET RESULTS"
  end

  erb :search_success
end

post '/search' do
  redirect "/search?search_term=#{params[:search_term]}"
end

get '/post' do
	erb :post
end

post '/retweet' do
	@retweet = params[:retweet]
	@result = Tweet.new(@retweet)
	@result.save
	@tweets = @timeline_class.return_timeline_by_user( session[:user])
	@followers = Follower.all
	erb :display
end

post '/followprofile' do
	@follow = params[:follow]
	@result = Follower.new(@follow)
	@result.save
  @user = User.find_by_id( @follow[:user_id])
	@usertweets = @timeline_class.return_tweets_by_user( @follow[:user_id])
  @followercontroller.startRedis
  if @followercontroller.redisWorking
    @followercontroller.incr_following(session[:user].id,@follow[:user_id])
   @followers = @followercontroller.get_followers( @follow[:user_id])
   @following = @followercontroller.get_following( @follow[:user_id])
   @redis_timeline.add_user_timeline(@usertweets,session[:user])
    @followercontroller.quitRedis
       erb :redisprofile
    else
      @followers = @timeline_class.return_follower_list( @follow[:user_id])
      @following = @timeline_class.return_following_list( @follow[:user_id])
       erb :profile
    end
end

post '/unfollowprofile' do
	@unfollow = params[:unfollow]
	follower =  Follower.find_by(follower: @unfollow[:follower_id], user_id: @unfollow[:user_id])
	follower.delete
  @user = User.find_by_id( @unfollow[:user_id])
	@usertweets = @timeline_class.return_tweets_by_user( @unfollow[:user_id])
  @followercontroller.startRedis
  if @followercontroller.redisWorking
    @followercontroller.decr_following(@unfollow[:follower_id],@unfollow[:user_id])
   @followers = @followercontroller.get_followers( @unfollow[:user_id])
   @following = @followercontroller.get_following( @unfollow[:user_id])
   @redis_timeline.remove_user_timeline(@user,session[:user])
    @followercontroller.quitRedis
       erb :redisprofile
    else
      @followers = @timeline_class.return_follower_list( @unfollow[:user_id])
    	@following = @timeline_class.return_following_list( @unfollow[:user_id])
       erb :profile
    end
end

get '/display' do
  @redis_timeline.startRedis
  if @redis_timeline.startRedis
    @users = JSON.parse(User.all.to_json)
    @tweets = @redis_timeline.get_user_timeline(session[:user])
    @redis_timeline.quitRedis

    erb :redisdisplay
  else
    @users = User.all
    @tweets = @timeline_class.return_timeline_by_user( session[:user])
    erb :display
  end
end


get '/profile/:id' do
  @user = User.find_by_id(params[:id])
  @usertweets = @timeline_class.return_tweets_by_user(params[:id])
  @token = ""
  if session[:user] != nil
    if session[:user].id != nil && session[:user].id==params[:id].to_i
  		@token = session[:user].api_token
    end
  end
  @followercontroller.startRedis
  if @followercontroller.redisWorking
   @followers = @followercontroller.get_followers( params[:id])
   @following = @followercontroller.get_following( params[:id])
    @followercontroller.quitRedis
       erb :redisprofile
    else
      @followers = @timeline_class.return_follower_list(params[:id])
       @following = @timeline_class.return_following_list(params[:id])
       erb :profile
    end

end

post '/api/token/new' do
  @token=Faker::Crypto.unique.md5
	session[:user].api_token = @token
	session[:user].save
  @user = User.find_by_id(session[:user])
  @usertweets = @timeline_class.return_tweets_by_user(session[:user].id)
  @followercontroller.startRedis
    if @followercontroller.redisWorking
       @followers = @followercontroller.get_followers(session[:user].id)
       @following = @followercontroller.get_following(session[:user].id)
      @followercontroller.quitRedis
     erb :redisprofile
   else
          @followers = @timeline_class.return_follower_list(session[:user].id)
           @following = @timeline_class.return_following_list(session[:user].id)
           erb :profile
        end
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
  @hometweets= @timeline_class.return_recent_tweets
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
  if @redis_timeline.startRedis
    @result.text = @twitter_functionality.display_tweet(@result)
    @redis_timeline.post_tweet_redis(@result)
    @redis_timeline.quitRedis
  else
    @tweets = Tweet.all
  end
	redirect '/display'
end

get '/hashtags/:id' do
  @hashtag = Hashtag.find_by(id: params[:id])
  @hashtagtweets = @hashtag.tweets.sort_by{ |k| k["time_created"] }.reverse!
  erb :hashtags
end

post '/register' do
  #rabbitmq_authorization(params[:user])

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

class TestApp < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets
end

#Test Interface HTTP calls



get '/loaderio-b824862f1b513a533572fb2d3c56d0b3/' do
	 'loaderio-b824862f1b513a533572fb2d3c56d0b3'
end

get '/loaderio-f58d25c9cfc33c94fb8c771be91e2848/' do
  'loaderio-f58d25c9cfc33c94fb8c771be91e2848'
end



#Root of GraphQL Based API
post '/api/v1/graphql' do

		request_payload = JSON.parse(request.body.read)

	  result = NanoTwitterAPI.execute(request_payload['query'])

	  result.to_json

end

post '/api/token/new' do
	if session[:user] != nil
		session[:user].api_token = Faker::Crypto.unique.md5
		session[:user].save
	end
	redirect to('/api/token/view')
end

get '/api/token/view' do
	if session[:user] != nil
		@token = session[:user].api_token
	else
		@token = "You must sign in to view your API token"
	end

	erb :api_token
end
