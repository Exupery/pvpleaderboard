class FilterController < ApplicationController
  protect_from_forgery with: :exception

  def filter
    @title = "Filter"
    @description = "WoW PvP leaderboard Talents, Glyphs, and Stats"
    puts params ## TODO DELME
  end
end
