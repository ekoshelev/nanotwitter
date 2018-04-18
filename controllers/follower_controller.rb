class FollowerController
  def initialize
    @users = User.all
    @redis = Redis.new(url: ENV["REDIS_URL"])
  end

  def incr_following(user,following)
     fcount_id= make_followingcount_id(user)
     follower_count_id= make_followercount_id(following)
     following_id= make_following_id(user)
     followers_id= make_follower_id(following)
     if @redis.get(fcount_id)==nil
      @redis.del(fcount_id)
    end
    if @redis.get( follower_count_id)==nil
      @redis.del(follower_count_id)
    end
    if @redis.lrange(following_id,0,-1)==[]
      @redis.del(following_id)
    end
    if @redis.lrange(followers_id,0,-1)==[]
      @redis.del(followers_id)
    end
    @redis.incr(fcount_id)
    @redis.incr(follower_count_id)
    @redis.rpush following_id, following
    @redis.rpush followers_id, user
  end

  def returnUsername(user)
    return User.find_by(id: user).name

  end

  def decr_following(user,following)
    fcount_id= make_followingcount_id(user)
    follower_count_id= make_followercount_id(following)
    following_id= make_following_id(user)
    followers_id= make_follower_id(following)
    @redis.lrem(following_id,-1, following)
    @redis.lrem(followers_id,-1, user)
    @redis.decr(fcount_id)
    @redis.decr(follower_count_id)
  end

  def get_following_count(user)
     fcount_id= make_followingcount_id(user)
    if @redis.get(fcount_id)==nil
      @redis.del(fcount_id)
      return 0
    end

    return @redis.get(fcount_id)
  end

  def get_followers_count(user)
    follower_count_id= make_followercount_id(user)
    if @redis.get(follower_count_id)==nil
      @redis.del(follower_count_id)
      return 0
    end
    return @redis.get(follower_count_id)
end

def get_following(user)
  following_id= make_following_id(user)
  if @redis.lrange(following_id,0,-1)==[]
    @redis.del(following_id)
    return @redis.lrange(following_id,0,-1)
  end
  return @redis.lrange(following_id,0,-1)
end

def get_followers(user)
  followers_id= make_follower_id(user)
  if @redis.lrange(followers_id,0,-1)==[]
    @redis.del(followers_id)
    return  @redis.lrange(followers_id,0,-1)
  end
  return  @redis.lrange(followers_id,0,-1)
end
=begin
  def get_follower_count(user)
    id = make_follower_id(user);
    if it doesnt exist
      Redis::put(id,1)
    return 1
  else {
    return  Redis::get(make_follower_id(user))
  }
  end

  def get_following_count(user)
    if it doesnt exist
    Redis::put(make_following_id(user),1)

    return 0
  else {
    return  Redis::get(make_following_id(user))
  }
  end



  def decr_following_count(user)
        Redis::decrement(make_following_id(user))
  end

  def  incr_follower_count(user)
      Redis::increment(make_follower_id(user))
  end

  def decr_follower_count(user)
        Redis::decrement(make_follower_id(user))
  end
=end
def make_following_id(user)
  return user.to_s + "_following";
end

def make_follower_id(user)
  return user.to_s + "_followers";
end
  def make_followingcount_id(user)
    return user.to_s + "_followingcount";
  end
  def make_followercount_id(user)
        return user.to_s + "_followercount";
  end
end
#where save to database?
