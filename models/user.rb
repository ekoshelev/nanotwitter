class User < ActiveRecord::Base

  has_many :tweets

  has_many :followers, class_name: 'Follower', foreign_key: 'user_id'
  has_many :following, class_name: 'Follower', foreign_key: 'follower_id'

  has_many :mentions
  has_many :mentioned, through: :mentions, source: :tweet

end
