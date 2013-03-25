# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130325072052) do

  create_table "admins", :force => true do |t|
    t.string   "email",                :default => "", :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "admins", ["authentication_token"], :name => "index_admins_on_authentication_token", :unique => true
  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true

  create_table "games", :force => true do |t|
    t.integer  "match_id"
    t.integer  "winner_id"
    t.integer  "winner_score"
    t.integer  "loser_id"
    t.integer  "loser_score"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "games", ["loser_id"], :name => "index_games_on_loser_id"
  add_index "games", ["winner_id"], :name => "index_games_on_winner_id"

  create_table "matches", :force => true do |t|
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.datetime "occured_at"
    t.integer  "winner_id"
    t.integer  "loser_id"
    t.integer  "winner_score", :default => 0
    t.integer  "loser_score",  :default => 0
  end

  create_table "player_tags", :force => true do |t|
    t.integer "player_id", :null => false
    t.integer "tag_id",    :null => false
  end

  add_index "player_tags", ["tag_id", "player_id"], :name => "index_player_tags_on_tag_id_and_player_id", :unique => true

  create_table "players", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "rank"
    t.boolean  "active",         :default => true
    t.integer  "initial_rating"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
