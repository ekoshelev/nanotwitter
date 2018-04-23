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


def get_main_timeline
    if ((@redis.get "home_timeline") !=nil)
        rb_hash = JSON.parse(@redis.get("home_timeline"))
      return rb_hash["tweets"]
  else
    return nil
  end
end

def post_tweet_redis(tweet)
  if ((@redis.get "home_timeline") !=nil)
    rb_hash = JSON.parse(@redis.get("home_timeline"))
    rb_hash["tweets"] << { :id => tweet.id, :text => tweet.text, :time_created => tweet.time_created, :user_id => tweet.user_id, :retweet_id => tweet.retweet_id }
    @redis.set "home_timeline", rb_hash.to_json
  else
    @redis.del "home_timeline"
    rb_hash = {:tweets => [{ :id => tweet.id, :text => tweet.text, :time_created => tweet.time_created, :user_id => tweet.user_id, :retweet_id => tweet.retweet_id }]}
    @redis.set "home_timeline", rb_hash.to_json
  end

  fanout(tweet)

end


def fanout(tweet)
  user_timelines = @followercontroller.get_followers(tweet.user)
  byebug
  tweet.mentions.each {|mentioned| user_timelines << mentioned.user}

  tweet_json = { :id => tweet.id, :time_created => tweet.time_created, :user_id => tweet.user_id, :retweet_id => tweet.retweet_id }

  if user_timelines.size>0
    user_timelines.each do |user|
      byebug
      hash_name = "user_timeline_#{user.id}"

      if @redis.get(hash_name) != nil
        user_timeline = JASON.parse(@redis.get(hash_name))
        user_timeline << tweet_json
        @redis.set hash_name, user_timeline
      else
        @redis.del hash_name
        @redis.set hash_name, [tweet_hash]
      end
    end
  end



end


end
