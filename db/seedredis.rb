class SeedRedis
  def initialize
    $redis = Redis.new(url: ENV["REDIS_URL"])
    @followers=Follower.all
    @users = User.all
    @tweets = Tweet.all
    @followercontroller=FollowerController.new($redis, @users)
  end

  def put_followers_into_redis
    @followers.each do |follower|
      @followercontroller.incr_following(follower.follower_id,follower.user_id)
    end
  end

  def put_timelines_into_redis
    @tweets.each do |tweet|
      #$redis_timeline.post_tweet_home_timeline(tweet)
      $redis_timeline.post_tweet_redis(tweet)
    end
  end

end
