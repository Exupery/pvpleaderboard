class FilterController < ApplicationController
  include Utils
  protect_from_forgery with: :exception

  def filter
    @title = "Filter"
    @description = "WoW PvP leaderboard Talents, Glyphs, and Stats"
  end

  def results
    @title = "Filter Results"
    @description = "WoW PvP leaderboard Talents, Glyphs, and Stats Filter Results"

    player_ids = find_player_ids
    return nil if player_ids.empty?
    puts player_ids.length  ## TODO DELME
    @selected = get_selected
    puts @selected  ## TODO DELME
  end

  private

  def find_player_ids
    ids = Array.new
    puts params ## TODO DELME

    # rows = ActiveRecord::Base.connection.execute("SELECT id FROM players LIMIT 5")
    # rows.each do |row|
    #   ids.push(row["id"])
    # end
    ids.push(0) ## TODO DELME

    return ids
  end

  def get_selected
    h = Hash.new

    filters = [:class, :spec, :leaderboards, :factions, :"cr-bracket", :"current-rating", :"arena-achievements", :"rbg-achievements", :races, :hks]

    filters.each do |filter|
      h[filter] = urlify params[filter]
    end

    return h
  end
end
