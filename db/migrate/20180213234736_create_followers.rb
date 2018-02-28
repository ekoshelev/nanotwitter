class CreateFollowers < ActiveRecord::Migration[5.1]
  def change
    create_table :followers do |j|
      j.integer :follower_id
      j.integer :followee_id
    end
  end
end
