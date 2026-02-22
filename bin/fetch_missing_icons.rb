#!/usr/bin/env ruby

require "fileutils"
require "find"
require "open3"

ICONS_DEST = "public/images/icons/"
SCRIPT_DIR = File.dirname(__FILE__)

if ARGV.empty?
  puts "Usage: ruby #{$0} <WOW_ICONS_DIR>"
  abort
end

blp_source = ARGV[0]

unless Dir.exist?(blp_source)
  puts "Error: source directory not found: #{blp_source}"
  abort
end

# Run icon_check.rb and collect missing icon names
puts "Checking for missing icons..."
output, status = Open3.capture2("ruby #{SCRIPT_DIR}/icon_check.rb")

if status.exitstatus != 0
  puts "Error running icon_check.rb"
  abort
end

lines = output.lines.map(&:chomp)
missing_index = lines.index("MISSING:")

if missing_index.nil?
  puts output.strip
  exit 0
end

missing_icons = lines[(missing_index + 1)..].reject(&:empty?)

if missing_icons.empty?
  puts "No missing icons to fetch."
  exit 0
end

puts "Found #{missing_icons.length} missing icon(s). Converting from BLP..."

converted = 0
not_found = []

missing_icons.each do |icon_name|
  blp_file = nil

  Find.find(blp_source) do |f|
    if f =~ /\/#{Regexp.escape(icon_name)}\.blp$/i
      blp_file = f
      Find.prune
    end
  end

  if blp_file.nil?
    not_found << icon_name
    next
  end

  # BLPConverter outputs <iconname>.png into the dest directory
  _, stderr, status = Open3.capture3("BLPConverter", "--dest", ICONS_DEST, blp_file)

  if status.exitstatus != 0
    puts "  ERROR converting #{icon_name}: #{stderr.strip}"
  else
    # BLPConverter may preserve original casing; rename to lowercase if needed
    expected = File.join(ICONS_DEST, "#{icon_name.downcase}.png")
    produced = Dir[File.join(ICONS_DEST, "#{icon_name}.png")].first ||
               Dir[File.join(ICONS_DEST, "#{File.basename(blp_file, '.blp')}.png")].first

    if produced && produced != expected
      FileUtils.mv(produced, expected)
    end

    puts "  OK #{icon_name}"
    converted += 1
  end
end

puts
puts "Done. #{converted} icon(s) converted."

unless not_found.empty?
  puts "\nCould not find BLP source for #{not_found.length} icon(s):"
  not_found.each { |name| puts "  #{name}" }
end
