require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
require_relative 'test_interface.rb'
Dir["./models/*.rb"].each {|file| require file}


# Hello! I'm going to clean this up a bit- make the helpers a module, create views for pages, etc.
# This is just a start. Sorry.
helpers do
	def authenticate!
		unless session[:user]
			session[:original_request] = request.path_info
			redirect 'authentication_fail'
		end
	end
end

get '/authentication_test/?' do
	#session[:user] = User.new
	authenticate!
	"Your attempt at authentication has succeeded!"
end

get '/authentication_fail' do
	"Your attempt at authentication has failed!"
end

get '/' do
	erb :index
end

get '/' do
	erb :index
end

get '/search' do
	erb :search
end

get '/profile' do
	erb :profile
end

get '/viewprofile' do
	erb :viewprofile
end

post '/login' do
    redirect '/search'
end

post '/register' do
	if params[:user]['password'] != params[:user]['confirm-password']
		redirect '/'
	end
	params[:user].delete('confirm-password')
	@user = User.new(params[:user])
	@user.save
    #redirect '/search'
		redirect '/test'
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

get '/test/reset' do
	erb :post_interface
end


post '/test/reset/all' do
	tester = TestInterface.new

	tester.reset_All

	test_user = User.new
	test_user.name = "TestUser"
	test_user.email = "testuser@sample.com"
	test_user.password = "password"

	test_user.save
end

post '/test/reset/testuser' do
	tester = TestInterface.new
	test_user = User.where(name: 'TestUser')

	test_user.tweets.each do |tweet|
		tester.delete_tweet(tweet)
	end

	
end
