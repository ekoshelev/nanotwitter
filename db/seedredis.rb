class SeedRedis
  def initialize
    @redis = Redis.new(url: ENV["REDIS_URL"])
    @tweets= Tweet.all
    @followers=Follower.all
    @users = User.all
    @followercontroller=FollowerController.new(@redis, @users)
    @timeclass=ReturnTimeline.new(@redis, @tweets, @followers,@followercontroller)
  end

  def put_tweets_into_redis
    tweets= @tweets.sort_by{ |k| k["time_created"] }.reverse!
    tweets = tweets[0..49]
    @tweets.each do |tweet|
      @timeclass.post_tweet_home_timeline(tweet)
    end
  end

  def put_followers_into_redis
    @followers.each do |follower|
      @followercontroller.incr_following(follower.follower_id,follower.user_id)
    end
  end

@twitter_functionality = TwitterFunctionality.new

end
