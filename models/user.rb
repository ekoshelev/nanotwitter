class User < ActiveRecord::Base

  has_many :tweets

  #This does not work
  has_many :followers, foreign_key: :follower_id
  has_many :follower_ids, through: :followers, source: :follower_id
  has_many :followers, foreign_key: :followee_id
  has_many :followee_ids, foreign_key: :followers, source: :followee_id

  # has_many :followers
  # has_many :users, through: :followers

  has_many :mentions
  has_many :retweets
  #has_many :tweets, through: :mentions

end
