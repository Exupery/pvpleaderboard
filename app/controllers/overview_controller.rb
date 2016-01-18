class OverviewController < ApplicationController
  protect_from_forgery with: :exception

  @@DEFAULT_LIMIT = 50

  def overview
    bracket = get_bracket
  	title_bracket = bracket.eql?("rbg") ? "RBG" : bracket
  	@title = "#{title_bracket || 'Leaderboard'} Overview"
    @description = "World of Warcraft PvP leaderboard representation by class, spec, race, faction, realm, and guild"

  	@factions = Hash.new(0)
    @races = Hash.new(0)
    @classes = Hash.new(0)
    @specs = Hash.new(nil)
    @realms = Hash.new(0)
    @guilds = Hash.new(nil)

    find_counts bracket
    set_bracket bracket
  end

  protected

  def set_bracket bracket
    case bracket
    when nil
      @bracket = "All Leaderboards"
    when "rbg"
      @bracket = "Rated Battlegrounds"
    else
      @bracket = bracket
    end
  end

  def realm_counts(bracket, limit)
    cache_key = "realm_counts_#{bracket}_#{limit}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT realms.name AS realm, COUNT(*) FROM bracket_#{bracket} JOIN players ON player_id=players.id JOIN realms ON players.realm_slug=realms.slug GROUP BY realm ORDER BY COUNT(*) DESC LIMIT #{limit}")
    rows.each do |row|
      h[row["realm"]] = row["count"].to_i
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  private

  def find_counts bracket
    if bracket.nil?
      @@BRACKETS.each do |b|
        (faction_counts b).each do |f, c|
          @factions[f] += c
        end

        (race_counts b).each do |r, c|
          @races[r] += c
        end

        (class_counts b).each do |cl, c|
          @classes[cl] += c
        end

        (spec_counts b).each do |s, info|
          if @specs[s].nil?
            @specs[s] = info
          else
            @specs[s].count += info.count
          end
        end

        (realm_counts(b, @@DEFAULT_LIMIT)).each do |r, c|
          @realms[r] += c
        end
      end
      @guilds = guild_counts "player_ids_all_brackets"
    else
      @factions = faction_counts bracket
      @races = race_counts bracket
      @classes = class_counts bracket
      @specs = spec_counts bracket
      @realms = realm_counts(bracket, @@DEFAULT_LIMIT)
      @guilds = guild_counts "bracket_#{bracket}"
    end
  end

  def faction_counts bracket
    cache_key = "faction_counts_#{bracket}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

  	h = Hash.new

  	rows = ActiveRecord::Base.connection.execute("SELECT factions.name AS faction, COUNT(*) FROM bracket_#{bracket} JOIN players ON player_id=players.id JOIN factions ON players.faction_id=factions.id GROUP BY faction ORDER BY faction ASC")
  	rows.each do |row|
  		h[row["faction"]] = row["count"].to_i
  	end

    Rails.cache.write(cache_key, h)
  	return h
	end

  def race_counts bracket
    cache_key = "race_counts_#{bracket}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT races.name AS race, COUNT(*) FROM bracket_#{bracket} JOIN players ON player_id=players.id JOIN races ON players.race_id=races.id GROUP BY race ORDER BY race ASC")
    rows.each do |row|
      h[row["race"]] = row["count"].to_i
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  def class_counts bracket
    cache_key = "class_counts_#{bracket}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT classes.name AS class, COUNT(*) FROM bracket_#{bracket} JOIN players ON player_id=players.id JOIN classes ON players.class_id=classes.id GROUP BY class ORDER BY class ASC")
    rows.each do |row|
      h[row["class"]] = row["count"].to_i
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  def spec_counts bracket
    cache_key = "spec_counts_#{bracket}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT specs.name AS spec, specs.icon, classes.name AS class, COUNT(*) FROM bracket_#{bracket} JOIN players ON player_id=players.id JOIN specs ON players.spec_id=specs.id JOIN classes ON specs.class_id=classes.id GROUP BY spec, specs.icon, class ORDER BY spec ASC")
    rows.each do |row|
      h[row["class"] + row["spec"]] = SpecInfo.new(row["spec"], row["count"].to_i, row["icon"], row["class"])
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  def guild_counts bracket
    cache_key = "guild_counts_#{bracket}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT guild, realms.name AS realm, factions.name AS faction, COUNT(*) FROM #{bracket} JOIN players ON player_id=players.id JOIN factions ON players.faction_id=factions.id JOIN realms ON players.realm_slug=realms.slug WHERE guild != '' GROUP BY guild,realms.name,factions.name ORDER BY COUNT(*) DESC LIMIT 100")
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
