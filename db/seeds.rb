require 'csv'
require 'activerecord-import'
require 'seedredis.rb'
# require_relative '../temp/fry_seeding.rb'

#start_time = Time.now
# seed_table("users.csv", "users", "(name, email, password, api_token)")
# seed_table("tweets.csv", "tweets", "(text, time_created, user_id)")
# seed_table("follows.csv", "followers", "(user_id, follower_id)")

last_user_id = User.last.id

users_columns = [:name, :email, :password, :api_token]
users_data = CSV.read("lib/seeds/users.csv")
User.import(users_columns, users_data, validate: false)

# puts Time.now - start_time # (~1.7)

columns = [:user_id, :text, :time_created]
tweets_data = CSV.read("lib/seeds/tweets.csv")

tweets_data.each do |tweet|
  tweet[0] = Integer(tweet[0]) + last_user_id
end

Tweet.import columns, tweets_data, validate: false

# puts Time.now - start_time #(~163.9)

follows_columns = [:user_id, :follower_id]
follows_data = CSV.read("lib/seeds/follows.csv")

follows_data.each do |follow|
  follow[0] = Integer(follow[0]) + last_user_id
  follow[1] = Integer(follow[1]) + last_user_id
end

Follower.import(follows_columns, follows_data, validate: false)

@seed_redis = SeedRedis.new
@seed_redis.put_tweets_into_redis
@seed_redis.put_followers_into_redis
# puts Time.now - start_time #(~171.3)
