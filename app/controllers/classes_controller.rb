class ClassesController < ApplicationController
  include Utils
  protect_from_forgery with: :exception

  def select_class
    @title = "Class / Spec Selection"
    @description = "WoW PvP leaderboard talents by class and spec"

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

    @class_and_spec = "#{spec[:name]} #{clazz[:name]}"
    @title = @class_and_spec
    @description = "World of Warcraft PvP leaderboard talents for #{@class_and_spec}"
    @heading = @class_and_spec

    @class_id = clazz[:id]
    @spec_id = spec[:id]

    @talent_counts = get_talent_counts

    @total = total_player_count(@class_id, @spec_id)
  end

  private

  def get_talent_counts
    cache_key = "talent_counts_#{@class_id}_#{@spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    region_clause = "AND leaderboards.region='US'" ## TODO ADD MULTIREGION SUPPORT
    rows = ActiveRecord::Base.connection.execute("SELECT talents.id AS talent, COUNT(*) AS count FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_talents ON players.id=players_talents.player_id JOIN talents ON players_talents.talent_id=talents.id WHERE players.class_id=#{@class_id} AND players.spec_id=#{@spec_id} #{region_clause} GROUP BY talent")
    rows.each do |row|
      h[row["talent"]] = row["count"].to_i
    end

    Rails.cache.write(cache_key, h)
    return h
  end

end
