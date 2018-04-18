require_relative 'fry_seeding.rb'
require_relative '../controllers/twitter_functionality.rb'

get '/fry_test' do
  tester = TwitterFunctionality.new

	tester.reset_user
	tester.reset_tweet
	tester.reset_follower
	tester.reset_mention
	tester.reset_Retweet

	tester.create_test_user

  seed_table("users.csv", "users", "(name, email, password, api_token)")
  seed_table("tweets.csv", "tweets", "(text, time_created, user_id)", params[:tweets].to_i)
  seed_table("follows.csv", "followers", "(user_id, follower_id)")
end
