class GlyphsController < ApplicationController
	include Utils
	protect_from_forgery with: :exception

	def glyphs_by_class
		@title = "Glyphs"
		@description = "WoW PvP leaderboard glyph choices"
	end
end
