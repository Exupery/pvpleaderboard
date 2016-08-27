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

    ids = player_ids.to_a.join(",")

    @talent_counts = get_talent_counts ids
    @stat_counts = get_stat_counts ids
    @gear = get_most_equipped_gear_by_player_ids ids
  end

  private

  def get_talent_counts ids
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT talents.id AS talent, COUNT(*) AS count FROM players JOIN players_talents ON players.id=players_talents.player_id JOIN talents ON players_talents.talent_id=talents.id WHERE players.id IN (#{ids}) GROUP BY talent")
    rows.each do |row|
      h[row["talent"]] = row["count"].to_i
    end

    return h
  end

  def get_stat_counts ids
    h = Hash.new
    cols = get_stat_cols
    return h if cols.empty?

    rows = ActiveRecord::Base.connection.execute("SELECT #{cols} FROM players JOIN players_stats ON players.id=players_stats.player_id WHERE players.id IN (#{ids})")
    rows.each do |row|
      h.merge!(parse_stats_row row)
    end

    return h
  end

  def find_player_ids
    ids = Set.new

    where = (@selected[:class] && @selected[:spec]) ? create_where_clause : ""
    return ids if where.empty?

    get_bracket_tables.each do |bracket_table|
      current_rating_join = cr_join bracket_table if @selected[:"cr-bracket"]
      rows = ActiveRecord::Base.connection.execute("SELECT #{bracket_table}.player_id FROM #{bracket_table} JOIN players ON players.id=#{bracket_table}.player_id #{current_rating_join} WHERE #{where}")
      rows.each do |row|
        ids.add(row["player_id"])
      end
    end

    return ids if ids.empty?

    ids = narrow_by_achievements ids if (@selected[:"arena-achievements"] || @selected[:"rbg-achievements"])

    return ids
  end

  def cr_join leaderboard
    bracket = @selected[:"cr-bracket"].downcase
    if @@BRACKETS.include?(bracket)
      return " JOIN bracket_#{bracket} AS cr_bracket ON #{leaderboard}.player_id=cr_bracket.player_id"
    end

    return ""
  end

  def get_bracket_tables
    tables = Array.new

    if !@selected[:leaderboards].nil?
      @@BRACKETS.each do |bracket|
        tables.push("bracket_#{bracket}") if @selected[:leaderboards].include? bracket
      end
    end

    tables.push("player_ids_all_brackets") if tables.empty?

    return tables
  end

  def get_selected
    @selected = Hash.new

    filters = [:class, :spec, :leaderboards, :factions, :"cr-bracket", :"current-rating", :"arena-achievements", :"rbg-achievements", :races, :hks]

    filters.each do |filter|
      @selected[filter] = urlify params[filter]
    end
  end

  def sanitize obj
    return ActiveRecord::Base::sanitize obj
  end
end
