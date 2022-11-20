include Utils

require "httparty"
require "yajl/json_gem"

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
    GC.start # Parsing all the JSON seems to retain a lot of mem, encourage cleanup
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

    player_hash = get_player_with_retry cache_key
    return nil if player_hash.nil?
    player = Player.new(player_hash)

    Rails.cache.write(cache_key, player, :expires_in => 30.minutes) unless player.nil?
    return player
  end

  def get_player_with_retry player_id
    # Blizzard's player API often flakes out but works on retry
    cnt = 0
    while cnt < 3
      begin
        get_statistics
        get_achievements
        return get_player_details
      rescue Exception => e
        cnt += 1
        logger.warn("Attempt #{cnt} failed for #{player_id}: #{e.to_s}")
        sleep(0.5)
      end
    end

    return nil
  end

  def get_player_details
    hash = Hash.new

    hash["region"] = @region
    hash["realm_slug"] = @realm_slug

    profile = get("")

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

    t = Thread.new {
      hash["ratings"] = Hash.new
      wait @statistics
      assign_ratings(hash, @statistics)
    }

    equipment = get "/equipment"
    hash["ilvl"] = profile["equipped_item_level"]

    populate_talents(hash, hash["spec"])

    wait @achievements
    hash["titles"] = get_titles @achievements
    hash["achiev_dates"] = get_achiev_dates @achievements

    t.join

    return hash
  end

  def wait obj
    cnt = 0
    while (obj.nil? && cnt < 64)
      cnt += 1
      sleep(0.25)
    end
  end

  def get_achievements
    Thread.new {
      @achievements = get "/achievements"
    }
  end

  def get_statistics
    Thread.new {
      @statistics = get "/achievements/statistics"
    }
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
    return nil if json["assets"].nil?
    json["assets"].each do |asset|
      return asset["value"] if asset["key"] == "main"
    end
    return nil
  end

  def assign_ratings(hash, statistics)
    highest = Hash.new()
    stats = Hash.new()

    if !statistics["categories"].nil?
      stats = statistics["categories"]
    elsif !statistics["statistics"].nil?
      stats = statistics["statistics"]
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
      if !json["rating"].nil?
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

    achievements = json["achievements"]
    pvp_achievements = Achievement.get_seasonal_achievements
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

  def get_achiev_dates json
    achiev_dates  = Hash.new

    achievements = json["achievements"]
    rating_achievements = PlayerAchievement.get_rating_achievements

    achievements.each do |a|
      id = a["id"]
      next unless rating_achievements.has_key? id
      time = a["completed_timestamp"]
      achievement = rating_achievements[id]
      achiev_dates[id] = PlayerAchievement.new(achievement, time)
    end

    return achiev_dates
  end

  def populate_talents(player_hash, spec)
    player_hash["class_talents"] = Array.new
    player_hash["spec_talents"] = Array.new
    player_hash["pvp_talents"] = Array.new
    return if spec.nil?
    json = get "/specializations"

    talent_icons = get_talent_icons "talents"
    pvp_talent_icons = get_talent_icons "pvp_talents"

    json["specializations"].each do |specialization|
      s = specialization["specialization"]
      next unless s["name"] == spec

      loadout = get_loadout specialization

      parse_talents(loadout, player_hash, "class", talent_icons)
      parse_talents(loadout, player_hash, "spec", talent_icons)

      next if specialization["pvp_talent_slots"].nil?
      specialization["pvp_talent_slots"].each do |slot|
        selected = slot["selected"]
        id = selected["talent"]["id"]
        name = selected["talent"]["name"]
        spell_id = selected["spell_tooltip"]["spell"]["id"]
        player_hash["pvp_talents"].push({:id => id, :spell_id => spell_id, :name => name, :icon => pvp_talent_icons[id]})
      end
    end
  end

  def get_loadout specialization
    # Players who have not created a loadout will have the
    # necessary fields directly on the specialization object
    return specialization if specialization["loadouts"].nil?

    specialization["loadouts"].each do |loadout|
      return loadout if loadout["is_active"]
    end

    # This should never get hit but return an empty
    # hash instead of null for such an edge case
    # https://xkcd.com/2200/
    return Hash.new
  end

  def parse_talents(json, hash, talent_type, talent_icons)
    return if json["selected_#{talent_type}_talents"].nil?
    json["selected_#{talent_type}_talents"].each do |talent|
      id = talent["tooltip"]["talent"]["id"]
      name = talent["tooltip"]["talent"]["name"]
      spell_id = talent["tooltip"]["spell_tooltip"]["spell"]["id"]
      hash["#{talent_type}_talents"].push({:id => id, :spell_id => spell_id, :name => name, :icon => talent_icons[id]})
    end
  end

  def get_talent_icons tbl
    cache_key = "#{tbl}_icons"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    talent_icons = Hash.new
    rows = ActiveRecord::Base.connection.execute("SELECT id, icon FROM #{tbl}")
    rows.each do |row|
      icon = row["icon"] == "" ? "placeholder" : row["icon"]
      talent_icons[row["id"]] = icon
    end

    Rails.cache.write(cache_key, talent_icons)
    return talent_icons
  end

  def get path
    uri = create_uri path
    return nil if uri.nil?
    res = HTTParty.get(uri, timeout: 5)
    if res.code == 401
      # On 401 clear oauth token cache to force a new one and try again
      Rails.cache.delete(@@OAUTH_CACHE_KEY)
      res = HTTParty.get(create_uri path)
    end
    return Hash.new if (res.body.nil? || res&.code != 200)
    return JSON.parse(res.body)
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
