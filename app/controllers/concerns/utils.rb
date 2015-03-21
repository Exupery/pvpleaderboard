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
		total = 0

		rows = ActiveRecord::Base.connection.execute("SELECT COUNT(*) AS total FROM player_ids_all_brackets JOIN players ON player_ids_all_brackets.player_id=players.id WHERE players.class_id=#{class_id} AND players.spec_id=#{spec_id}")
		rows.each do |row|
      total = row["total"].to_i
    end

    return total
	end
end