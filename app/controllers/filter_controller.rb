require "set"

class FilterController < ApplicationController
  include Utils, FilterUtils
  protect_from_forgery with: :exception
  before_action :get_selected

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
    spec = Specs.slugs["#{slugify @selected[:class]}_#{slugify @selected[:spec]}"]
    @spec_id = spec[:id]

    @talent_counts = get_talent_counts player_ids
    @stat_counts = get_stat_counts player_ids
    @gear = get_most_equipped_gear_by_player_ids player_ids
  end

  private

  def get_talent_counts ids
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT talents.id AS talent, COUNT(*) AS count FROM players JOIN players_talents ON players.id=players_talents.player_id JOIN talents ON players_talents.talent_id=talents.id WHERE players.id IN (#{whereify(ids)}) GROUP BY talent")
    rows.each do |row|
      h[row["talent"]] = row["count"].to_i
    end

    return h
  end

  def get_stat_counts ids
    h = Hash.new
    cols = get_stat_cols
    return h if cols.empty?
    rows = ActiveRecord::Base.connection.execute("SELECT #{cols} FROM players JOIN players_stats ON players.id=players_stats.player_id WHERE players.id IN (#{whereify(ids)})")
    rows.each do |row|
      h.merge!(parse_stats_row row)
    end

    return h
  end

  def find_player_ids
    ids = Set.new

    where = (@selected[:class] && @selected[:spec]) ? create_where_clause : ""
    return ids if where.empty?

    rows = ActiveRecord::Base.connection.execute("SELECT leaderboards.player_id FROM leaderboards JOIN players ON players.id=leaderboards.player_id WHERE #{where} #{bracket_clause} #{region_clause}")
    rows.each do |row|
      ids.add(row["player_id"])
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
      return "AND leaderboards.bracket IN (#{brackets.join(",")})"
    end
  end

  def get_selected
    @selected = Hash.new

    filters = [:class, :spec, :leaderboards, :factions, :"cr-bracket", :"current-rating", :"arena-achievements", :"rbg-achievements", :races, :hks, :regions]

    filters.each do |filter|
      @selected[filter] = urlify params[filter]
    end
  end

  def sanitize obj
    return ActiveRecord::Base::sanitize obj
  end
end
