class CreateHashtag < ActiveRecord::Migration[5.1]
  def change
    create_table :hashtags do |t|
      t.string :name
    end
  end
end
