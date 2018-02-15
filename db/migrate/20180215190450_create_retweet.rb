class CreateRetweet < ActiveRecord::Migration[5.1]
  def change
    create_table :retweets do |j|
      j.integer :user_id
      j.integer :tweet_id
    end
  end
end
