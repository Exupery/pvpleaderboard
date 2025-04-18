class StatisticsController < BracketRegionController
  include Utils
  protect_from_forgery with: :exception

  @@DEFAULT_LIMIT = 50

  def show
    expires_in 1.day, public: true
    fresh_when(last_modified: last_players_update) if Rails.env.production?

    @title = "#{@title_region}#{@title_bracket || 'Leaderboard'} Statistics"
    @description = "World of Warcraft PvP #{@title_region + @title_bracket + ' ' unless @title_bracket.nil?}leaderboard representation by class, spec, race, faction, realm, and guild"

    @min_rating = get_min_rating params[:rating]

    @factions = Hash.new(0)
    @races = Hash.new(0)
    @classes = Hash.new(0)
    @specs = Hash.new(nil)
    @realms = Hash.new(nil)
    @guilds = Hash.new(nil)

    find_counts @bracket
  end

  protected

  def realm_counts(region, bracket, min_rating, limit)
    cache_key = "realm_counts_#{region.nil? ? 'all' : region}_#{bracket}_#{min_rating}_#{limit}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    bracket_clause = get_bracket_clause bracket

    sql = "SELECT realms.slug AS slug, realms.region AS region, COUNT(*) AS count FROM leaderboards JOIN players ON player_id=players.id JOIN realms ON players.realm_id=realms.id WHERE leaderboards.rating > #{min_rating} #{bracket_clause} #{@region_clause} GROUP BY slug, realms.region ORDER BY COUNT(*) DESC LIMIT #{limit}"
    rows = get_rows(sql)
    rows.each do |row|
      key = row["slug"] + row["region"]
      next unless Realms.list.has_key?(key)
      h[key] = {realm: Realms.list[key], count: row["count"].to_i}
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  private

  def get_bracket_clause bracket
    return bracket.nil? ? "" : "AND leaderboards.bracket LIKE '#{bracket}%'"
  end

  def get_min_rating rating_param
    return 0 if rating_param.nil?
    num = rating_param.to_i
    return num < 2200 ? 0 : num
  end

  def find_counts bracket
    @factions = faction_counts bracket
    @races = race_counts bracket
    @classes = class_counts bracket
    @specs = spec_counts bracket
    @realms = realm_counts(@region, bracket, @min_rating, @@DEFAULT_LIMIT)
    @guilds = guild_counts bracket
  end

  def faction_counts bracket
    cache_key = "faction_counts_#{@region}_#{bracket.nil? ? "all" : bracket}_#{@min_rating}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    bracket_clause = get_bracket_clause bracket

    rows = get_rows("SELECT factions.name AS faction, COUNT(*) AS count FROM leaderboards JOIN players ON player_id=players.id JOIN factions ON players.faction_id=factions.id WHERE leaderboards.rating > #{@min_rating} #{bracket_clause} #{@region_clause} GROUP BY faction ORDER BY faction ASC")
    rows.each do |row|
      h[row["faction"]] = row["count"].to_i
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  def race_counts bracket
    cache_key = "race_counts_#{@region}_#{bracket.nil? ? "all" : bracket}_#{@min_rating}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    bracket_clause = get_bracket_clause bracket

    rows = get_rows("SELECT races.name AS race, COUNT(*) AS count FROM leaderboards JOIN players ON player_id=players.id JOIN races ON players.race_id=races.id WHERE leaderboards.rating > #{@min_rating} #{bracket_clause} #{@region_clause} GROUP BY race ORDER BY race ASC")
    rows.each do |row|
      h[row["race"]] = row["count"].to_i
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  def class_counts bracket
    cache_key = "class_counts_#{@region}_#{bracket.nil? ? "all" : bracket}_#{@min_rating}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    bracket_clause = get_bracket_clause bracket

    rows = get_rows("SELECT classes.name AS class, COUNT(*) AS count FROM leaderboards JOIN players ON player_id=players.id JOIN classes ON players.class_id=classes.id WHERE leaderboards.rating > #{@min_rating} #{bracket_clause} #{@region_clause} GROUP BY class ORDER BY class ASC")
    rows.each do |row|
      h[row["class"]] = row["count"].to_i
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  def spec_counts bracket
    cache_key = "spec_counts_#{@region}_#{bracket.nil? ? "all" : bracket}_#{@min_rating}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    bracket_clause = get_bracket_clause bracket

    rows = get_rows("SELECT specs.name AS spec, specs.icon, classes.name AS class, COUNT(DISTINCT(leaderboards.player_id)) AS count FROM leaderboards JOIN players ON player_id=players.id JOIN specs ON players.spec_id=specs.id JOIN classes ON specs.class_id=classes.id WHERE leaderboards.rating > #{@min_rating} #{bracket_clause} #{@region_clause} GROUP BY spec, specs.icon, class ORDER BY spec ASC")
    rows.each do |row|
      h[row["class"] + row["spec"]] = SpecInfo.new(row["spec"], row["count"].to_i, row["icon"], row["class"])
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  def guild_counts bracket
    cache_key = "guild_counts_#{@region}_#{bracket.nil? ? "all" : bracket}_#{@min_rating}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    bracket_clause = get_bracket_clause bracket

    rows = get_rows("SELECT guild, realms.name AS realm, factions.name AS faction, COUNT(*) FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN factions ON players.faction_id=factions.id JOIN realms ON players.realm_id=realms.id WHERE guild != '' AND guild IS NOT NULL #{bracket_clause} #{@region_clause} AND leaderboards.rating > #{@min_rating} GROUP BY guild, realms.name, factions.name ORDER BY COUNT(*) DESC LIMIT 100")
    rows.each do |row|
      h[row["guild"] + row["realm"] + row["faction"]] = GuildInfo.new(row["guild"], row["realm"], row["faction"], row["count"].to_i)
    end

    Rails.cache.write(cache_key, h)
    return h
  end

end

class SpecInfo
  attr_reader :name, :icon, :class_name
  attr_accessor :count

  def initialize(name, count, icon, class_name)
    @name = name
    @count = count
    @icon = icon
    @class_name = class_name
  end
end

class GuildInfo
  attr_reader :name, :realm, :faction
  attr_accessor :count

  def initialize(name, realm, faction, count)
    @name = name
    @realm = realm
    @faction = faction
    @count = count
  end
end
