class CreateTweet < ActiveRecord::Migration[5.1]
  def change
    create_table :tweets do |t|
      t.string :text
      t.timestamp :time_created
      t.integer :user_id
      t.integer :retweet_id
    end
  end
end
