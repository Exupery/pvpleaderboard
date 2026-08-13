#!/usr/bin/env ruby

require "fileutils"
require "net/http"
require "open3"
require "tmpdir"
require "uri"

require_relative "icon_check"

CASC_URL = ENV["CASC_URL"].to_s
MAX_REDIRECTS = 3

if CASC_URL.empty?
  abort "CASC_URL is not set"
end

## Accepts either a base URL to append the ID to, or a format string with %s
def casc_url(id)
  CASC_URL.include?("%s") ? format(CASC_URL, id) : "#{CASC_URL.chomp("/")}/#{id}"
end

def fetch(url, redirects = MAX_REDIRECTS)
  response = Net::HTTP.get_response(URI(url))

  if response.is_a?(Net::HTTPRedirection) && redirects > 0
    return fetch(response["location"], redirects - 1)
  end

  response.is_a?(Net::HTTPSuccess) ? response.body : nil
end

## BLPConverter writes <input basename>.png into --dest, so downloading to
## <id>.blp is what produces the <id>.png the app expects.
def convert(blp_file, dest)
  _, stderr, status = Open3.capture3("BLPConverter", "--dest", dest, blp_file)
  status.success? ? nil : (stderr.strip.empty? ? "BLPConverter failed" : stderr.strip)
end

unless system("which BLPConverter > /dev/null 2>&1")
  abort "BLPConverter not found on PATH. Install it before running this script."
end

db = connect
missing = missing_icon_ids(db)
db.close

if missing.empty?
  puts "All required icons present in #{ICONS}"
  exit 0
end

puts "Found #{missing.length} missing icon(s). Downloading..."

downloaded = 0
failed = []

Dir.mktmpdir do |tmp|
  missing.each do |id|
    data = fetch(casc_url(id))

    if data.nil?
      failed << [ id, "download failed" ]
      next
    end

    unless data.start_with?("BLP2")
      failed << [ id, "not a BLP (file may not exist in the client)" ]
      next
    end

    blp_file = File.join(tmp, "#{id}.blp")
    File.binwrite(blp_file, data)

    error = convert(blp_file, ICONS)

    if error
      failed << [ id, error ]
    elsif !File.exist?(File.join(ICONS, "#{id}.png"))
      failed << [ id, "converted but #{id}.png was not produced" ]
    else
      puts "  OK #{id}.png"
      downloaded += 1
    end
  end
end

puts
puts "Done. #{downloaded} icon(s) written to #{ICONS}."

unless failed.empty?
  puts
  puts "Failed to fetch #{failed.length} icon(s):"
  failed.each { |id, reason| puts "  #{id}: #{reason}" }
end
