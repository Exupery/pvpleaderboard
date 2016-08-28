#!/usr/bin/env ruby

require "fileutils"
require "find"

BASE_PATH = "public/images/icons/"

if ARGV.length != 2
  puts "A file containing icons to copy and where to copy from are required parameters"
  abort
end

icons_to_copy = ARGV[0]
source_root = ARGV[1]

File.open(icons_to_copy, "r") do |file|
  file.each_line do |line|
    icon = line.chomp
    Find.find(source_root) do |f|
      if f =~ /.*#{icon}\.png$/i
        dest = BASE_PATH + icon + ".png"
        FileUtils.cp(f, dest)
        break
      end
    end
  end
end
