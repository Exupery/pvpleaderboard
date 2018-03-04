#!/usr/bin/env ruby

require "pg"

BASE_PATH = "public/images/"
ICONS = "icons/"
CLASSES = "classes/"
RACES = "races/"
TABLES = [ "specs", "talents" ]

db = PG.connect(ENV["POSTGRESQL_DEV_URL"])
$has_missing = false

## Check if `icon_file` exists
def check(icon_name, icon_file)
  if !(File.exist?(icon_file))
    puts "MISSING:" if !$has_missing
    $has_missing = true
    puts icon_name
  end
end

## Check tables with icon field
TABLES.each do |table|
  db.exec("SELECT DISTINCT(icon) FROM #{table}") do |result|
    result.each do |row|
      icon_name = row["icon"]
      icon_file = "#{BASE_PATH + ICONS + icon_name}.png"

      check(icon_name, icon_file)
    end
  end
end

## Check tables without icon fields
db.exec("SELECT name FROM classes") do |result|
  result.each do |row|
    icon_name = row["name"].downcase.gsub(/\s/, "_")
    icon_file = "#{BASE_PATH + CLASSES + icon_name}.png"

    check(icon_name, icon_file)
  end
end
["female", "male"].each do |gender|
  db.exec("SELECT name FROM races") do |result|
    result.each do |row|
      icon_name = row["name"].downcase.gsub(/\s/, "_") + "_" + gender
      icon_file = "#{BASE_PATH + RACES + icon_name}.png"

      check(icon_name, icon_file)
    end
  end
end

db.close
puts "All required icons present in #{BASE_PATH}" unless $has_missing
