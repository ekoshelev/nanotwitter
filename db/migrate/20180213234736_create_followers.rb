class CreateFollowers < ActiveRecord::Migration[5.1]
  def change
    create_table :followers do |j|
      j.integer :follower_user_id
      j.integer :followee_user_id
    end
  end
end
