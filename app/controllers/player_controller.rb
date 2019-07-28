include Utils

require "httparty"

class PlayerController < BracketRegionController
  protect_from_forgery with: :exception

  @@URI = "https://%s.api.blizzard.com/wow/character/%s/%s?fields=pvp,statistics,achievements,talents,guild&access_token=%s"
  @@OAUTH_URI = "https://us.battle.net/oauth/token"
  @@OAUTH_ID = ENV["BATTLE_NET_CLIENT_ID"]
  @@OAUTH_SECRET = ENV["BATTLE_NET_SECRET"]
  @@OAUTH_CACHE_KEY = "oauth_access_token"

  def show
    expires_in 1.hour, public: true

    redirect_to "/players" if params[:player].nil?

    @player_name = params[:player].capitalize
    @title = "#{@player_name} - #{@realm.name}"
    @description = "World of Warcraft PvP details for #{@player_name} of #{@realm.name}"

    @player = get_player
    @image = @player.main_image if @player
  end

  def search
    @title = "Player Audit"
    @description = "View a player's PvP ratings and history."

    render "search"
  end

  private

  def get_player
    cache_key = "#{@region}_#{@realm_slug}_#{@player_name}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    uri = create_uri
    return nil if uri.nil?
    res = HTTParty.get(uri)
    if res.code == 401
      # On 401 clear oauth token cache to force a new one and try again
      Rails.cache.delete(@@OAUTH_CACHE_KEY)
      res = HTTParty.get(create_uri)
    end
    return nil if res.code != 200

    player_hash = create_player_hash res.parsed_response
    player = Player.new(player_hash)

    Rails.cache.write(cache_key, player, :expires_in => 15.minutes) unless player.nil?
    return player
  end

  def create_player_hash json
    hash = Hash.new

    hash["region"] = @region
    hash["realm_slug"] = @realm_slug

    hash["name"] = json["name"]
    hash["thumbnail"] = json["thumbnail"]
    hash["guild"] = get_guild json["guild"]

    spec = get_spec(json["talents"])
    hash["spec"] = spec["name"]
    hash["spec_icon"] = spec["icon"]

    hash["faction"] = get_name("factions", json["faction"])
    hash["race"] = get_name("races", json["race"])
    hash["class"] = get_name("classes", json["class"])

    hash["ratings"] = Hash.new
    assign_ratings(hash, json["pvp"], json["statistics"])

    hash["titles"] = get_titles json["achievements"]

    return hash
  end

  def get_spec talents
    talents.reject{ |t| !t["selected"] }.each do |tree|
      return tree["spec"]
    end
  end

  def get_name(table, id)
    cache_key = "#{table}_#{id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    name = nil
    row = ActiveRecord::Base.connection.execute("SELECT name FROM #{table} WHERE id=#{id} LIMIT 1")
    row.each do |row| name = row["name"] end
    Rails.cache.write(cache_key, name, :expires_in => 30.days) unless name.nil?
    return name
  end

  def get_guild json
    return nil if json.nil?
    return json["name"]
  end

  def assign_ratings(hash, pvp, statistics)
    highest = Hash.new()
    arena_stats = statistics["subCategories"]
      .reject{ |sc| sc["name"] != "Player vs. Player" }[0]["subCategories"]
      .reject{ |ssc| ssc["name"] != "Rated Arenas" }[0]
    arena_stats["statistics"].each do |s|
      if s["lastUpdated"] > 0
        if s["name"] == "Highest 2 man personal rating"
          highest["2v2"] = { "high" => s["quantity"], "time" => s["lastUpdated"] }
        elsif s["name"] == "Highest 3 man personal rating"
          highest["3v3"] = { "high" => s["quantity"], "time" => s["lastUpdated"] }
        end
      end
    end

    pvp["brackets"].each do |b|
      # for some reason each bracket is an array with the
      # useful info stored as an object in the second element
      bracket = b[1]["slug"]
      next unless Brackets.list.include?(bracket)
      h = Hash.new
      h["current_rating"] = b[1]["rating"]
      h["wins"] = b[1]["seasonWon"]
      h["losses"] = b[1]["seasonLost"]
      h["high"] = highest[bracket]["high"] if highest[bracket]
      h["time"] = get_date(highest[bracket]["time"]) if highest[bracket]

      hash["ratings"][bracket] = h
    end
  end

  def get_date time
    return nil if time.nil? || time <= 0
    return Time.at(time / 1000).to_date.strftime("%-d %B %Y")
  end

  def get_titles json
    titles  = Array.new
    return titles if json.nil?

    completed_ids = json["achievementsCompleted"]
    timestamps = json["achievementsCompletedTimestamp"]

    pvp_achievements = Achievement.get_pvp_achievements
    completed_ids.each_index do |i|
      id = completed_ids[i]
      next unless pvp_achievements.has_key? id
      time = timestamps[i]
      achievement = pvp_achievements[id]
      title = Title.new(achievement.name, achievement.description, time)
      titles.push title
    end

    return titles
  end

  def create_uri
    oauth_token = create_token
    return nil if oauth_token.nil?
    return @@URI % [@region.downcase, urlify(@realm.name), CGI.escape(@player_name), oauth_token]
  end

  def create_token
    return Rails.cache.read(@@OAUTH_CACHE_KEY) if Rails.cache.exist?(@@OAUTH_CACHE_KEY)
    res = HTTParty.post(@@OAUTH_URI, body: {
      client_id: @@OAUTH_ID,
      client_secret: @@OAUTH_SECRET,
      grant_type: "client_credentials"
    })
    return nil if res.code != 200
    access_token = res.parsed_response["access_token"]
    return nil if access_token.nil?
    Rails.cache.write(@@OAUTH_CACHE_KEY, access_token, :expires_in => 30.minutes)
    return access_token
  end

end