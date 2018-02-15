class CreateTweetHastag < ActiveRecord::Migration[5.1]
  def change
    create_table :tweet_hashtags do |j|
      j.integer :tweet_id
      j.integer :hashtag_id
    end
  end
end
