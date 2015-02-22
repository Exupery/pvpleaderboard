class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def index
  	@title = "WoW PvP Leaderboard"
  	@description = "See which talents, glyphs, and stats top WoW PvPers are selecting"
  end

  def stats
  	@title = "Leaderboard Statistics"
  	@description = "WoW PvP leaderboard statistics"
  end
end
