require_relative 'follower_controller'
require 'byebug'

class ReturnTimeline
def initialize(redis,tweets,followers,fc)
  @redis=redis
  @tweets = tweets
  @followers= followers
  @followercontroller = fc
end

  def return_recent_tweets
    tweets= @tweets.sort_by{ |k| k["time_created"] }.reverse!
    return tweets[0..49]
  end

  def return_follower_list(user)
    followers = @followers.select { |follower| follower.user_id == user.to_i }
    return followers
  end

  def return_following_list(user)
    following = @followers.select { |follower| follower.follower_id == user.to_i }
    return following
  end

  def return_tweets_by_user(user)
    usertweets = @tweets.select { |tweet| tweet.user_id == user.to_i }
    sortusertweets= usertweets.sort_by{ |k| k["time_created"] }.reverse!
    return sortusertweets[0..49]
  end

  def return_timeline_by_user(user)
    @followinglist = return_following_list(user.id)
    followingids=[]
      @followinglist.each do |follow|
        followingids.push(follow.user_id)
      end

      followingids.push()

        followingids.push(user.id.to_i)
    usertweets = @tweets.select { |tweet| followingids.include? tweet.user_id}

    user.mentions.each {|mention| usertweets.push(mention.tweet)}

    sortusertweets= usertweets.sort_by{ |k| k["time_created"] }.reverse!
    return sortusertweets[0..49]
  end

    def quitRedis
      @redis.quit
    end

    def connectRedis
      @redis._client.connect
    end
    
def add_user_redis(user)
  if ((@redis.get "users") !=nil)
    rb_hash = JSON.parse(@redis.get("users"))
    rb_hash["allusers"] << { :id => user.id,  :email => user.email, :api_token => user.api_token }
    @redis.set "users", rb_hash.to_json
  else
    @redis.del "home_timeline"
    rb_hash = {:tweets => [{ :id => tweet.id, :text => tweet.text, :time_created => tweet.time_created, :user_id => tweet.user_id, :retweet_id => tweet.retweet_id }]}
    @redis.set "home_timeline", rb_hash.to_json
  end
end

def get_main_timeline
    if ((@redis.get "home_timeline") !=nil)
        rb_hash = JSON.parse(@redis.get("home_timeline"))
        sortusertweets= rb_hash["tweets"].sort_by{ |k| k["time_created"] }.reverse!
      return sortusertweets
  else
    return nil
  end
end

def get_user_timeline(user)
  if @redis.get("user_timeline_#{user.id}") != nil
     timeline = JSON.parse(@redis.get("user_timeline_#{user.id}"))
     return timeline["tweets"]
  end
  return nil
end

def post_tweet_home_timeline(tweet)
  if ((@redis.get "home_timeline") !=nil)
    rb_hash = JSON.parse(@redis.get("home_timeline"))
    rb_hash["tweets"] << { :id => tweet.id, :text => tweet.text, :time_created => tweet.time_created, :user_id => tweet.user_id, :retweet_id => tweet.retweet_id }
    if (rb_hash["tweets"].size>=51)
      rb_hash["tweets"]=rb_hash["tweets"].drop(1)
    end
    @redis.set "home_timeline", rb_hash.to_json
  else
    @redis.del "home_timeline"
    rb_hash = {:tweets => [{ :id => tweet.id, :text => tweet.text, :time_created => tweet.time_created, :user_id => tweet.user_id, :retweet_id => tweet.retweet_id }]}
    @redis.set "home_timeline", rb_hash.to_json
  end
end

def post_tweet_redis(tweet)
  add_user_timeline([tweet],tweet.user)
  fanout(tweet)
end
def fanout(tweet)
  user_timelines = @followercontroller.get_followers(tweet.user.id)
  tweet.mentions.each do |mentioned|
    add = mentioned.user.id.to_s
    if !user_timelines.include?(add)
      user_timelines << add
    end
  end
  tweet_json = { :id => tweet.id, :text => tweet.text, :time_created => tweet.time_created, :user_id => tweet.user_id, :retweet_id => tweet.retweet_id }

  if user_timelines.size>0
    user_timelines.each do |user|
      hash_name = "user_timeline_#{user}"

      if @redis.get(hash_name) != nil
        user_timeline = JSON.parse(@redis.get(hash_name))
        user_timeline["tweets"] << tweet_json
        @redis.set hash_name, user_timeline.to_json
      else
        @redis.del hash_name
        @redis.set hash_name, {"tweets"=>[tweet_json]}.to_json
      end
    end
  end

end

def get_hash_name(id)
  "user_timeline_#{id}"
end

def add_user_timeline(tweets,user)
  timeline = {"tweets"=>[]}
  hash_name = get_hash_name(user.id)
  if @redis.get(hash_name) != nil
    timeline = JSON.parse(@redis.get(hash_name))
  else
    @redis.del hash_name
  end
  tweets.each do |tweet|
    tweet_json = { :id => tweet.id, :text => tweet.text, :time_created => tweet.time_created, :user_id => tweet.user_id, :retweet_id => tweet.retweet_id }
    timeline["tweets"] << tweet_json
  end

  @redis.set get_hash_name(user.id), timeline.to_json

end

def remove_user_timeline(unfollowed,user)
  hash_name = get_hash_name(user.id)
  timeline = JSON.parse(@redis.get(hash_name))

  timeline["tweets"].each do |tweet|
    if tweet['user_id'] == unfollowed.id
      timeline["tweets"].delete(tweet)
    end
  end

  @redis.set hash_name, timeline.to_json

end




end
