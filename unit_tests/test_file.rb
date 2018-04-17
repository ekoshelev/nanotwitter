require 'minitest/autorun'
require 'pry-byebug'
#require 'sinatra'
require 'sinatra/activerecord'
# require 'sinatra/twitter-bootstrap'
require './controllers/twitter_functionality.rb'
Dir["./models/*.rb"].each {|file| require file}

class TestUser <  Minitest::Test

  def setup
    @controller = TwitterFunctionality.new
    @controller.reset_All
  end

  def test_create_user
  #  assert_equal true, User.new
    user = User.new
    user.name = "TestUser"
    user.email = "testemail@tester.com"
    user.password = "TestPassword"
    user.save

    assert_equal "TestUser", User.first.name
    assert_equal "testemail@tester.com", User.first.email
    assert_equal "TestPassword", User.first.password

    @controller.reset_All
  end

  def test_create_tweet

    user = User.new
    user.name = "TestUser"
    user.email = "testemail@tester.com"
    user.password = "TestPassword"
    user.save

    tweet = Tweet.new
    tweet.text = "This is a test Tweet"
    tweet.user_id = user.id
    tweet.save

    assert_equal "This is a test Tweet", Tweet.first.text
    assert_equal user.id, Tweet.first.user.id

    @controller.reset_All
  end

  def test_hashtag


    user = User.new
    user.name = "TestUser"
    user.email = "testemail@tester.com"
    user.password = "TestPassword"
    user.save

    tweet = Tweet.new
    tweet.text = "This is a test Tweet"
    tweet.user_id = user.id
    tweet.save

    hashtag = Hashtag.new
    hashtag.name = "#Test"
    hashtag.save

    join = TweetHashtag.new
    join.tweet_id = Tweet.first.id
    join.hashtag_id = Hashtag.first.id
    join.save

    #checks the database pathing to find the name of a hastag through a tweet and user
    assert_equal "#Test", Hashtag.first.name
    assert_equal "#Test", Tweet.first.hashtags.first.name
    assert_equal "#Test", User.first.tweets.first.hashtags.first.name

    @controller.reset_All
  end

  def test_mention


    user = User.new
    user.name = "TestUser"
    user.email = "testemail@tester.com"
    user.password = "TestPassword"
    user.save

    user2 = User.new
    user2.name = "MentionedUser"
    user2.save

    tweet = Tweet.new
    tweet.text = "This is a test Tweet"
    tweet.user_id = user.id
    tweet.save

    mention = Mention.new
    mention.tweet_id = tweet.id
    mention.user_id = user2.id
    mention.save

    assert_equal "MentionedUser", Mention.first.user.name
    assert_equal "MentionedUser", Tweet.first.mentions.first.user.name
    assert_equal "MentionedUser", User.first.tweets.first.mentions.first.user.name
    assert_equal "TestUser", User.second.mentions.first.tweet.user.name

    @controller.reset_All

  end

  def test_retweet


    user = User.new
    user.name = "TestUser"
    user.email = "testemail@tester.com"
    user.password = "TestPassword"
    user.save

    user2 = User.new
    user2.name = "RetweetingUser"
    user2.save

    tweet = Tweet.new
    tweet.text = "This is a test Tweet"
    tweet.user_id = user.id
    tweet.save

    tweet2 = Tweet.new
    tweet2.retweet_id = tweet.id
    tweet2.text = tweet2.retweet.text
    tweet2.user_id = user2.id
    tweet2.save

    assert_equal "This is a test Tweet", Tweet.second.text
    assert_equal "TestUser", Tweet.second.retweet.user.name
    assert_equal "RetweetingUser", Tweet.first.retweeted.first.user.name
    assert_equal "This is a test Tweet", User.second.tweets.first.retweet.text

    @controller.reset_All
  end

  def test_follower


    user = User.new
    user.name = "TestUser"
    user.email = "testemail@tester.com"
    user.password = "TestPassword"
    user.save

    user2 = User.new
    user2.name = "FollowingUser"
    user2.save

    follow = Follower.new
    follow.user_id = User.first.id
    follow.follower_id = User.second.id
    follow.save

    assert_equal "FollowingUser", Follower.first.follower.name
    assert_equal "TestUser", Follower.first.user.name
    assert_equal "FollowingUser", User.first.followers.first.follower.name
    assert_equal "TestUser", User.second.following.first.user.name


    @controller.reset_All
  end



end
