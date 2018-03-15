require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
require_relative 'test_interface.rb'
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

get '/display' do
	@tweets = Tweet.all
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
		session[:user] = user.name
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
	byebug
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

	redirect to('/display')
end

post '/search' do
    redirect '/search'
end

class TestApp < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets
end

#Test Calls
get '/test' do
	@users = User.all
	erb :test_display
end

get '/test/page' do
	erb :post_interface
end


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
