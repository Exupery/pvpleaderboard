class GlyphsController < ApplicationController
	include Utils
	protect_from_forgery with: :exception

	def glyphs_by_class
		@title = "Glyphs"
		@description = "WoW PvP leaderboard glyph choices"
		@heading = "Select a Class"

		classes = Classes.list
		@class_slug = slugify params[:class]
		if @class_slug
			if !classes.key?(@class_slug)
				redirect_to "/glyphs"
				return nil
			end
			clazz = classes[@class_slug]["name"]
			@title = "#{@clazz} Glyphs"
			@description = @title
			@heading = "Select a Specialization"
		end

		@spec_slug = slugify params[:spec]
		if @spec_slug
			spec_slugs = Specs.slugs
			full_slug = "#{@class_slug}_#{@spec_slug}"
			if !spec_slugs.key?(full_slug)
				redirect_to "/glyphs/#{@class_slug}"
				return nil
			end
			@title = "#{spec_slugs[full_slug]["name"]} #{clazz} Glyphs"
			@description = @title
			@heading = @title

			class_id = classes[@class_slug]["id"]
			spec_id = spec_slugs[full_slug]["id"]
		end
	end
	
end
