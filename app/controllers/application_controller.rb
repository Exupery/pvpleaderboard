class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_format

  @@BRACKETS = Brackets.list
  @@BRACKETS_WITH_SOLO = Brackets.with_solo
  @@REGIONS = Regions.list

  def set_format
    request.format = "html"
  end

  def index
    expires_in 1.week, public: true
    @description = "View and filter arena and RBG leaderboards. See which talents, stats, and gear top World of Warcraft PvPers are selecting."
  end

  def get_bracket
    bracket = params[:bracket] || params[:leaderboard]
    if bracket
      bracket.downcase!
      bracket = nil unless @@BRACKETS_WITH_SOLO.include?(bracket)
    end

    return bracket
  end

  def get_title_bracket bracket
    return "Solo Shuffle" if bracket.eql?("solo")
    return "RBG" if bracket.eql?("rbg")
    return bracket
  end

  def get_bracket_fullname(bracket, region)
    return "All #{get_title_region region}Leaderboards" if bracket.nil?
    return (get_title_region region) + (bracket.downcase.eql?("rbg") ? "Rated Battlegrounds" : get_title_bracket(bracket))
  end

  def get_player_region
    return get_region Regions.with_asia
  end

  def get_leaderboard_region
    return get_region @@REGIONS
  end

  def get_title_region region
    return region.nil? ? "" : "#{region} "
  end

  private

  def get_region regions
    region = params[:region]
    if region
      region.upcase!
      region = nil unless regions.include?(region)
    end

    return region
  end

end
