class CreateFollowers < ActiveRecord::Migration[5.1]
  def change
    create_table :followers do |j|
      j.integer :user_id
      j.integer :follower_id
    end
  end
end
