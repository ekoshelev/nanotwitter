require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
Dir["./models/*.rb"].each {|file| require file}

class TestInterface


  def create_test_user
    test_user = User.new
    test_user.name = "TestUser"
    test_user.email = "testuser@sample.com"
    test_user.password = "password"
    test_user.save
    @test_id = test_user.id
    return test_user
  end

  attr_accessor :test_id


  def reset_User
    if User.exists?
      User.delete_all
    end
  end

  def reset_Tweet
    if Tweet.exists?
      Tweet.delete_all
      TweetHashtag.delete_all
    end
  end

  def reset_Hashtag
    if Hashtag.exists?
      Hashtag.delete_all
      TweetHashtag.delete_all
    end
  end

  def reset_Mention
    if Mention.exists?
      Mention.delete_all
    end
  end

  def reset_Retweet
    if Retweet.exists?
      Retweet.delete_all
    end
  end

  def reset_Follower
    if Follower.exists?
      Follower.delete_all
    end
  end

  def reset_All
    reset_User
  	reset_Tweet
  	reset_Hashtag
    reset_Mention
    reset_Retweet
    reset_Follower
  end

  def delete_user(user)
    user.followers.delete_all
    user.following.delete_all
    user.delete
  end

  def delete_tweet(tweet)
    tweet.mentions.delete_all
    tweet.tweetHashtags.delete_all
    tweet.delete
  end

  def delete_retweet(retweet)
    retweet.delete
  end

  def delete_follow(follow)
    follow.delete
  end

  def delete_following(following)
    following.delete
  end

  def add_follow(followee,follower)
    follow = Follower.new
    follow.user_id = followee.id
    follow.follower_id = follower.id
    follow.save
  end

end
