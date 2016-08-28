#!/usr/bin/env ruby

require "pg"

BASE_PATH = "public/images/icons/"
TABLES = [ "specs", "talents" ]

db = PG.connect(
  host: ENV["PVP_DB_HOST"],
  user: ENV["PVP_DB_USER"],
  password: ENV["PVP_DB_PASSWORD"],
  dbname: ENV["PVP_DB_NAME"])
has_missing = false
TABLES.each do |table|
  db.exec("SELECT DISTINCT(icon) FROM #{table}") do |result|
    result.each do |row|
      icon_name = row["icon"]
      icon_file = "#{BASE_PATH + icon_name}.png"

      if !(File.exist?(icon_file))
        has_missing = true
        puts "MISSING: #{icon_name}"
      end
    end
  end
end
db.close
puts "All required icons present in #{BASE_PATH}" unless has_missing