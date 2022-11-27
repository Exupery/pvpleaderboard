# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 0) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievements", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 128
    t.string "description", limit: 1024
    t.string "icon", limit: 128
  end

  create_table "classes", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.index ["name"], name: "classes_name_key", unique: true
  end

  create_table "factions", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.index ["name"], name: "factions_name_key", unique: true
  end

  create_table "items", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 128
    t.string "quality", limit: 64
    t.datetime "last_update", precision: nil, default: -> { "now()" }
  end

  create_table "leaderboards", primary_key: ["region", "bracket", "player_id"], force: :cascade do |t|
    t.string "region", limit: 2, null: false
    t.string "bracket", limit: 3, null: false
    t.integer "player_id", null: false
    t.integer "ranking", limit: 2, null: false
    t.integer "rating", limit: 2, null: false
    t.integer "season_wins", limit: 2
    t.integer "season_losses", limit: 2
    t.datetime "last_update", precision: nil, default: -> { "now()" }
    t.index ["ranking"], name: "leaderboards_ranking_idx"
    t.index ["rating"], name: "leaderboards_rating_idx"
  end

  create_table "metadata", primary_key: "key", id: { type: :string, limit: 32 }, force: :cascade do |t|
    t.string "value", limit: 512, default: "", null: false
    t.datetime "last_update", precision: nil, default: -> { "now()" }
  end

  create_table "players", id: :serial, force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.integer "realm_id", null: false
    t.integer "blizzard_id", null: false
    t.integer "class_id"
    t.integer "spec_id"
    t.integer "faction_id"
    t.integer "race_id"
    t.integer "gender", limit: 2
    t.string "guild", limit: 64
    t.datetime "last_update", precision: nil, default: -> { "now()" }, null: false
    t.datetime "last_login", precision: nil, default: "0001-01-01 00:00:00", null: false
    t.text "profile_id"
    t.index ["class_id", "spec_id"], name: "players_class_id_spec_id_idx"
    t.index ["faction_id", "race_id"], name: "players_faction_id_race_id_idx"
    t.index ["guild"], name: "players_guild_idx"
    t.index ["realm_id", "blizzard_id"], name: "players_realm_id_blizzard_id_key", unique: true
  end

  create_table "players_achievements", primary_key: ["player_id", "achievement_id"], force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "achievement_id", null: false
  end

  create_table "players_items", primary_key: "player_id", id: :integer, default: nil, force: :cascade do |t|
    t.integer "head"
    t.integer "neck"
    t.integer "shoulder"
    t.integer "back"
    t.integer "chest"
    t.integer "shirt"
    t.integer "tabard"
    t.integer "wrist"
    t.integer "hands"
    t.integer "waist"
    t.integer "legs"
    t.integer "feet"
    t.integer "finger1"
    t.integer "finger2"
    t.integer "trinket1"
    t.integer "trinket2"
    t.integer "mainhand"
    t.integer "offhand"
  end

  create_table "players_pvp_talents", primary_key: ["player_id", "pvp_talent_id"], force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "pvp_talent_id", null: false
    t.boolean "stale", default: true
  end

  create_table "players_stats", primary_key: "player_id", id: :integer, default: nil, force: :cascade do |t|
    t.integer "strength"
    t.integer "agility"
    t.integer "intellect"
    t.integer "stamina"
    t.integer "critical_strike"
    t.integer "haste"
    t.integer "versatility"
    t.integer "mastery"
    t.integer "leech"
    t.integer "dodge"
    t.integer "parry"
  end

  create_table "players_talents", primary_key: ["player_id", "talent_id"], force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "talent_id", null: false
    t.boolean "stale", default: true
  end

  create_table "pvp_talents", id: :integer, default: nil, force: :cascade do |t|
    t.integer "spell_id", null: false
    t.integer "spec_id", null: false
    t.string "name", limit: 128, null: false
    t.string "icon", limit: 128
    t.index ["spec_id"], name: "pvp_talents_spec_id_idx"
  end

  create_table "races", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 32, null: false
  end

  create_table "realms", id: :integer, default: nil, force: :cascade do |t|
    t.string "slug", limit: 64, null: false
    t.string "name", limit: 64, null: false
    t.string "region", limit: 2, null: false
    t.index ["slug", "region"], name: "realms_slug_region_key", unique: true
  end

  create_table "specs", id: :integer, default: nil, force: :cascade do |t|
    t.integer "class_id", null: false
    t.string "name", limit: 32, null: false
    t.string "role", limit: 32
    t.string "icon", limit: 128
  end

  create_table "talents", id: :integer, default: nil, force: :cascade do |t|
    t.integer "spell_id", null: false
    t.integer "class_id", null: false
    t.integer "spec_id", null: false
    t.string "name", limit: 128, null: false
    t.string "icon", limit: 128
    t.integer "node_id"
    t.integer "display_row"
    t.integer "display_col"
    t.index ["class_id", "spec_id"], name: "talents_class_id_spec_id_idx"
    t.index ["node_id"], name: "talents_node_id_idx"
  end

  add_foreign_key "leaderboards", "players", name: "leaderboards_player_id_fkey"
  add_foreign_key "players", "classes", name: "players_class_id_fkey"
  add_foreign_key "players", "factions", name: "players_faction_id_fkey"
  add_foreign_key "players", "races", name: "players_race_id_fkey"
  add_foreign_key "players", "realms", name: "players_realm_id_fkey"
  add_foreign_key "players", "specs", name: "players_spec_id_fkey"
  add_foreign_key "players_achievements", "achievements", name: "players_achievements_achievement_id_fkey"
  add_foreign_key "players_achievements", "players", name: "players_achievements_player_id_fkey"
  add_foreign_key "players_items", "players", name: "players_items_player_id_fkey"
  add_foreign_key "players_pvp_talents", "players", name: "players_pvp_talents_player_id_fkey"
  add_foreign_key "players_pvp_talents", "pvp_talents", name: "players_pvp_talents_pvp_talent_id_fkey"
  add_foreign_key "players_stats", "players", name: "players_stats_player_id_fkey"
  add_foreign_key "players_talents", "players", name: "players_talents_player_id_fkey"
  add_foreign_key "players_talents", "talents", name: "players_talents_talent_id_fkey"
  add_foreign_key "pvp_talents", "specs", name: "pvp_talents_spec_id_fkey"
  add_foreign_key "specs", "classes", name: "specs_class_id_fkey"
  add_foreign_key "talents", "classes", name: "talents_class_id_fkey"
end
