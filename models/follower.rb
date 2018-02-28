class Follower < ActiveRecord::Base
  belongs_to :follower_id, class_name: "User"
  belongs_to :followee_id, class_name: "User"
end
