require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
require_relative 'test_interface.rb'
require 'faker'
Dir["./models/*.rb"].each {|file| require file}

require_relative 'temp/fry_test_001.rb'

get '/' do
	erb :index
end

get '/' do
	erb :index
end

get '/search' do
	erb :search
end

get '/post' do
	erb :post
end

post '/retweet' do
	@tweets = Tweet.all
	@retweets = Retweet.all
	erb :display
end

get '/display' do

	@tweets = Tweet.all
	@retweets = Retweet.all
	erb :display
end


get '/profile' do
	erb :profile
end

get '/viewprofile' do
	erb :viewprofile
end

post '/login' do
	user = User.find_by(name: "#{params[:username]}")
	password = "#{params[:password]}"

	if BCrypt::Password.new(user.password).is_password? password
		session[:user] = user
		redirect to('/display')
	else
		"Login Failed!"
	end
    #redirect '/search'
end

post '/post_tweet' do
	@tweet = params[:tweet]
	@result = Tweet.new(@tweet)
	@result.save
	@tweets = Tweet.all
	redirect '/display'
end

post '/register' do
	if params[:user]['password'] != params[:user]['confirm-password']
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

#Test Calls
# get '/test' do
# 	@users = User.all
# 	erb :test_display
# end


#Test Interface HTTP calls
post '/test/reset/all' do
	tester = TestInterface.new

	tester.reset_All
	tester.create_test_user

end

post '/test/reset/testuser' do
	tester = TestInterface.new

	if User.exists?(name: 'TestUser')

	test_user = User.where(name: 'TestUser').first

	if test_user.tweets.exists?
		test_user.tweets.each do |tweet|
			tester.delete_tweet(tweet)
		end
	end

	if test_user.retweets.exists?
			test_user.retweets.each do |retweet|
				tester.delete_retweet(retweet)
			end
	end

	if test_user.followers.exists?
		test_user.followers.each do |follow|
			tester.delete_follow(follow)
		end
	end

	if test_user.following.exists?
		test_user.following.each do |following|
			tester.delete_following(following)
		end
	end

	test_user.delete
	end

	tester.create_test_user

end

get '/test/status' do
	erb :report
end

get '/test/version' do
	#donn't know what is meany by presented as JSON
	erb :version
end

post '/test/reset/standard' do
	tester = TestInterface.new

	tester.reset_User
	tester.reset_Tweet
	tester.reset_Follower
	tester.reset_Mention
	tester.reset_Retweet

	tester.create_test_user

	# if params[:tweets].exists?
  #
	# else
	load "./db/seeds.rb"

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
	tester = TestInterface.new
	followee = User.find_by_id(params[:id])

	if followee == nil
		return 404 #{"no user under id"}
	end

	num = params[:count].to_i

	random_followers = User.all.sample(num)

	num.times do |count|
		tester.add_follow(followee,random_followers[count])
	end

	return 200

end

post '/test/user/follow' do
	tester = TestInterface.new
	num = params[:count].to_i

	random_users = User.all.sample(num*2)

	random_followees = random_users[0...num]
	random_followers = random_users[num..random_users.size-1]

	num.times do |count|
		tester.add_follow(random_followees[count],random_followers[count])
	end

	return 200

end
