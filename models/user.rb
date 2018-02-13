class User < ActiveRecord::Base
  has_many :tweets

  has_many :followers
  has_many :users, through: :followers

  has_many :mentions
  has_many :tweets, through: :mentions
end
