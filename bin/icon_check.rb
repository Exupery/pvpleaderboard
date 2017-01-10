#!/usr/bin/env ruby

require "pg"

BASE_PATH = "public/images/icons/"
TABLES = [ "specs", "talents" ]

db = PG.connect(ENV["POSTGRESQL_DEV_URL"])
has_missing = false
TABLES.each do |table|
  db.exec("SELECT DISTINCT(icon) FROM #{table}") do |result|
    result.each do |row|
      icon_name = row["icon"]
      icon_file = "#{BASE_PATH + icon_name}.png"

      if !(File.exist?(icon_file))
        puts "MISSING:" if !has_missing
        has_missing = true
        puts icon_name
      end
    end
  end
end
db.close
puts "All required icons present in #{BASE_PATH}" unless has_missing
