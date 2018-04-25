require_relative 'follower_controller_redis'
require 'byebug'

class ReturnTimelineRedis
  def initialize(redis, tweets, followers, fc)
    $redis = redis
    @tweets = tweets
    @followers = followers
    @followercontroller = fc
  end

  def quitRedis
    $redis.quit
  end

  def startRedis
    $redis._client.connect
  end

  def redisWorking
    return $redis._client.connected?
  end

  def add_user_redis(user)
    if ($redis.get 'users') != nil
      rb_hash = JSON.parse($redis.get('users'))
      rb_hash['allusers'] << { id: user.id, email: user.email, api_token: user.api_token }
      $redis.set 'users', rb_hash.to_json
    else
      $redis.del 'home_timeline'
      rb_hash = { tweets: [{ id: tweet.id, text: tweet.text, time_created: tweet.time_created, user_id: tweet.user_id, retweet_id: tweet.retweet_id }] }
      $redis.set 'home_timeline', rb_hash.to_json
    end
  end

  def get_main_timeline
    if ($redis.get 'home_timeline') != nil
      rb_hash = JSON.parse($redis.get('home_timeline'))
      sortusertweets = rb_hash['tweets'].sort_by { |k| k['time_created'] }.reverse!
      sortusertweets
    end
  end

  def get_user_timeline(user)
    hash_name = get_hash_name(user.id)
    unless $redis.get(hash_name).nil?
      timeline = JSON.parse($redis.get(hash_name))
      sorted = timeline['tweets'].sort_by { |k| k['time_created'] }.reverse!
      return sorted
    end
    nil
  end

  def get_user_tweets(user)
    hash_name = "posted_tweets_#{user.id}"
    unless $redis.get(hash_name).nil?
      posted = JSON.parse($redis.get(hash_name))
      return posted
    end
    nil
  end

  def post_tweet_home_timeline(tweet)
    if ($redis.get 'home_timeline') != nil
      rb_hash = JSON.parse($redis.get('home_timeline'))
      rb_hash['tweets'] << { id: tweet.id, text: tweet.text, time_created: tweet.time_created, user_id: tweet.user_id, retweet_id: tweet.retweet_id }
      if rb_hash['tweets'].size >= 51
        rb_hash['tweets'] = rb_hash['tweets'].drop(1)
      end
      $redis.set 'home_timeline', rb_hash.to_json
    else
      $redis.del 'home_timeline'
      rb_hash = { tweets: [{ id: tweet.id, text: tweet.text, time_created: tweet.time_created, user_id: tweet.user_id, retweet_id: tweet.retweet_id }] }
      $redis.set 'home_timeline', rb_hash.to_json
    end
  end

  def post_tweet_redis(tweet)
    post_tweet_home_timeline(tweet)
    add_user_timeline([tweet], tweet.user)
    posted_tweets(tweet)
    fanout(tweet)
  end

  def posted_tweets(tweet)
    hash_name = "posted_tweets_#{tweet.user.id}"
    if !$redis.get(hash_name).nil?
      posted = JSON.parse($redis.get(hash_name))
      return posted['tweets']
    else
      $redis.del hash_name
      posted = { tweets: [{ id: tweet.id, text: tweet.text, time_created: tweet.time_created,
                  user_id: tweet.user_id, retweet_id: tweet.retweet_id }] }
    end
    $redis.set hash_name, posted.to_json
  end

  def fanout(tweet)
    user_timelines = @followercontroller.get_followers(tweet.user.id)
    tweet.mentions.each do |mentioned|
      add = mentioned.user.id.to_s
      user_timelines << add unless user_timelines.include?(add)
    end

    tweet_json = { id: tweet.id, text: tweet.text, time_created: tweet.time_created,
                    user_id: tweet.user_id, retweet_id: tweet.retweet_id }

    unless user_timelines.empty?
      user_timelines.each do |user|
        hash_name = "user_timeline_#{user}"

        if !$redis.get(hash_name).nil?
          user_timeline = JSON.parse($redis.get(hash_name))
          #user_timeline['tweets'] = user_timeline['tweets'].sort_by { |k| k['time_created'] }.reverse!
          user_timeline['tweets'] << tweet_json
          if user_timeline['tweets'].size >= 51
            user_timeline['tweets'] = user_timeline['tweets'].drop(1)
          end
          $redis.set hash_name, user_timeline.to_json
        else
          $redis.del hash_name
          $redis.set hash_name, { 'tweets' => [tweet_json] }.to_json
        end
      end
    end
  end

  def get_hash_name(id)
    "user_timeline_#{id}"
  end

  def add_user_timeline(tweets, user)
    timeline = { 'tweets' => [] }
    hash_name = get_hash_name(user.id)
    if !$redis.get(hash_name).nil?
      timeline = JSON.parse($redis.get(hash_name))
    else
      $redis.del hash_name
    end

    #timeline['tweets'] = timeline['tweets'].sort_by { |k| k['time_created'] }.reverse!

    tweets.each do |tweet|
      tweet_json = { id: tweet.id, text: tweet.text, time_created: tweet.time_created,
                      user_id: tweet.user_id, retweet_id: tweet.retweet_id}
      timeline['tweets'] << tweet_json
      if timeline['tweets'].size >= 51
        timeline['tweets'] = timeline['tweets'].drop(1)
      end
    end
    $redis.set get_hash_name(user.id), timeline.to_json
  end

  def remove_user_timeline(unfollowed, user)
    hash_name = get_hash_name(user.id)

    timeline = JSON.parse($redis.get(hash_name))

    updated = []

    #does not work with mentions
    timeline['tweets'].each do |tweet|
       updated << tweet if tweet['user_id'] != unfollowed.id
    end
    timeline['tweets'] = updated
    $redis.set hash_name, timeline.to_json
  end
end
