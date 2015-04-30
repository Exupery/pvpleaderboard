class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def index
  	@title = "Home"
  	@description = "See which talents, glyphs, stats, and gear top World of Warcraft PvPers are selecting"
  end
end
