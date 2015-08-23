require "set"

class FilterController < ApplicationController
  include Utils
  protect_from_forgery with: :exception
  before_action :get_selected

  @@brackets = ["2v2", "3v3", "5v5", "rbg"]

  def filter
    @title = "Filter"
    @description = "World of Warcraft PvP leaderboard Talents, Glyphs, Stats, and Gear"
  end

  def results
    @title = "Filter Results"
    @description = "World of Warcraft PvP leaderboard Talents, Glyphs, Stats, and Gear Filter Results"

    redirect_to "/filter" if (@selected[:class].nil? || @selected[:spec].nil?)

    player_ids = find_player_ids
    @total = player_ids.length
    return nil if player_ids.empty?

    clazz = Classes.list[slugify @selected[:class]]
    @class_id = clazz[:id] if clazz

    ids = player_ids.to_a.join(",")

    @talent_counts = get_talent_counts ids
    @major_glyph_counts = get_glyph_counts(ids, Glyphs.MAJOR_ID)
    @minor_glyph_counts = get_glyph_counts(ids, Glyphs.MINOR_ID)
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

  def get_glyph_counts(ids, type_id)
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT glyphs.id AS glyph, COUNT(*) AS count FROM players JOIN players_glyphs ON players.id=players_glyphs.player_id JOIN glyphs ON players_glyphs.glyph_id=glyphs.id WHERE players.id IN (#{ids}) AND glyphs.type_id=#{type_id} GROUP BY glyph")
    rows.each do |row|
      h[row["glyph"]] = row["count"].to_i
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

    where = create_where_clause
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

  def create_where_clause
    clazz = Classes.list[slugify @selected[:class]]
    where = "players.class_id=#{clazz[:id]}" if clazz

    spec = Specs.slugs[slugify "#{@selected[:class]}_#{@selected[:spec]}"]
    where += " AND players.spec_id=#{spec[:id]}" if spec

    return "" if (clazz.nil? || spec.nil?)

    where += factions_clause if @selected[:factions]
    where += cr_clause if (@selected[:"cr-bracket"] && @selected[:"current-rating"])
    where += races_clause if @selected[:races]
    if (@selected[:hks] && @selected[:hks].to_i > 0)
      where += " AND players.honorable_kills > #{@selected[:hks].to_i}"
    end

    return where
  end

  def factions_clause
    ## omit clause if both factions are selected
    return "" if @selected[:factions].downcase.include?("alliance") && @selected[:factions].downcase.include?("horde")

    faction = Factions.list[slugify @selected[:factions]]
    return faction ? " AND players.faction_id=#{faction[:id]}" : ""
  end

  def races_clause
    a = Array.new

    # Pandas (and potential future races) can be either faction (and thus mutiple slugs/ids)
    # so iterating through the races and using include on the param string instead of tokenizing
    Races.list.each do |slug, hash|
      a.push(hash[:id]) if @selected[:races].include?(urlify hash[:name])
    end

    return a.empty? ? "" : " AND players.race_id IN (#{a.join(",")})"
  end

  def cr_clause
    bracket = @selected[:"cr-bracket"].downcase
    cr = @selected[:"current-rating"].to_i
    return "" if (!@@brackets.include?(bracket) || cr <= 0)

    return " AND cr_bracket.rating > #{cr}"
  end

  def cr_join leaderboard
    bracket = @selected[:"cr-bracket"].downcase
    if @@brackets.include?(bracket)
      return " JOIN bracket_#{bracket} AS cr_bracket ON #{leaderboard}.player_id=cr_bracket.player_id"
    end

    return ""
  end

  def get_bracket_tables
    tables = Array.new

    if !@selected[:leaderboards].nil?
      @@brackets.each do |bracket|
        tables.push("bracket_#{bracket}") if @selected[:leaderboards].include? bracket
      end
    end

    tables.push("player_ids_all_brackets") if tables.empty?

    return tables
  end

  def narrow_by_achievements ids
    id_array = ids.to_a

    arena_narrowed = Set.new
    if @selected[:"arena-achievements"]
      arena_achievements = arena_achievement_ids @selected[:"arena-achievements"]
      rows = ActiveRecord::Base.connection.execute("SELECT player_id FROM players_achievements WHERE player_id IN (#{id_array.join(",")}) AND achievement_id IN (#{arena_achievements.join(",")})")
      rows.each do |row|
        arena_narrowed.add(row["player_id"])
      end

      return arena_narrowed unless @selected[:"rbg-achievements"]
    end

    rbg_narrowed = Set.new
    if @selected[:"rbg-achievements"]
      rbg_achievements = rbg_achievement_id_pairs
      if rbg_achievements.length == 2
        rows = ActiveRecord::Base.connection.execute("SELECT player_id FROM players_achievements WHERE player_id IN (#{id_array.join(",")}) AND (achievement_id IN (#{rbg_achievements[0].join(",")}) OR achievement_id IN (#{rbg_achievements[1].join(",")}))")
        rows.each do |row|
          rbg_narrowed.add(row["player_id"])
        end
      end

      return @selected[:"arena-achievements"] ? (arena_narrowed & rbg_narrowed) : rbg_narrowed
    end

    return Set.new
  end

  def rbg_achievement_id_pairs
    rbg_alliance = Array.new
    rbg_horde = Array.new
    ctr = 0
    @selected[:"rbg-achievements"].split("-").each do |achiev|
      if ctr.even?
        rbg_alliance.push(achiev)
      else
        rbg_horde.push(achiev)
      end
      ctr += 1
    end
    return [rbg_alliance, rbg_horde]
  end

  def arena_achievement_ids achievements
    ids = Array.new
    return ids if (achievements.nil? || achievements.empty?)

    achievements.split("-").each do |achiev|
      i = achiev.to_i
      ids.push i if i > 0
    end

    return ids
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
