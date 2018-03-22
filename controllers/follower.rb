
  def get_follower_count(user)
    Redis::put(user_followers,"value")
    Redis::get("user_key")

  end

  def get_following_count(user)
  end

  def incr_following_count(user)
      Redis::increment("key")
  end

  def decr_following_count(user)
        Redis::decrement("key")
  end

def  incr_following_count(user)
    Redis::increment("key")
end

def decr_following_count(user)
      Redis::decrement("key")
end
