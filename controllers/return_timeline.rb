class ReturnTimeline
def initialize
  @tweets = Tweet.all
end

  def return_recent_tweets
    return @tweets[0..20]
  end

end
