module Utils extend ActiveSupport::Concern

  @@stats = ["strength", "agility", "intellect", "stamina", "critical_strike", "haste", "mastery", "versatility", "leech", "dodge", "parry"]
  @@stat_cols = nil

  @@normal_slots = ["head", "neck", "shoulder", "back", "chest", "wrist", "hands", "waist", "legs", "feet", "mainhand", "offhand"]
  @@two_slots = ["finger1", "finger2", "trinket1", "trinket2"]

 	def stats
		return @@stats
  end

  def get_stat_cols
    return @@stat_cols unless @@stat_cols.nil?

    cols = ""
		@@stats.each do |stat|
			cols += "," if !cols.empty?
			cols += "MIN(#{stat}) AS min_#{stat}, AVG(#{stat}) AS avg_#{stat}, MAX(#{stat}) AS max_#{stat}"
    end
    @@stat_cols = cols

    return @@stat_cols
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

  # Any given spec uses only one of Intellect, Agility, or Strength
  # Remove the two that are not highest from the provided hash
  def remove_unused_stats hash
    avg_agility = hash["agility"][:avg]
    avg_intellect = hash["intellect"][:avg]
    avg_strength = hash["strength"][:avg]

    if (avg_agility > avg_intellect && avg_agility > avg_strength)
      hash.delete("intellect")
      hash.delete("strength")
    elsif (avg_intellect > avg_agility && avg_intellect > avg_strength)
      hash.delete("agility")
      hash.delete("strength")
    elsif (avg_strength > avg_agility && avg_strength > avg_intellect)
      hash.delete("agility")
      hash.delete("intellect")
    end
  end

  def get_slots
    return @@normal_slots + @@two_slots
  end

  def get_most_equipped_gear_by_spec(class_id, spec_id)
    cache_key = "gear_counts_#{class_id}_#{spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    gear = get_most_equipped_gear(class_id, spec_id, nil)

    Rails.cache.write(cache_key, gear)
    return gear
  end

  def get_most_equipped_gear_by_player_ids ids
    return get_most_equipped_gear(nil, nil, ids)
  end

	def slugify txt
		return nil if txt.nil?
		return txt.downcase.gsub(/[\s\-]/, "_")
	end

	def urlify txt
		return nil if txt.nil?
		return txt.downcase.gsub(/[_\s]/, "-")
  end

  def whereify set
    return set.to_a.join(",")
  end

	def total_player_count(class_id, spec_id)
    cache_key = "total_player_count_#{class_id}_#{spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

		total = 0

		rows = ActiveRecord::Base.connection.execute("SELECT COUNT(*) AS total FROM leaderboards JOIN players ON leaderboards.player_id=players.id WHERE players.class_id=#{class_id} AND players.spec_id=#{spec_id}")
		rows.each do |row|
      total = row["total"].to_i
    end

    Rails.cache.write(cache_key, total)
    return total
	end

  def last_players_update
    last = nil

    rows = ActiveRecord::Base.connection.execute("SELECT last_update FROM metadata WHERE key='update_time'")
    rows.each do |row|
      last = DateTime.parse(row["last_update"]) if row["last_update"]
    end

    return last
  end

  private

  def get_most_equipped_gear(class_id, spec_id, ids)
    h = Hash.new
    gear = Hash.new
    rows = ActiveRecord::Base.connection.execute(gear_sql(class_id, spec_id, ids))
    rows.each do |row|
      get_slots.each do |slot|
        h[slot] = row[slot].to_i
      end
    end
    names = get_gear_names h.values
    h.each do |slot, id|
      gear[slot] = {:id => id, :name => names[id]}
    end

    return gear
  end

  def gear_sql(class_id, spec_id, ids)
    sql = ""
    where = ids ? "players.id IN (#{whereify(ids)})" : "players.class_id=#{class_id} AND players.spec_id=#{spec_id}"
    @@normal_slots.each do |slot|
      sql += "(SELECT #{slot} FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_items ON players_items.player_id=players.id WHERE #{where} GROUP BY #{slot} ORDER BY COUNT(*) DESC LIMIT 1),"
    end
    sql += two_slot_sql("finger", where)
    sql += ","
    sql += two_slot_sql("trinket", where)

    return "SELECT #{sql}"
  end

  def two_slot_sql(slot, where)
    sql = ""
    from = "FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_items ON players_items.player_id=players.id WHERE #{where}"
    base = "(SELECT #{slot} AS #{slot}%s FROM (SELECT players_items.player_id, #{slot}1 AS #{slot} #{from} UNION ALL SELECT players_items.player_id, #{slot}2 AS #{slot} #{from}) AS tbl GROUP BY #{slot} ORDER BY COUNT(*) DESC LIMIT 1 %s)"
    sql += base % ["1", ""]
    sql += ",#{base % ["2", "OFFSET 1"]}"

    return sql
  end

  def get_gear_names ids
    h = Hash.new
    rows = ActiveRecord::Base.connection.execute("SELECT id, name FROM items WHERE id IN (#{whereify(ids)})")
    rows.each do |row|
      h[row["id"].to_i] = row["name"]
    end

    return h
  end

end