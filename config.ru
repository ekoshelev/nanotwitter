require_relative 'env' if File.exists?('env.rb')
require './app'
run Sinatra::Application
