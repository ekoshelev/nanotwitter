# require 'pry-byebug'
# require 'sinatra'
require 'sinatra/activerecord'
# require 'sinatra/twitter-bootstrap'
Dir["./models/*.rb"].each {|file| require file}

class TwitterFunctionality
  def create_test_user
    test_user = User.new
    test_user.name = "TestUser"
    test_user.email = "testuser@sample.com"
    test_user.password = "password"
    test_user.save
    return test_user
  end


  def reset_user
    if User.exists?
      User.delete_all
    end
  end

  def reset_tweet
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

  def reset_mention
    if Mention.exists?
      Mention.delete_all
    end
  end


  def reset_follower
    if Follower.exists?
      Follower.delete_all
    end
  end

  def reset_All
    reset_user
  	reset_tweet
  	reset_Hashtag
    reset_mention
    reset_follower
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

  def add_hashtags(tweet)
    tags = tweet.text.scan(/#\w+/)
    current_tags = Hashtag.all

    tags.each do |hashtag|
      if current_tags.find_by(name: hashtag) == nil
        tweet.hashtags.create(name: hashtag)
      else
        existing = current_tags.find_by(name: hashtag)
        TweetHashtag.create(tweet_id: tweet.id, hashtag_id: existing.id)
      end
    end

  end

  def add_mentions(tweet)
    mentions = tweet.text.scan(/@\w+/)
    users = User.all

    mentions.each do |mention|
      mention.slice!(0)
      user = User.find_by(name: mention)

      if user != nil
        Mention.create(tweet_id: tweet.id, user_id: user.id)
      end

    end

  end

  def display_tweet(tweet)
    split = tweet["text"].split(' ')

    split.map! do |word|
      first = word.slice(0)
      if first == '@'
        original = word
        word.slice!(0)

        if User.find_by(name: word) != nil
          user = User.find_by(name: word)
          word = "<a href=\"/profile/#{user.id.to_s}\">@#{word}</a>"
        else

          word = "@#{original}"
        end

      elsif first == '#'
        strip = word.scan(/#\w+/)

        tag = Hashtag.find_by(name: strip[0])

        word = "<a href=\"/hashtags/#{tag.id.to_s}\">#{word}</a>"
      else
        word = word
      end
    end

    return "#{split.join(' ')}"

  end

  def timeline_to_hash(timeline)
    timeline_hash = {"tweets" => []}
    if timeline.empty?
      return nil
    end
    timeline.each do |tweet|
      tweet_hash = { "id" => "#{tweet.id}",
        "text" => tweet.text, "time_created" => tweet.time_created,
        "user_id" => "#{tweet.user_id}", "retweet_id" => tweet.retweet_id }
      timeline_hash["tweets"] << tweet_hash
    end
    return timeline_hash
  end

  def follower_to_int(followers)
    follower_set = []

    if followers.empty?
      return nil
    end

    followers.each do |follow|
      follower_set << follow.follower_id
    end
    return follower_set
  end

  def following_to_int(following)
    following_set = []

    if following.empty?
      return nil
    end

    following.each do |followed|
      following_set << followed.user_id
    end

    return following_set
  end


end
