#!/usr/bin/env ruby

require "pg"

BASE_PATH = File.expand_path("../public/images", __dir__)
ICONS = File.join(BASE_PATH, "icons")
CLASSES = File.join(BASE_PATH, "classes")
RACES = File.join(BASE_PATH, "races")

## Tables whose `icon` column holds a Blizzard FileDataID
ICON_TABLES = [ "specs", "talents", "pvp_talents", "achievements" ]

def connect
  PG.connect(ENV["POSTGRESQL_DEV_URL"])
end

## FileDataIDs referenced by the DB with no <id>.png on disk.
## Rows with a blank icon are skipped - that means the updater never resolved an
## icon for the row, which is missing data rather than a missing file.
def missing_icon_ids(db)
  ids = ICON_TABLES.flat_map do |table|
    db.exec("SELECT DISTINCT icon FROM #{table} WHERE icon <> ''").map { |row| row["icon"] }
  end

  ids.uniq.reject { |id| File.exist?(File.join(ICONS, "#{id}.png")) }.sort_by(&:to_i)
end

## Class and race icons are named after the class/race, not a FileDataID
def missing_class_icons(db)
  db.exec("SELECT name FROM classes")
    .map { |row| row["name"].downcase.gsub(/\s/, "_") }
    .reject { |name| File.exist?(File.join(CLASSES, "#{name}.png")) }
    .sort
end

def missing_race_icons(db)
  [ "female", "male" ].flat_map { |gender|
    db.exec("SELECT name FROM races")
      .map { |row| "#{row["name"].downcase.gsub(/\s/, "_")}_#{gender}" }
  }.reject { |name| File.exist?(File.join(RACES, "#{name}.png")) }.sort
end

if __FILE__ == $PROGRAM_NAME
  db = connect
  icons = missing_icon_ids(db)
  classes = missing_class_icons(db)
  races = missing_race_icons(db)
  db.close

  if icons.empty? && classes.empty? && races.empty?
    puts "All required icons present in #{BASE_PATH}"
    exit 0
  end

  puts "MISSING:"
  icons.each { |id| puts "  icons/#{id}.png" }
  classes.each { |name| puts "  classes/#{name}.png" }
  races.each { |name| puts "  races/#{name}.png" }

  puts
  puts "#{icons.length} icon(s), #{classes.length} class icon(s), #{races.length} race icon(s) missing."
  puts "Run bin/fetch_missing_icons.rb to download the missing icons." unless icons.empty?
end
