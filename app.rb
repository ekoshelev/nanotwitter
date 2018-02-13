require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require './models/model'
require 'sinatra/twitter-bootstrap'

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
