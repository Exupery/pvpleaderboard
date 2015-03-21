class TalentsController < ApplicationController
	include Utils
	protect_from_forgery with: :exception

	def talents_by_class
		@title = "Talents"
		@description = "WoW PvP leaderboard talent choices"
		@heading = "Select a Class"

		classes = Classes.list
		@class_slug = slugify params[:class]
		if @class_slug
			if !classes.key?(@class_slug)
				redirect_to "/talents"
				return nil
			end
			clazz = classes[@class_slug]["name"]
			@title = "#{@clazz} Talents"
			@description = @title
			@heading = "Select a Specialization"
		end

		@spec_slug = slugify params[:spec]
		if @spec_slug
			spec_slugs = Specs.slugs
			full_slug = "#{@class_slug}_#{@spec_slug}"
			if !spec_slugs.key?(full_slug)
				redirect_to "/talents/#{@class_slug}"
				return nil
			end
			@title = "#{spec_slugs[full_slug]["name"]} #{clazz} Talents"
			@description = @title
			@heading = @title

			class_id = classes[@class_slug]["id"]
			spec_id = spec_slugs[full_slug]["id"]
			@counts = talent_counts(class_id, spec_id)
			@total = total_count(class_id, spec_id)
			@class_talents = Talents.get_talents class_id
		end
	end

	private

	def talent_counts(class_id, spec_id)
		h = Hash.new

		rows = ActiveRecord::Base.connection.execute("SELECT talents.id AS talent, COUNT(*) AS count FROM player_ids_all_brackets JOIN players ON player_ids_all_brackets.player_id=players.id JOIN players_talents ON players.id=players_talents.player_id JOIN talents ON players_talents.talent_id=talents.id WHERE players.class_id=#{class_id} AND players.spec_id=#{spec_id} GROUP BY talent")
    rows.each do |row|
      h[row["talent"]] = row["count"].to_i
    end

		return h
	end

	def total_count(class_id, spec_id)
		total = 0

		rows = ActiveRecord::Base.connection.execute("SELECT COUNT(*) AS total FROM player_ids_all_brackets JOIN players ON player_ids_all_brackets.player_id=players.id WHERE players.class_id=#{class_id} AND players.spec_id=#{spec_id}")
		rows.each do |row|
      total = row["total"].to_i
    end

    return total
	end

end
