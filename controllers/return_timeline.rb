class ReturnTimeline
def initialize(tweets,followers)
  @tweets = tweets
  @followers= followers
  @alltweets= @tweets
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
end
