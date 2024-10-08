class ClassesController < ApplicationController
  include Utils
  protect_from_forgery with: :exception

  @@NUM_TOP_PLAYERS_PER_BRACKET = ENV.fetch("TOP_PLAYERS_PER_BRACKET", 6)

  def select_class
    @title = "Class / Spec Selection"
    @description = "WoW PvP leaderboard talents, stats, and gear by class and spec"

    @heading = "Select a Class and Spec"

    render "results_by_class"
  end

  def results_by_class
    class_slug = slugify params[:class]
    clazz = Classes.list[class_slug]
    if clazz.nil?
      redirect_to "/pvp"
      return nil
    end

    spec_slug = slugify params[:spec]
    spec_slugs = Specs.slugs
    full_slug = "#{class_slug}_#{spec_slug}"
    if !spec_slugs.key?(full_slug)
      redirect_to "/pvp/#{class_slug}"
      return nil
    end
    spec = spec_slugs[full_slug]

    @class_name = clazz[:name]
    @spec_name = spec[:name]
    @class_and_spec = "#{spec[:name]} #{clazz[:name]}"
    @title = @class_and_spec
    @description = "World of Warcraft PvP leaderboard talents, stats, and gear for #{@class_and_spec}"
    @heading = @class_and_spec
    @image = "#{request.base_url}/images/classes/#{class_slug}.png"

    @class_id = clazz[:id]
    @spec_id = spec[:id]

    @class_talent_counts = get_class_talent_counts
    @spec_talent_counts = get_spec_talent_counts
    @hero_talent_counts = get_hero_talent_counts
    @pvp_talent_counts = get_pvp_talent_counts
    @stat_counts = get_stat_counts
    @gear = get_most_equipped_gear_by_spec(@class_id, @spec_id)
    @players_title = "The #{@@NUM_TOP_PLAYERS_PER_BRACKET} highest rated players from each bracket in each region"
    @top_players = get_top_players

    @total = total_player_count(@class_id, @spec_id)
  end

  private

  def get_top_players
    players = Array.new

    Regions.list.each do |region|
      Brackets.with_solo_blitz.each do |bracket|
        rows = get_rows("SELECT ranking, rating, season_wins AS wins, season_losses AS losses, players.name AS name, factions.name AS faction, races.name AS race, players.gender AS gender, realms.slug AS realm_slug, realms.name AS realm, realms.region AS region, leaderboards.bracket AS bracket FROM leaderboards LEFT JOIN players ON leaderboards.player_id=players.id LEFT JOIN factions ON players.faction_id=factions.id LEFT JOIN races ON players.race_id=races.id LEFT JOIN realms ON players.realm_id=realms.id WHERE players.class_id=#{@class_id} AND players.spec_id=#{@spec_id} AND realms.region='#{region}' AND (bracket='#{bracket}' OR bracket='#{bracket}_#{@spec_id}') ORDER BY ranking ASC LIMIT #{@@NUM_TOP_PLAYERS_PER_BRACKET}")

        rows.each do |row|
          players << Player.new(row)
        end
      end
    end

    return players
  end

  def get_class_talent_counts
    label = "class_#{@class_id}_#{@spec_id}"
    where = "players.class_id=#{@class_id} AND players.spec_id=#{@spec_id} AND (talents.spec_id=0 OR talents.spec_id=#{@spec_id}) AND talents.cat='CLASS'"
    return get_talent_counts(label, where)
  end

  def get_spec_talent_counts
    label = "spec_#{@class_id}_#{@spec_id}"
    where = "players.spec_id=#{@spec_id} AND talents.spec_id=#{@spec_id} AND talents.cat='SPEC'"
    return get_talent_counts(label, where)
  end

  def get_talent_counts(label, where)
    cache_key = "talent_counts_#{label}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = get_rows("SELECT talents.id AS talent, COUNT(DISTINCT(players.id)) AS count FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_talents ON players.id=players_talents.player_id JOIN talents ON players_talents.talent_id=talents.id WHERE #{where} GROUP BY talent")
    rows.each do |row|
      h[row["talent"]] = row["count"].to_i
    end

    write_to_cache_maybe_stale("players_talents", h, cache_key)
    return h
  end

  def get_pvp_talent_counts
    cache_key = "pvp_talent_counts_#{@spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = get_rows("SELECT pvp_talents.id AS pvp_talent, COUNT(DISTINCT(players.id)) AS count FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_pvp_talents ON players.id=players_pvp_talents.player_id JOIN pvp_talents ON players_pvp_talents.pvp_talent_id=pvp_talents.id WHERE pvp_talents.spec_id=#{@spec_id} GROUP BY pvp_talent ORDER BY count DESC")
    rows.each do |row|
      h[row["pvp_talent"]] = row["count"].to_i
    end

    write_to_cache_maybe_stale("players_pvp_talents", h, cache_key)
    return h
  end

  def get_hero_talent_counts
    cache_key = "hero_talent_counts_#{@spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = get_rows("SELECT talents.id AS hero_talent, COUNT(DISTINCT(players.id)) AS count FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_talents ON players.id=players_talents.player_id JOIN talents ON players_talents.talent_id=talents.id WHERE players.spec_id=#{@spec_id} AND cat='HERO' AND #{@spec_id}=ANY(hero_specs) GROUP BY hero_talent ORDER BY count DESC")
    rows.each do |row|
      h[row["hero_talent"]] = row["count"].to_i
    end

    write_to_cache_maybe_stale("players_talents", h, cache_key)
    return h
  end

  def write_to_cache_maybe_stale(tbl, hash, cache_key)
    stale_count = get_stale_count tbl
    ttl = (stale_count == 0) ? 1.hour : 10.minutes
    Rails.cache.write(cache_key, hash, :expires_in => ttl)
  end

  def get_stale_count tbl
    rows = get_rows("SELECT COUNT(*) AS count FROM #{tbl} WHERE stale=TRUE")
    rows.each do |row|
      return row["count"].to_i
    end
  end

  def get_stat_counts
    cache_key = "stat_counts_#{@class_id}_#{@spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    h = Hash.new
    cols = get_stat_cols
    return h if cols.empty?
    rows = get_rows("SELECT #{cols} FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_stats ON players.id=players_stats.player_id WHERE players.class_id=#{@class_id} AND players.spec_id=#{@spec_id}")
    rows.each do |row|
      h.merge!(parse_stats_row row)
    end

    remove_unused_stats h

    Rails.cache.write(cache_key, h)
    return h
  end

end
