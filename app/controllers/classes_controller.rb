class ClassesController < ApplicationController
  include Utils
  protect_from_forgery with: :exception

  def select_class
    @title = "Class / Spec Selection"
    @description = "WoW PvP leaderboard Talents, Glyphs, and Stats by class and spec"

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

    class_and_spec = "#{spec[:name]} #{clazz[:name]}"
    @title = class_and_spec
    @description = "WoW PvP leaderboard Talents, Glyphs, and Stats for #{class_and_spec}"
    @heading = class_and_spec

    @class_id = clazz[:id]
    @spec_id = spec[:id]

    @talent_counts = get_talent_counts
    @major_glyph_counts = get_glyph_counts Glyphs.MAJOR_ID
    @minor_glyph_counts = get_glyph_counts Glyphs.MINOR_ID
    @stat_counts = get_stat_counts
    @gear_counts = get_gear_counts
    puts @gear_counts ## TODO DELME

    @total = total_player_count(@class_id, @spec_id)
  end

  private

  def get_talent_counts
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT talents.id AS talent, COUNT(*) AS count FROM player_ids_all_brackets JOIN players ON player_ids_all_brackets.player_id=players.id JOIN players_talents ON players.id=players_talents.player_id JOIN talents ON players_talents.talent_id=talents.id WHERE players.class_id=#{@class_id} AND players.spec_id=#{@spec_id} GROUP BY talent")
    rows.each do |row|
      h[row["talent"]] = row["count"].to_i
    end

    return h
  end

  def get_glyph_counts type_id
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT glyphs.id AS glyph, COUNT(*) AS count FROM player_ids_all_brackets JOIN players ON player_ids_all_brackets.player_id=players.id JOIN players_glyphs ON players.id=players_glyphs.player_id JOIN glyphs ON players_glyphs.glyph_id=glyphs.id WHERE players.class_id=#{@class_id} AND players.spec_id=#{@spec_id} AND glyphs.type_id=#{type_id} GROUP BY glyph")
    rows.each do |row|
      h[row["glyph"]] = row["count"].to_i
    end

    return h
  end

  def get_stat_counts
    h = Hash.new
    cols = get_stat_cols
    return h if cols.empty?

    rows = ActiveRecord::Base.connection.execute("SELECT #{cols} FROM player_ids_all_brackets JOIN players ON player_ids_all_brackets.player_id=players.id JOIN players_stats ON players.id=players_stats.player_id WHERE players.class_id=#{@class_id} AND players.spec_id=#{@spec_id}")
    rows.each do |row|
      h.merge!(parse_stats_row row)
    end

    return h
  end

  def get_gear_counts
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute(gear_sql(@class_id, @spec_id))
    rows.each do |row|
      get_slots.each do |slot|
        h[slot] = row[slot].to_i
      end
    end

    return h
  end

end
