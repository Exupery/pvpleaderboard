class LeaderboardsController < ApplicationController

  def show
    bracket = get_bracket
    title_bracket = bracket.eql?("rbg") ? "RBG" : bracket
    if title_bracket
      @title = "#{title_bracket} Leaderboard"
      @description = "World of Warcraft #{title_bracket} PvP leaderboard"
    else
      @title = "Leaderboard Selection"
      @description = "World of Warcraft PvP leaderboards"
    end

    @active_bracket = bracket.eql?("rbg") ? "Rated Battleground" : bracket
  end

end
