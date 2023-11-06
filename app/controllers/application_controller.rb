class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_format, :check_params

  @@BRACKETS = Brackets.list
  @@BRACKETS_WITH_SOLO = Brackets.with_solo
  @@REGIONS = Regions.list

  def set_format
    request.format = "html"
  end

  # Getting a large number of SQL injection attack attemps, param
  # sanitization is preventing any of them succeeding but it does
  # cause a large number of 5xxs and eats up resources due to the
  # volume - so just adding this as a simple check early on to
  # fail early with a 403 before spending cycles to fully process
  # the request.
  def check_params
    params.each do | key, param |
      next if param.nil?
      param_lc = param.downcase
      if param_lc.include?("select") && param_lc.include?("from")
        head :forbidden
      end
    end
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

  def get_rows sql
    sanitized = ActiveRecord::Base::sanitize_sql(sql)
    return ActiveRecord::Base.connection.execute(sanitized)
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
