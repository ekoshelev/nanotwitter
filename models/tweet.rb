class Tweet < ActiveRecord::Base
  belongs_to :user
  belongs_to :retweet

  has_many :tweetHashtags
  has_many :hashtags, through: :tweetHashtags

  has_many :mentions
  has_many :users, through: :mentions




end
