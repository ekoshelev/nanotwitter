class ReturnTimeline
def initialize
  @tweets = Tweet.all
end

  def return_recent_tweets
    tweets= @tweets.sort_by{ |k| k["time_created"] }.reverse!
    return tweets[0..49]
  end

end
