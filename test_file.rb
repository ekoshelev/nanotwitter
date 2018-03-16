require 'minitest/autorun'
# require 'pry-byebug'
# require 'sinatra'
# require 'sinatra/activerecord'
# require 'sinatra/twitter-bootstrap'
require './test_interface.rb'
Dir["./models/*.rb"].each {|file| require file}

class TestUser <  Minitest::Test

  def setup
    @tester = TestInterface.new
    @tester.reset_All
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

    @tester.reset_All
  end

  def test_create_tweet
    @tester.reset_All

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

    @tester.reset_All
  end

  def test_hashtag
    @tester.reset_All

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

    @tester.reset_All
  end

  def test_mention
    @tester.reset_All

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

    @tester.reset_All

  end

  def test_retweet
    @tester.reset_All

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

    retweet = Retweet.new
    retweet.user_id = User.second.id
    retweet.tweet_id = Tweet.first.id
    retweet.save

    assert_equal "This is a test Tweet", Retweet.first.tweet.text
    assert_equal "RetweetingUser", Retweet.first.user.name
    assert_equal "RetweetingUser", Tweet.first.retweets.first.user.name
    assert_equal "This is a test Tweet", User.second.retweets.first.tweet.text

    @tester.reset_All
  end

  def test_follower
    @tester.reset_All

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


    @tester.reset_All
  end



end
