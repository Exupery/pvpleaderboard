module Utils extend ActiveSupport::Concern

	@@stats = ["strength", "agility", "intellect", "stamina", "spirit", "critical_strike", "haste", "attack_power", "mastery", "multistrike", "versatility", "leech", "dodge", "parry"]

  @@normal_slots = ["head", "neck", "shoulder", "back", "chest", "wrist", "hands", "waist", "legs", "feet", "mainhand", "offhand"]

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

  def get_slots
    return @@normal_slots + ["finger1", "finger2", "trinket1", "trinket2"]
  end

  def gear_sql(class_id, spec_id)
    sql = ""
    @@normal_slots.each do |slot|
      sql += "(SELECT #{slot} FROM player_ids_all_brackets JOIN players ON player_ids_all_brackets.player_id=players.id JOIN players_items ON players_items.player_id=players.id WHERE players.class_id=#{class_id} AND players.spec_id=#{spec_id} GROUP BY #{slot} ORDER BY COUNT(*) DESC LIMIT 1),"
    end

    sql += two_slot_sql("finger", class_id, spec_id)+","
    sql += two_slot_sql("trinket", class_id, spec_id)

    return "SELECT #{sql}"
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

  def last_players_update
    last = nil

    rows = ActiveRecord::Base.connection.execute("SELECT MAX(last_update) FROM players")
    rows.each do |row|
      last = DateTime.parse(row["max"]) if row["max"]
    end

    return last.nil? ? "UNKNOWN" : last.strftime("%d %b %Y %H:%M:%S")
  end

  private

  def two_slot_sql(slot, class_id, spec_id)
    sql = ""
    from = "FROM player_ids_all_brackets JOIN players ON player_ids_all_brackets.player_id=players.id JOIN players_items ON players_items.player_id=players.id WHERE players.class_id=#{class_id} AND players.spec_id=#{spec_id}"
    base = "(SELECT #{slot} AS #{slot}%s FROM (SELECT players_items.player_id, #{slot}1 AS #{slot} #{from} UNION ALL SELECT players_items.player_id, #{slot}2 AS #{slot} #{from}) AS tbl GROUP BY #{slot} ORDER BY COUNT(*) DESC LIMIT 1 %s)"

    sql += base % ["1", ""]
    sql += ",#{base % ["2", "OFFSET 1"]}"

    return sql
  end
end