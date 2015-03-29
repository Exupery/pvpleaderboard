class FilterController < ApplicationController
  protect_from_forgery with: :exception

  def filter
    @title = "Filter"
    @description = "WoW PvP leaderboard Talents, Glyphs, and Stats"
  end

  def results
    @title = "Filter Results"
    @description = "WoW PvP leaderboard Talents, Glyphs, and Stats Filter Results"
    puts params ## TODO DELME
  end
end
