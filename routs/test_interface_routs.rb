require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
require 'faker'
require 'newrelic_rpm'
require 'graphql'
require 'json'
require './controllers/return_timeline.rb'
require './controllers/twitter_functionality.rb'
require_relative '../temp/fry_seeding.rb'
Dir["./types/*.rb"].each {|file| require file}
Dir["./models/*.rb"].each {|file| require file}

post '/test/reset/all' do

	@twitter_functionality.reset_All
	@twitter_functionality.create_test_user

	return 200
end

post '/test/reset/testuser' do


	if User.exists?(name: 'TestUser')

    test_user = User.where(name: 'TestUser').first

	if test_user.tweets.exists?
	@twitter_functionality.test_user.tweets.each do |tweet|
			@twitter_functionality.delete_tweet(tweet)
		end
	end

	if test_user.followers.exists?
		test_user.followers.each do |follow|
			@twitter_functionality.delete_follow(follow)
		end
	end

	if test_user.following.exists?
		test_user.following.each do |following|
			@twitter_functionality.delete_following(following)
		end
	end

	test_user.delete
	end

	@twitter_functionality.create_test_user

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
	0.7.to_json
end


post '/test/reset/standard' do

	@twitter_functionality.reset_User
	@twitter_functionality.reset_Tweet
	@twitter_functionality.reset_Follower
	@twitter_functionality.reset_Mention

	@twitter_functionality.create_test_user

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


  if params[:id] == 'testuser'
		user = User.find_by_name('TestUser')
	elsif User.find_by_id(params[:id].to_i)
		user = User.find_by_id(params[:id].to_i)
	else
		return 404
	end

	num = params[:count].to_i

	random_followers = User.all.sample(num)

	num.times do |count|
		@twitter_functionality.add_follow(user,random_followers[count])
	end

	return 200

end


post '/test/user/follow' do

	num = params[:count].to_i

	random_users = User.all.sample(num*2)

	random_followees = random_users[0...num]
	random_followers = random_users[num..random_users.size-1]

	num.times do |count|
		@twitter_functionality.add_follow(random_followees[count],random_followers[count])
	end

	return 200

end
