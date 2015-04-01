class FilterController < ApplicationController
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
  end

  private

  def find_player_ids
    ids = Array.new
    puts params ## TODO DELME

    # rows = ActiveRecord::Base.connection.execute("SELECT id FROM players LIMIT 5")
    # rows.each do |row|
    #   ids.push(row["id"])
    # end

    return ids
  end
end
