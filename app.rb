require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
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
    redirect '/search'
end

post '/search' do
    redirect '/search'
end

class TestApp < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets
end
