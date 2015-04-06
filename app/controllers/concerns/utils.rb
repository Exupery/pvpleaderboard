module Utils extend ActiveSupport::Concern

	@@stats = ["strength", "agility", "intellect", "stamina", "spirit", "critical_strike", "haste", "attack_power", "mastery", "multistrike", "versatility", "leech", "dodge", "parry"]

	def stats
		return @@stats
	end

	def get_stat_cols
		cols = ""
		@@stats.each do |stat|
			cols += "," if !cols.empty?
			cols += "MIN(#{stat}) AS min_#{stat}, AVG(#{stat}) AS avg_#{stat}, MAX(#{stat}) AS max_#{stat}"
		end

		return cols
	end

	def parse_stats_row row
		h = Hash.new

		@@stats.each do |stat|
  		h[stat] = Hash.new
  		h[stat][:min] = row["min_#{stat}"].to_i
  		h[stat][:avg] = row["avg_#{stat}"].to_i
  		h[stat][:max] = row["max_#{stat}"].to_i
  	end

		return h
	end

	def slugify txt
		return nil if txt.nil?
		return txt.downcase.gsub(/[\s\-]/, "_")
	end

	def urlify txt
		return nil if txt.nil?
		return txt.downcase.gsub(/[_\s]/, "-")
	end

	def total_player_count(class_id, spec_id)
		total = 0

		rows = ActiveRecord::Base.connection.execute("SELECT COUNT(*) AS total FROM player_ids_all_brackets JOIN players ON player_ids_all_brackets.player_id=players.id WHERE players.class_id=#{class_id} AND players.spec_id=#{spec_id}")
		rows.each do |row|
      total = row["total"].to_i
    end

    return total
	end
end