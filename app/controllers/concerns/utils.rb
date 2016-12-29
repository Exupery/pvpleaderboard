module Utils extend ActiveSupport::Concern

	def slugify txt
		return nil if txt.nil?
		return txt.downcase.gsub(/[\s\-]/, "_")
	end

	def urlify txt
		return nil if txt.nil?
		return txt.downcase.gsub(/[_\s]/, "-")
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

end