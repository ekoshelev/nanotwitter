
  def get_follower_count(user)
    if it doesnt exist
    Redis::put(make_follower_id(user),1)
    return 0
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

  def incr_following_count(user)
      Redis::increment(make_following_id(user))
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


def make_following_id(user)
  return user + "_following";
end
def make_follower_id(user)
      return user + "_followers";
end

#where save to database?
