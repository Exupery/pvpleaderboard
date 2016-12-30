class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  @@BRACKETS = Brackets.list
  @@REGIONS = Regions.list

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

  def get_bracket_fullname(bracket, region)
    return "All #{get_title_region region}Leaderboards" if bracket.nil?
    return (get_title_region region) + (bracket.downcase.eql?("rbg") ? "Rated Battlegrounds" : bracket)
  end

  def get_region
    region = params[:region]
    if region
      region.upcase!
      region = nil unless @@REGIONS.include?(region)
    end

    return region
  end

  def get_title_region region
    return region.nil? ? "" : "#{region} "
  end

end
