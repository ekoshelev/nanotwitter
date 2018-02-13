class Hashtag < ActiveRecord::Base
  has_many :tweetHashtags
  has_many :tweets, through: :tweetHashtags
end
