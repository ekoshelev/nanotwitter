require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
require 'faker'
require 'newrelic_rpm'
require 'graphql'
require 'json'
require './controllers/return_timeline.rb'
require './controllers/follower_controller_redis.rb'
require './controllers/return_timeline_redis.rb'
require './controllers/twitter_functionality.rb'
require './db/seedredis.rb'
require 'csv'
require 'activerecord-import'
require_relative '../temp/fry_seeding.rb'
Dir["./models/*.rb"].each {|file| require file}


get '/user/testuser' do
  session[:user] = $testuser
  redirect '/display'
end

post '/user/testuser/tweet' do
	tweet = {
	"text" => Faker::Hacker.say_something_smart,
	"time_created" => Time.new.inspect,
	"user_id" => $testuser_id}

	@result = Tweet.new(tweet)
	@result.save
  @twitter_functionality.add_hashtags(@result)
  @twitter_functionality.add_mentions(@result)

  if $redis_timeline.startRedis#$redis_timeline.redisWorking
    @result.text = @twitter_functionality.display_tweet(@result)
    #$redis_timeline.post_tweet_home_timeline(@result)
    $redis_timeline.post_tweet_redis(@result)
    $redis_timeline.quitRedis
  end

	redirect '/user/testuser'

end

post '/test/reset/all' do

  $redis.flushall
	@twitter_functionality.reset_All
	$testuser = @twitter_functionality.create_test_user

	return 200
end

post '/test/reset/testuser' do


	if $testuser.tweets.exists?
	$testuser.tweets.each do |tweet|
			@twitter_functionality.delete_tweet(tweet)
		end
	end

	if $testuser.followers.exists?
		$testuser.followers.each do |follow|
			@twitter_functionality.delete_follow(follow)
		end
	end

	if $testuser.following.exists?
		$testuser.following.each do |following|
			@twitter_functionality.delete_following(following)
		end
	end

	$testuser.delete

	$testuser = @twitter_functionality.create_test_user

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
	1.0.to_json
end


post '/test/reset/standard' do
  $redis._client.connect
  $redis.flushall
	@twitter_functionality.reset_user
	@twitter_functionality.reset_tweet
	@twitter_functionality.reset_follower
	@twitter_functionality.reset_mention

	$testuser = @twitter_functionality.create_test_user

  last_user_id = User.last.id


  users_columns = [:name, :email, :password, :api_token]
  users_data = CSV.read("lib/seeds/users.csv")
  users_data = users_data[0, params[:users].to_i]
  User.import(users_columns, users_data, validate: false)

  columns = [:user_id, :text, :time_created]
  tweets_data = CSV.read("lib/seeds/tweets.csv")
  tweets_data = tweets_data[0, params[:tweets].to_i]
  tweets_data.each do |tweet|
    tweet[0] = Integer(tweet[0]) + last_user_id
  end
  Tweet.import columns, tweets_data, validate: false

  follows_columns = [:user_id, :follower_id]
  follows_data = CSV.read("lib/seeds/follows.csv")
  follows_data = follows_data[0, params[:follows].to_i]
  follows_data.each do |follow|
    follow[0] = Integer(follow[0]) + last_user_id
    follow[1] = Integer(follow[1]) + last_user_id
  end
  Follower.import(follows_columns, follows_data, validate: false)

  # seed_table("users.csv", "users", "(name, email, password, api_token)", params[:users])
  # seed_table("tweets.csv", "tweets", "(text, time_created, user_id)", params[:tweets])
  # seed_table("follows.csv", "followers", "(user_id, follower_id)", params[:follows])
  @seed_redis = SeedRedis.new
  # @seed_redis.put_tweets_into_redis
  @seed_redis.put_followers_into_redis
  @seed_redis.put_timelines_into_redis
  $redis.quit
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

    $redis_timeline.startRedis
		tweet_number.times do
			t = Tweet.new
			t.text = Faker::Hacker.say_something_smart
      t.time_created = Time.now
			t.user_id = u.id
			t.save
      $redis_timeline.post_tweet_redis(t)
		end
    $redis_timeline.quitRedis

	end

	return 200

end

post '/test/user/:u/tweets' do
	if params[:u] == 'testuser'
		user = $testuser
	elsif User.find_by_id(params[:u].to_i)
		user = User.find_by_id(params[:u].to_i)
	else
		return 500
	end

	number_tweets = params[:count].to_i

	if number_tweets==nil
		return 500
	end

	number_tweets.times do
		t = Tweet.new
		t.text = Faker::Hacker.say_something_smart
		t.user_id = user.id
    t.time_created = Time.now
		t.save
    $redis_timeline.startRedis
    $redis_timeline.post_tweet_redis(t)
    $redis_timeline.quitRedis
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
