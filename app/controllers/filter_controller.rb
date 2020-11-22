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

    @whereified_ids = whereify(player_ids)
    @talent_counts = get_talent_counts
    @pvp_talent_counts = get_pvp_talent_counts
    @covenant_counts = get_covenant_counts
    @soulbind_counts = get_soulbind_counts
    @conduit_counts = get_conduit_counts
    @stat_counts = get_stat_counts
    @gear = get_most_equipped_gear_by_player_ids player_ids
  end

  private

  def get_talent_counts
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT talents.id AS talent, COUNT(*) AS count FROM players JOIN players_talents ON players.id=players_talents.player_id JOIN talents ON players_talents.talent_id=talents.id WHERE players.id IN (#{@whereified_ids}) GROUP BY talent")
    rows.each do |row|
      h[row["talent"]] = row["count"].to_i
    end

    return h
  end

  def get_pvp_talent_counts
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT pvp_talents.id AS pvp_talent, COUNT(*) AS count FROM players JOIN players_pvp_talents ON players.id=players_pvp_talents.player_id JOIN pvp_talents ON players_pvp_talents.pvp_talent_id=pvp_talents.id WHERE players.id IN (#{@whereified_ids}) GROUP BY pvp_talent ORDER BY count DESC")
    rows.each do |row|
      h[row["pvp_talent"]] = row["count"].to_i
    end

    return h
  end

  def get_covenant_counts
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT covenants.name AS covenant_name, covenants.icon AS covenant_icon, COUNT(*) AS count FROM players JOIN players_covenants ON players.id=players_covenants.player_id JOIN covenants ON players_covenants.covenant_id=covenants.id WHERE players.id IN (#{@whereified_ids}) GROUP BY covenants.name, covenants.icon ORDER BY count DESC")
    rows.each do |row|
      covenant = Covenant.new(row["covenant_name"], row["covenant_icon"])
      h[covenant] = row["count"].to_i
    end

    return h
  end

  def get_soulbind_counts
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT soulbinds.name AS soulbind, COUNT(*) AS count FROM players JOIN players_soulbinds ON players.id=players_soulbinds.player_id JOIN soulbinds ON players_soulbinds.soulbind_id=soulbinds.id WHERE players.id IN (#{@whereified_ids}) GROUP BY soulbind ORDER BY count DESC")
    rows.each do |row|
      h[row["soulbind"]] = row["count"].to_i
    end

    return h
  end

  def get_conduit_counts
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT conduits.name AS conduit, conduits.spell_id AS spell_id, COUNT(*) AS count FROM players JOIN players_conduits ON players.id=players_conduits.player_id JOIN conduits ON players_conduits.conduit_id=conduits.id WHERE players.id IN (#{@whereified_ids}) GROUP BY conduit, spell_id ORDER BY count DESC")
    rows.each do |row|
      conduit = Conduit.new(row["conduit"], row["spell_id"])
      h[conduit] = row["count"].to_i
    end

    return h
  end

  def get_stat_counts
    h = Hash.new
    cols = get_stat_cols
    return h if cols.empty?
    rows = ActiveRecord::Base.connection.execute("SELECT #{cols} FROM players JOIN players_stats ON players.id=players_stats.player_id WHERE players.id IN (#{@whereified_ids})")
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

    rows = ActiveRecord::Base.connection.execute("SELECT DISTINCT(leaderboards.player_id) FROM leaderboards JOIN players ON players.id=leaderboards.player_id WHERE #{where} #{bracket_clause} #{region_clause}")
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
      return "AND leaderboards.bracket IN (#{brackets.join(",")})"
    end
  end

  def get_selected
    @selected = Hash.new

    filters = [:class, :spec, :leaderboards, :factions, :"cr-bracket", :"current-rating", :"arena-achievements", :"rbg-achievements", :races, :regions]

    filters.each do |filter|
      @selected[filter] = dashify params[filter]
    end
  end

  def sanitize obj
    return ActiveRecord::Base::sanitize obj
  end
end
