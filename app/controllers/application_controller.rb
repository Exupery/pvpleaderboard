class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  @@BRACKETS = ["2v2", "3v3", "5v5", "rbg"]

  def index
  	@description = "See which talents, glyphs, stats, and gear top World of Warcraft PvPers are selecting"
  end

  def get_bracket
    bracket = params[:bracket] || params[:leaderboard]
    if bracket
      bracket.downcase!
      bracket = nil unless @@BRACKETS.include?(bracket)
    end

    return bracket
  end

end
