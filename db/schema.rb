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

ActiveRecord::Schema.define(:version => 20121017144402) do

  create_table "activities", :force => true do |t|
  end

  create_table "collaboration_requests", :force => true do |t|
    t.text     "message"
    t.integer  "user_id"
    t.integer  "node_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "collaborators", :force => true do |t|
    t.integer  "node_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "doc_versions", :force => true do |t|
    t.integer  "node_id"
    t.string   "content_file_name"
    t.string   "content_content_type"
    t.integer  "content_file_size"
    t.datetime "content_updated_at"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "let_me_know_recipients", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "node_images", :force => true do |t|
    t.integer  "node_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "media_file_name"
    t.string   "media_content_type"
    t.integer  "media_file_size"
    t.datetime "media_updated_at"
  end

  create_table "nodes", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "owner_id"
    t.integer  "parent_id"
    t.string   "type"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "file_content_file_name"
    t.string   "file_content_content_type"
    t.integer  "file_content_file_size"
    t.datetime "file_content_updated_at"
    t.string   "content_file_name"
    t.string   "content_content_type"
    t.integer  "content_file_size"
    t.datetime "content_updated_at"
    t.integer  "version"
    t.integer  "downloads_count"
    t.string   "pad_id"
    t.boolean  "once_created_as_folder_type"
    t.boolean  "closed"
    t.string   "cached_readonly_pad_id"
    t.float    "popularity_score"
    t.boolean  "explicitly_open_sourced"
    t.boolean  "node_images_dirty"
    t.integer  "vote_count",                  :default => 0
    t.integer  "vote_sum",                    :default => 0
  end

  add_index "nodes", ["node_images_dirty"], :name => "index_nodes_on_node_images_dirty"
  add_index "nodes", ["pad_id"], :name => "index_nodes_on_pad_id"
  add_index "nodes", ["parent_id", "name", "version"], :name => "index_nodes_on_parent_id_and_name_and_version", :unique => true
  add_index "nodes", ["type"], :name => "index_nodes_on_type"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "owner_id"
  end

  add_index "projects", ["owner_id"], :name => "index_projects_on_owner_id"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 5
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "sanctioned_tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "social_activities", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "verb"
    t.text     "options_as_json"
    t.boolean  "unseen",          :default => true
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "social_activities", ["target_id", "target_type", "created_at"], :name => "social_activities_target1"

  create_table "social_connections", :force => true do |t|
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "subscription_plans", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.integer  "max_number_closed_source_nodes"
    t.string   "max_document_space"
    t.integer  "max_number_collaborators"
    t.string   "monthly_cost"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "user_to_nodes", :force => true do |t|
    t.integer "user_id"
    t.integer "node_id"
    t.boolean "collapsed", :default => false
    t.integer "vote",      :default => 0
    t.boolean "voted"
  end

  add_index "user_to_nodes", ["user_id", "node_id"], :name => "index_user_to_nodes_on_user_id_and_node_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                                          :default => "", :null => false
    t.string   "encrypted_password",              :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                  :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "operator"
    t.string   "facebook_id"
    t.string   "sketchspace_cookie"
    t.string   "linkedin_id"
    t.string   "twitter_id"
    t.string   "full_name"
    t.integer  "associated_subscription_plan_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["linkedin_id"], :name => "index_users_on_linkedin_id", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["sketchspace_cookie"], :name => "index_users_on_sketchspace_cookie"
  add_index "users", ["twitter_id"], :name => "index_users_on_twitter_id", :unique => true

end
