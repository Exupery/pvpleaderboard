class TalentsController < ApplicationController
	protect_from_forgery with: :exception

	def talents_by_class
		@title = "Talents"
		@description = "WoW PvP leaderboard talent choices"
		@classes = Classes.list
		slug = params[:class] ? params[:class].sub(/-/, "_") : nil
		if slug
			slugs = @classes.invert
			if !slugs.key?(slug)
				redirect_to "/talents"
				return nil
			end
			@title = "#{slugs[slug]} Talents"
		end
	end

end
