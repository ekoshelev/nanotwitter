require 'bcrypt'
require 'byebug'
require_relative 'fry_seeding.rb'
require_relative '../controllers/twitter_functionality.rb'

configure do
  enable :sessions
end

helpers do
  def authenticate!
    halt(401, 'Not Authorized') unless session[:user]
    session[:original_request] = request.path_info
  end
end

get '/fry_login' do
  if session[:user]
    "Welcome #{session[:user]}"
  else
    erb :fry_login
  end
end

get '/fry_poptest' do
  erb :fry_poptest
end

post '/fry_login' do
  user = User.find_by(name: "#{params[:username]}")
  password = "#{params[:password]}"

  if BCrypt::Password.new(user.password).is_password? password
    session[:user] = user.name
    redirect to('/fry_protected_test')
  else
    "Login Failed!"
  end
end

get '/fry_protected_test' do
  authenticate!
  erb :fry_protected_test
end

get '/fry_logout' do
  session.clear
  redirect to('/fry_login')
end

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
