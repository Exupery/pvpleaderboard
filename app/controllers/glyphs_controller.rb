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
			clazz = classes[@class_slug][:name]
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
			@title = "#{spec_slugs[full_slug][:name]} #{clazz} Glyphs"
			@description = @title
			@heading = @title

			@class_id = classes[@class_slug][:id]
			spec_id = spec_slugs[full_slug][:id]

			@major_glyph_counts = glyph_counts(@class_id, spec_id, Glyphs.MAJOR_ID)
			@minor_glyph_counts = glyph_counts(@class_id, spec_id, Glyphs.MINOR_ID)
			@total = total_player_count(@class_id, spec_id)
		end
	end

	private

	def glyph_counts(class_id, spec_id, type_id)
		h = Hash.new

		rows = ActiveRecord::Base.connection.execute("SELECT glyphs.id AS glyph, COUNT(*) AS count FROM player_ids_all_brackets JOIN players ON player_ids_all_brackets.player_id=players.id JOIN players_glyphs ON players.id=players_glyphs.player_id JOIN glyphs ON players_glyphs.glyph_id=glyphs.id WHERE players.class_id=#{class_id} AND players.spec_id=#{spec_id} AND glyphs.type_id=#{type_id} GROUP BY glyph")
    rows.each do |row|
      h[row["glyph"]] = row["count"].to_i
    end

		return h
	end

end
