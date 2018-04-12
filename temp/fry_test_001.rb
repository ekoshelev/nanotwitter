require_relative 'fry_seeding.rb'
require_relative '../controllers/twitter_functionality.rb'

get '/fry_test' do
  tester = TwitterFunctionality.new

	tester.reset_User
	tester.reset_Tweet
	tester.reset_Follower
	tester.reset_Mention
	tester.reset_Retweet

	tester.create_test_user

  seed_table("users.csv", "users", "(name, email, password, api_token)")
  seed_table("tweets.csv", "tweets", "(text, time_created, user_id)", params[:tweets].to_i)
  seed_table("follows.csv", "followers", "(user_id, follower_id)")
end
