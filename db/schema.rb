# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180215190635) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  #user_id referrs to the user being followed, follower_id referrs to the user following
  create_table "followers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "follower_id"
  end

  #name referrs to the #name
  create_table "hashtags", force: :cascade do |t|
    t.string "name"
  end

  #a mention is set up like a join table, joining a user and a tweet by id.
  create_table "mentions", force: :cascade do |t|
    t.integer "tweet_id"
    t.integer "user_id"
  end

  #the user_id referrs to the retweeter, and the tweet_id refeers to the id of the tweet being retweeted
  create_table "retweets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "tweet_id"
  end

  #joins a hastag with the tweet its being tagged in
  create_table "tweet_hashtags", force: :cascade do |t|
    t.integer "tweet_id"
    t.integer "hashtag_id"
  end

  create_table "tweets", force: :cascade do |t|
    t.string "text"
    t.datetime "time_created"
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password"
    t.string "api_token"
  end

end
