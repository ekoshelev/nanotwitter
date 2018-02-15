class CreateTweet < ActiveRecord::Migration[5.1]
  def change
    create_table :tweets do |t|
      t.string :text
      t.timestamps :time_created
      t.integer :user_id
    end
  end
end
