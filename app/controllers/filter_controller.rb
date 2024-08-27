require "set"

class FilterController < ApplicationController
  include Utils, FilterUtils
  protect_from_forgery with: :exception
  before_action :get_selected

  @@NUM_TOP_PLAYERS = ENV.fetch("TOP_PLAYERS_PER_BRACKET", 6).to_i * 8

  def filter
    @title = "Filter"
    @description = "World of Warcraft PvP leaderboard filter"
  end

  def results
    @title = "Filter Results"
    @description = "World of Warcraft PvP leaderboard filter results"

    redirect_to "/pvp/filter" if (@selected[:class].nil? || @selected[:spec].nil?)

    player_ids = find_player_ids
    @total = player_ids.length
    return nil if player_ids.empty?

    clazz = Classes.list[slugify @selected[:class]]
    @class_id = clazz[:id] if clazz
    @class_name = clazz[:name] if clazz
    spec = get_spec_from_selected
    @spec_id = spec[:id] if spec
    @spec_name = spec[:name] if spec

    @whereified_ids = whereify(player_ids)
    @class_talent_counts = get_class_talent_counts
    @spec_talent_counts = get_spec_talent_counts
    @hero_talent_counts = get_hero_talent_counts
    @pvp_talent_counts = get_pvp_talent_counts
    @stat_counts = get_stat_counts
    @gear = get_most_equipped_gear_by_player_ids player_ids

    @top_players = get_top_players
    @players_title = "The #{@top_players.length} highest rated players matching the filter"
  end

  private

  def get_top_players
    players = Array.new

    rows = get_rows("SELECT ranking, rating, season_wins AS wins, season_losses AS losses, players.name AS name, factions.name AS faction, races.name AS race, players.gender AS gender, realms.slug AS realm_slug, realms.name AS realm, realms.region AS region, leaderboards.bracket AS bracket FROM leaderboards LEFT JOIN players ON leaderboards.player_id=players.id LEFT JOIN factions ON players.faction_id=factions.id LEFT JOIN races ON players.race_id=races.id LEFT JOIN realms ON players.realm_id=realms.id WHERE players.id IN (#{@whereified_ids}) #{bracket_clause} ORDER BY ranking ASC LIMIT #{@@NUM_TOP_PLAYERS}")

    rows.each do |row|
      next unless matchSpec(row["bracket"])
      players << Player.new(row)
    end

    return players
  end

  def matchSpec bracket
      return true if @spec_id.nil?

      return true unless bracket.start_with?("solo")

      return bracket == "solo_#{@spec_id}"
  end

  def get_class_talent_counts
    return get_talent_counts "players.class_id=#{@class_id} AND (talents.spec_id=0 OR talents.spec_id=#{@spec_id}) AND talents.cat='CLASS'"
  end

  def get_spec_talent_counts
    return get_talent_counts "talents.spec_id=#{@spec_id} AND talents.cat='SPEC'"
  end

  def get_talent_counts where
    h = Hash.new

    rows = get_rows("SELECT talents.id AS talent, COUNT(*) AS count FROM players JOIN players_talents ON players.id=players_talents.player_id JOIN talents ON players_talents.talent_id=talents.id WHERE #{where} AND players.id IN (#{@whereified_ids}) GROUP BY talent")
    rows.each do |row|
      h[row["talent"]] = row["count"].to_i
    end

    return h
  end

  def get_pvp_talent_counts
    h = Hash.new

    rows = get_rows("SELECT pvp_talents.id AS pvp_talent, COUNT(*) AS count FROM players JOIN players_pvp_talents ON players.id=players_pvp_talents.player_id JOIN pvp_talents ON players_pvp_talents.pvp_talent_id=pvp_talents.id WHERE players.id IN (#{@whereified_ids}) GROUP BY pvp_talent ORDER BY count DESC")
    rows.each do |row|
      h[row["pvp_talent"]] = row["count"].to_i
    end

    return h
  end

  def get_hero_talent_counts
    h = Hash.new

    rows = get_rows("SELECT talents.id AS hero_talent, COUNT(DISTINCT(players.id)) AS count FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_talents ON players.id=players_talents.player_id JOIN talents ON players_talents.talent_id=talents.id WHERE players.id IN (#{@whereified_ids}) AND cat='HERO' AND #{@spec_id}=ANY(hero_specs) GROUP BY hero_talent ORDER BY count DESC")
    rows.each do |row|
      h[row["hero_talent"]] = row["count"].to_i
    end

    return h
  end

  def get_stat_counts
    h = Hash.new
    cols = get_stat_cols
    return h if cols.empty?
    rows = get_rows("SELECT #{cols} FROM players JOIN players_stats ON players.id=players_stats.player_id WHERE players.id IN (#{@whereified_ids})")
    rows.each do |row|
      h.merge!(parse_stats_row row)
    end

    remove_unused_stats h

    return h
  end

  def find_player_ids
    ids = Array.new

    where = (@selected[:class] && @selected[:spec]) ? create_where_clause : ""
    return ids if where.empty?

    rows = get_rows("SELECT DISTINCT(leaderboards.player_id) FROM players_talents JOIN leaderboards ON players_talents.player_id=leaderboards.player_id JOIN players ON players.id=leaderboards.player_id WHERE #{where} #{bracket_clause} #{region_clause}")
    rows.each do |row|
      ids.push(row["player_id"])
    end

    return ids if ids.empty?

    ids = narrow_by_achievements ids if (@selected[:"arena-achievements"] || @selected[:"rbg-achievements"])
    ids = narrow_by_cr ids if @selected[:"current-rating"]

    return ids
  end

  def region_clause
    if @selected[:regions].nil?
      return ""
    else
      regions = Array.new
      Regions.list.each do |region|
        regions.push("'#{region}'") if @selected[:regions].upcase.include? region
      end
      return "AND leaderboards.region IN (#{regions.join(",")})"
    end
  end

  def bracket_clause
    if @selected[:leaderboards].nil?
      return ""
    else
      brackets = Array.new
      @@BRACKETS.each do |bracket|
        brackets.push("'#{bracket}'") if @selected[:leaderboards].include? bracket
      end
      spec = get_spec_from_selected
      unless spec.nil?
        solo_bracket = "solo_#{spec[:id]}"
        brackets.push("'#{solo_bracket}'") if @selected[:leaderboards].include? "solo"
      end
      return "AND leaderboards.bracket IN (#{brackets.join(",")})"
    end
  end

  def get_selected
    @selected = Hash.new

    filters = [:class, :spec, :leaderboards, :factions, :"cr-bracket", :"current-rating", :"arena-achievements", :"rbg-achievements", :races, :regions, :"active-since"]

    filters.each do |filter|
      @selected[filter] = dashify params[filter]
    end
  end

  def get_spec_from_selected
    return Specs.slugs["#{slugify @selected[:class]}_#{slugify @selected[:spec]}"]
  end
end
