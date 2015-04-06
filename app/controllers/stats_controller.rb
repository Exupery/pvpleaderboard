class StatsController < ApplicationController
	include Utils
	protect_from_forgery with: :exception

	def stats_by_class
		@title = "Stats"
		@description = "WoW PvP leaderboard stat choices"
		@heading = "Select a Class"

		classes = Classes.list
		@class_slug = slugify params[:class]
		if @class_slug
			if !classes.key?(@class_slug)
				redirect_to "/stats"
				return nil
			end
			clazz = classes[@class_slug][:name]
			@title = "#{@clazz} Stats"
			@description = @title
			@heading = "Select a Specialization"
		end

		@spec_slug = slugify params[:spec]
		if @spec_slug
			spec_slugs = Specs.slugs
			full_slug = "#{@class_slug}_#{@spec_slug}"
			if !spec_slugs.key?(full_slug)
				redirect_to "/stats/#{@class_slug}"
				return nil
			end
			@title = "#{spec_slugs[full_slug][:name]} #{clazz} Stats"
			@description = @title
			@heading = @title

			class_id = classes[@class_slug][:id]
			spec_id = spec_slugs[full_slug][:id]

			@stat_counts = get_stat_counts(class_id, spec_id)
		end
	end

	private

	def get_stat_counts(class_id, spec_id)
		h = Hash.new
		cols = get_stat_cols
		return h if cols.empty?

		rows = ActiveRecord::Base.connection.execute("SELECT #{cols} FROM player_ids_all_brackets JOIN players ON player_ids_all_brackets.player_id=players.id JOIN players_stats ON players.id=players_stats.player_id WHERE players.class_id=#{class_id} AND players.spec_id=#{spec_id}")
    rows.each do |row|
    	h.merge!(parse_stats_row row)
    end

		return h
	end

end
