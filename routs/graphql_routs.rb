require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
require 'faker'
require 'newrelic_rpm'
require 'graphql'
require 'json'
require './controllers/return_timeline.rb'
require './controllers/twitter_functionality.rb'
require_relative '../temp/fry_seeding.rb'
Dir["./types/*.rb"].each {|file| require file}
Dir["./models/*.rb"].each {|file| require file}

post '/api/v1/graphql' do

		request_payload = JSON.parse(request.body.read)

	  result = NanoTwitterAPI.execute(request_payload['query'])

	  result.to_json

end
