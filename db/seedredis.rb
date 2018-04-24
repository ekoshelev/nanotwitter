class SeedRedis
  def initialize
    $redis = Redis.new(url: ENV["REDIS_URL"])
    @followers=Follower.all
    @users = User.all
    @followercontroller=FollowerController.new($redis, @users)
  end

  def put_followers_into_redis
    @followers.each do |follower|
      @followercontroller.incr_following(follower.follower_id,follower.user_id)
    end
  end



end
