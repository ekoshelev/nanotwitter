require_relative '../temp/fry_seeding.rb'

seed_table("users.csv", "users", "(name, email, password, api_token)")
seed_table("tweets.csv", "tweets", "(text, time_created, user_id)")
seed_table("follows.csv", "followers", "(user_id, follower_id)")
