include Utils

require "httparty"

class PlayerController < BracketRegionController
  protect_from_forgery with: :exception

  @@URI = "https://%s.api.blizzard.com/profile/wow/character/%s/%s%s?locale=en_US&access_token=%s&namespace=profile-%s"
  @@OAUTH_URI = "https://us.battle.net/oauth/token"
  @@OAUTH_ID = ENV["BATTLE_NET_CLIENT_ID"]
  @@OAUTH_SECRET = ENV["BATTLE_NET_SECRET"]
  @@OAUTH_CACHE_KEY = "oauth_access_token"

  def show
    expires_in 1.hour, public: true

    redirect_to "/players" if params[:player].nil?

    @player_name = params[:player].capitalize
    @realm_name = @realm.nil? ? params[:realm_slug] : @realm.name
    @title = "#{@player_name} - #{@realm_name}"
    @description = "World of Warcraft PvP details for #{@player_name} of #{@realm_name}"

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

    player_hash = create_player_hash
    return nil if player_hash.nil?
    player = Player.new(player_hash)

    Rails.cache.write(cache_key, player, :expires_in => 15.minutes) unless player.nil?
    return player
  end

  def create_player_hash
    hash = Hash.new

    hash["region"] = @region
    hash["realm_slug"] = @realm_slug

    profile = get("")
    return nil unless valid_response(profile)

    hash["name"] = profile["name"]
    hash["guild"] = get_guild profile["guild"]

    active = profile["active_spec"]
    # Spec may be nil if very low level player who hasn't selected a spec yet
    hash["spec"] = active["name"] unless active.nil?
    hash["spec_icon"] = (active.nil? || active["id"].nil?)  ? "placeholder" : get_spec_icon(active["id"])

    hash["faction"] = profile["faction"]["name"]
    hash["race"] = profile["race"]["name"]
    hash["class"] = profile["character_class"]["name"]
    hash["gender"] = profile["gender"]["type"] == "MALE" ? 0 : 1

    hash["thumbnail"] = get_thumbnail

    hash["ratings"] = Hash.new
    assign_ratings(hash, get("/achievements/statistics"))

    hash["titles"] = get_titles get "/achievements"

    equipment = get "/equipment"
    hash["neck_level"] = get_neck_level equipment
    hash["cloak_rank"] = get_cloak_rank equipment
    hash["ilvl"] = profile["equipped_item_level"]

    return hash
  end

  def get_spec talents
    talents.reject{ |t| !t["selected"] }.each do |tree|
      return tree["spec"]
    end
  end

  def get_spec_icon spec_id
    cache_key = "spec_icon_#{spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    icon = nil
    row = ActiveRecord::Base.connection.execute("SELECT icon FROM specs WHERE id=#{spec_id} LIMIT 1")
    row.each do |row| icon = row["icon"] end
    Rails.cache.write(cache_key, icon, :expires_in => 30.days) unless icon.nil?
    return icon
  end

  def get_guild json
    return nil if json.nil?
    return json["name"]
  end

  def get_thumbnail
    json = get "/character-media"
    return valid_response(json) ? json["render_url"] : nil
  end

  def assign_ratings(hash, statistics)
    highest = Hash.new()
    stats = Hash.new()
    if valid_response(statistics)
      if !statistics["categories"].nil?
        stats = statistics["categories"]
      elsif !statistics["statistics"].nil?
        stats = statistics["statistics"]
      end
    end
    stats.each do |cat|
      next unless cat["name"] == "Player vs. Player"
      next if cat["sub_categories"].nil?
      cat["sub_categories"].each do |sub_cat|
        next unless sub_cat["name"] == "Rated Arenas"
        sub_cat["statistics"].each do |s|
          if s["name"] == "Highest 2v2 personal rating"
            highest["2v2"] = { "high" => s["quantity"], "time" => s["last_updated_timestamp"] }
          elsif s["name"] == "Highest 3v3 personal rating"
            highest["3v3"] = { "high" => s["quantity"], "time" => s["last_updated_timestamp"] }
          end
        end
      end
    end

    @@BRACKETS.each do |bracket|
      json = get "/pvp-bracket/#{bracket}"

      h = Hash.new
      if valid_response(json)
        h["current_rating"] = json["rating"]
        h["wins"] = json["season_match_statistics"]["won"]
        h["losses"] = json["season_match_statistics"]["lost"]
      else
        h["current_rating"] = nil
        h["wins"] = 0
        h["losses"] = 0
      end
      h["high"] = highest[bracket]["high"].to_i if highest[bracket]
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
    return titles unless valid_response(json)

    achievements = json["achievements"]
    pvp_achievements = Achievement.get_pvp_achievements
    achievements.each do |a|
      id = a["id"]
      next unless pvp_achievements.has_key? id
      time = a["completed_timestamp"]
      achievement = pvp_achievements[id]
      title = Title.new(achievement.name, achievement.description, time)
      titles.push title
    end

    return titles
  end

  def get_neck_level json
    return 0 unless valid_response(json)
    equipped_items = json["equipped_items"]
    return 0 if equipped_items.nil?

    equipped_items.each do |item|
      next if item["name"] != "Heart of Azeroth"
      return item["azerite_details"]["level"]["value"]
    end

    return 0
  end

  def get_cloak_rank json
    return 0 unless valid_response(json)
    equipped_items = json["equipped_items"]
    return 0 if equipped_items.nil?

    equipped_items.each do |item|
      next if item["name"] != "Ashjra'kamas, Shroud of Resolve"
      txt = item["name_description"]["display_string"]
      return txt.split(" ")[1]
    end

    return 0
  end

  def valid_response res
    # Shenanigans necessary due to HTTParty not wanting Response.nil? calls
    # https://github.com/jnunemaker/httparty/issues/568
    return !res.body.nil? if res&.code == 200
    return false
  end

  def get path
    uri = create_uri path
    return nil if uri.nil?
    res = HTTParty.get(uri)
    if res.code == 401
      # On 401 clear oauth token cache to force a new one and try again
      Rails.cache.delete(@@OAUTH_CACHE_KEY)
      res = HTTParty.get(create_uri path)
    end
    return res
  end

  def create_uri path
    oauth_token = create_token
    return nil if oauth_token.nil? or @region.nil? or @realm.nil?
    return @@URI % [@region.downcase, CGI.escape(urlify(@realm.name)), CGI.escape(@player_name.downcase), path, oauth_token, @region.downcase]
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