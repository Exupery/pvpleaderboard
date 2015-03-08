class TalentsController < ApplicationController
	include Utils
	protect_from_forgery with: :exception

	def talents_by_class
		@title = "Talents"
		@description = "WoW PvP leaderboard talent choices"

		@heading = "Select a Class"
		@classes = Classes.list
		@class_slug = slugify params[:class]
		if @class_slug
			class_slugs = @classes.invert
			if !class_slugs.key?(@class_slug)
				redirect_to "/talents"
				return nil
			end
			@clazz = class_slugs[@class_slug]
			@title = "#{@clazz} Talents"
			@heading = "Select a Specialization"
		end

		@specs = Specs.list
		@spec_slug = slugify params[:spec]
		if @spec_slug
			spec_slugs = Specs.slugs
			full_slug = "#{@class_slug}_#{@spec_slug}"
			if !spec_slugs.key?(full_slug)
				redirect_to "/talents/#{@class_slug}"
				return nil
			end
			@spec = spec_slugs[full_slug]
			@title = "#{@spec} #{@clazz} Talents"
			@heading = @title
		end
	end

end
