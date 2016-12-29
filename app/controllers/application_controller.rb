class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  @@BRACKETS = Brackets.list

  def index
    expires_in 1.week, public: true
    @description = "View and filter arena and RBG leaderboards. See which talents top World of Warcraft PvPers are selecting."
  end

  def get_bracket
    bracket = params[:bracket] || params[:leaderboard]
    if bracket
      bracket.downcase!
      bracket = nil unless @@BRACKETS.include?(bracket)
    end

    return bracket
  end

  def get_title_bracket bracket
    return bracket.eql?("rbg") ? "RBG" : bracket
  end

  def get_bracket_fullname bracket
    return "All Leaderboards" if bracket.nil?
    return bracket.downcase.eql?("rbg") ? "Rated Battlegrounds" : bracket
  end

end
