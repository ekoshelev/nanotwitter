class Tweet < ActiveRecord::Base
  belongs_to :user
  belongs_to :retweet, class_name: 'Tweet', foreign_key: 'retweet_id'


  has_many :tweetHashtags
  has_many :hashtags, through: :tweetHashtags

  has_many :mentions
  has_many :users, through: :mentions




end
