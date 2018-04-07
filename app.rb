require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
require 'faker'
require 'redis-sinatra'
require 'newrelic_rpm'
require 'graphql'
require 'json'
require './controllers/return_timeline.rb'
require_relative 'twitter_functionality'
require_relative './temp/fry_seeding.rb'
Dir["./types/*.rb"].each {|file| require file}
Dir["./models/*.rb"].each {|file| require file}

require_relative 'temp/fry_test_001.rb'

get '/' do
	timeclass=ReturnTimeline.new
	@hometweets= timeclass.return_recent_tweets
	erb :index
end

get '/search' do
	erb :search
end

get '/post' do
	erb :post
end

post '/retweet' do
	@retweet = params[:retweet]
	@result = Retweet.new(@retweet)
	@result.save
	@tweets = Tweet.all
	@retweets = Retweet.all
	@followers = Follower.all
	erb :display
end


post '/followprofile' do
	@follow = params[:follow]
	@result = Follower.new(@follow)
	@result.save
  @user = User.find_by_id( @follow[:user_id])
	@tweets = Tweet.all
	@retweets = Retweet.all
	@followers = Follower.all
	erb :profile
end

post '/unfollowprofile' do
	@unfollow = params[:unfollow]
	follower =  Follower.find_by(follower: @unfollow[:follower_id], user_id: @unfollow[:user_id])
	follower.delete
  @user = User.find_by_id( @unfollow[:user_id])
	@tweets = Tweet.all
	@retweets = Retweet.all
	@followers = Follower.all
	erb :profile
end


post '/follow' do
	@follow = params[:follow]
	@result = Follower.new(@follow)
	@result.save
	@tweets = Tweet.all
	@retweets = Retweet.all
	@followers = Follower.all
	erb :display
end

post '/unfollow' do
	@unfollow = params[:unfollow]

	follower =  Follower.find_by(follower: @unfollow[:follower_id], user_id: @unfollow[:user_id])
	follower.delete
	@tweets = Tweet.all
	@retweets = Retweet.all
	@followers = Follower.all
	erb :display
end


get '/display' do

	@tweets = Tweet.all
	@retweets = Retweet.all
	@followers = Follower.all
	erb :display
end


get '/profile/:id' do
  @user = User.find_by_id(params[:id])
  @tweets = Tweet.all
  @retweets = Retweet.all
	@followers = Follower.all
	erb :profile
end


post '/login' do
	user = User.find_by(name: "#{params[:username]}")
	password = "#{params[:password]}"

	if !user.nil? && (BCrypt::Password.new(user.password).is_password? password)
		session[:user] = user
		redirect to('/display')
	else
		"Login Failed!"
	end
    #redirect '/search'
end

get '/logout' do
	session.clear
	redirect '/'
end

post '/post_tweet' do
	@tweet = params[:tweet]
	@result = Tweet.new(@tweet)
	@result.save
	@tweets = Tweet.all
	redirect '/display'
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
post '/test/reset/all' do

	reset_All
	create_test_user

	return 200
end

post '/test/reset/testuser' do

	if User.exists?(name: 'TestUser')

	test_user = User.where(name: 'TestUser').first

	if test_user.tweets.exists?
		test_user.tweets.each do |tweet|
			delete_tweet(tweet)
		end
	end

	if test_user.retweets.exists?
			test_user.retweets.each do |retweet|
				delete_retweet(retweet)
			end
	end

	if test_user.followers.exists?
		test_user.followers.each do |follow|
			delete_follow(follow)
		end
	end

	if test_user.following.exists?
		test_user.following.each do |following|
			delete_following(following)
		end
	end

	test_user.delete
	end

	create_test_user

end

get '/test/status' do
	test_user = User.find_by_name('TestUser')
	if test_user == nil
		@test_id = "no test user"
	else
		@test_id = test_user.id
	end

	erb :report
end

get '/test/version' do
	#donn't know what is meant by presented as JSON
	0.5.to_json
end


post '/test/reset/standard' do

	reset_User
	reset_Tweet
	reset_Follower
	reset_Mention
	reset_Retweet

	create_test_user

  seed_table("users.csv", "users", "(name, email, password, api_token)", params[:users])
  seed_table("tweets.csv", "tweets", "(text, time_created, user_id)", params[:tweets])
  seed_table("follows.csv", "followers", "(user_id, follower_id)", params[:follows])

	return 200
end

post '/test/users/create' do

	user_number = params[:count].to_i
	tweet_number = params[:tweets].to_i

	if user_number == nil
		user_number = 1
	end

	if tweet_number == nil
		tweet_number = 0
	end

	user_number.times do
		u = User.new
		u.name = Faker::Internet.unique.user_name
		u.email = Faker::Internet.unique.email(u.name)
		u.password = Faker::Internet.password
		u.save

		tweet_number.times do
			t = Tweet.new
			t.text = Faker::Twitter.status['text']
			t.user_id = u.id
			t.save
		end

	end

	return 200

end

post '/test/user/:u/tweets' do
	if params[:u] == 'testuser'
		user = User.find_by_name('TestUser')
	elsif User.find_by_id(params[:u].to_i)
		user = User.find_by_id(params[:u].to_i)
	else
		return 404
	end

	number_tweets = params[:count].to_i

	if number_tweets==nil
		return 500
	end

	number_tweets.times do
		t = Tweet.new
		t.text = Faker::Twitter.status['text']
		t.user_id = user.id
		t.save
	end

return 200

end

post '/test/user/:id/follow' do

	followee = User.find_by_id(params[:id])

	if followee == nil
		return 404 #{"no user under id"}
	end

	num = params[:count].to_i

	random_followers = User.all.sample(num)

	num.times do |count|
		add_follow(followee,random_followers[count])
	end

	return 200

end

post '/test/user/follow' do

	num = params[:count].to_i

	random_users = User.all.sample(num*2)

	random_followees = random_users[0...num]
	random_followers = random_users[num..random_users.size-1]

	num.times do |count|
		add_follow(random_followees[count],random_followers[count])
	end

	return 200

end


get '/loaderio-b824862f1b513a533572fb2d3c56d0b3/' do
	 'loaderio-b824862f1b513a533572fb2d3c56d0b3'
end



#Root of GraphQL Based API
post '/api/v1/:apitoken/graphql' do

	token = params[:apitoken]

	if User.where(api_token: token).exists?

		request_payload = JSON.parse(request.body.read)

	  result = NanoTwitterAPI.execute(request_payload['query'])

	  result.to_json
	else
		"invalid API token".to_json
	end

end
