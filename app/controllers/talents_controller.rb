class TalentsController < ApplicationController
	protect_from_forgery with: :exception

	def talents_by_class
		@title = "Talents"
		@description = "WoW PvP leaderboard talent choices"
		@classes = Classes.list
	end
end
