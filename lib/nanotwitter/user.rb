require 'json'
require 'byebug'
Dir["./lib/nanotwitter/*.rb"].each {|file| require file}

class User
  def initialize(response)
    @name = response['name']
    @id = response['id']
    @tweets = make_tweets(response['tweets'])
    @timeline = make_tweets(response['timeline'])
  end

  def make_tweets(tweets)
    byebug
    tweets.each {|tweet| Tweet.new(tweet)}
  end

  attr_accessor :name, :tweets, :id, :timeline

end
