require "concurrent"

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
			cols += "MIN(#{stat}) AS min_#{stat}, PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY #{stat}) AS med_#{stat}, MAX(#{stat}) AS max_#{stat}"
    end
    @@stat_cols = cols

    return @@stat_cols
  end

  def parse_stats_row row
    h = Hash.new
    @@stats.each do |stat|
      h[stat] = Hash.new
      h[stat][:min] = [row["min_#{stat}"].to_i, 0].max
      h[stat][:med] = row["med_#{stat}"].to_i
      h[stat][:max] = row["max_#{stat}"].to_i
    end

    return h
  end

  # Any given spec uses only one of Intellect, Agility, or Strength
  # Remove the two that are not highest from the provided hash
  def remove_unused_stats hash
    med_agility = hash["agility"][:med]
    med_intellect = hash["intellect"][:med]
    med_strength = hash["strength"][:med]

    if (med_agility > med_intellect && med_agility > med_strength)
      hash.delete("intellect")
      hash.delete("strength")
    elsif (med_intellect > med_agility && med_intellect > med_strength)
      hash.delete("agility")
      hash.delete("strength")
    elsif (med_strength > med_agility && med_strength > med_intellect)
      hash.delete("agility")
      hash.delete("intellect")
    end
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
	  return txt.downcase.gsub(/[_\s]/, "-").gsub(/'/, "")
  end

  def dashify txt
    return nil if txt.nil?
    return txt.downcase.gsub(/[_]/, "-").gsub(/'/, "")
  end

  def whereify set
    return set.to_a.join(",")
  end

	def total_player_count(class_id, spec_id)
    cache_key = "total_player_count_#{class_id}_#{spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

		total = 0

		sql = ActiveRecord::Base::sanitize_sql("SELECT talents.id, COUNT(DISTINCT(players.id)) AS cnt FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_talents ON players.id=players_talents.player_id JOIN talents ON players_talents.talent_id=talents.id WHERE players.class_id=#{class_id} AND players.spec_id=#{spec_id} AND (talents.spec_id=0 OR talents.spec_id=#{spec_id}) AND talents.cat='CLASS' GROUP BY talents.id ORDER BY cnt DESC LIMIT 1")
    rows = ActiveRecord::Base.connection.execute(sql)
		rows.each do |row|
      total = row["cnt"].to_i
    end

    Rails.cache.write(cache_key, total)
    return total
	end

  def last_players_update
    last = nil

    rows = ActiveRecord::Base.connection.execute("SELECT last_update FROM metadata WHERE key='update_time'")
    rows.each do |row|
      last = DateTime.parse(row["last_update"].to_s) if row["last_update"]
    end

    return last
  end

  private

  def get_most_equipped_gear(class_id, spec_id, ids)
    h = Concurrent::Hash.new()
    threads = Array.new
    gear = Hash.new

    where = ids ? "players.id IN (#{whereify(ids)})" : "players.class_id=#{class_id} AND players.spec_id=#{spec_id}"

    normal_slot_thread = Thread.new {
      @@normal_slots.each do |slot|
        sql = "SELECT #{slot} AS cnt FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_items ON players_items.player_id=players.id WHERE #{where} GROUP BY #{slot} ORDER BY COUNT(*) DESC LIMIT 1"
        result = ActiveRecord::Base.connection.execute(ActiveRecord::Base::sanitize_sql(sql))
        next if result.num_tuples.zero?
        h[slot] = result[0]["cnt"].to_i
      end
    }
    threads.push normal_slot_thread

    fingers_thread = Thread.new {
      find_two_slot_counts("finger", where, h)
    }
    threads.push fingers_thread
    trinkets_thread = Thread.new {
      find_two_slot_counts("trinket", where, h)
    }
    threads.push trinkets_thread

    threads.each do |thread|
      thread.join
    end

    names = get_gear_names h.values
    (@@normal_slots + @@two_slots).each do |slot|
      next unless h.key?(slot)
      id = h[slot]
      gear[slot] = {:id => id, :name => names[id]}
    end

    return gear
  end

  def find_two_slot_counts(slot, where, h)
    sql = two_slot_sql(slot, where)
    result = ActiveRecord::Base.connection.execute(ActiveRecord::Base::sanitize_sql("SELECT #{sql}"))
    return if result.num_tuples.zero? || result[0]["#{slot}1"].nil?
    h["#{slot}1"] = result[0]["#{slot}1"]
    h["#{slot}2"] = result[0]["#{slot}2"]
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
    return h if ids.empty?
    sql = ActiveRecord::Base::sanitize_sql("SELECT id, name FROM items WHERE id IN (#{whereify(ids)})")
    rows = ActiveRecord::Base.connection.execute(sql)
    rows.each do |row|
      h[row["id"].to_i] = row["name"]
    end

    return h
  end

end