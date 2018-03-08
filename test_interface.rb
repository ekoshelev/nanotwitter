require 'pry-byebug'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/twitter-bootstrap'
Dir["./models/*.rb"].each {|file| require file}

class TestInterface


  def reset_User
    if User.exists?
      User.delete_all
    end
  end

  def reset_Tweet
    if Tweet.exists?
      Tweet.delete_all
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

  def delete_tweet(tweet)
    tweet.mentions.delete_all
    tweet.tweetHashtags.delete_all
    tweet.delete
  end

  def delete_follow(follow)
    #delete all following id's, then all follower.where(follower_id: user.id).delete_all
  end


end
