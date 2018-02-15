class CreateMention < ActiveRecord::Migration[5.1]
  def change
    create_table :mentions do |j|
      j.integer :tweet_id
      j.integer :user_id
    end
  end
end
