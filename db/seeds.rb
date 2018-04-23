require 'csv'
require 'activerecord-import'
# require_relative '../temp/fry_seeding.rb'

#start_time = Time.now
# seed_table("users.csv", "users", "(name, email, password, api_token)")
# seed_table("tweets.csv", "tweets", "(text, time_created, user_id)")
# seed_table("follows.csv", "followers", "(user_id, follower_id)")

users_columns = [:name, :email, :password, :api_token]
users_data = CSV.read("lib/seeds/users.csv")
User.import(users_columns, users_data, validate: false)

# puts Time.now - start_time # (~1.7)

columns = [:user_id, :text, :time_created]
tweets_csv = CSV.read("lib/seeds/tweets.csv")
Tweet.import columns, tweets_csv, validate: false

# puts Time.now - start_time #(~163.9)

follows_columns = [:user_id, :follower_id]
follows_data = CSV.read("lib/seeds/follows.csv")
Follower.import(follows_columns, follows_data, validate: false)

# puts Time.now - start_time #(~171.3)
