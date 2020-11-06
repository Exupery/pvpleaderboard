class Talents
	def self.get_talents(class_id, spec_id)
		h = Hash.new()
    tier_col = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT id, spell_id, spec_id, name, icon, tier, col FROM talents WHERE class_id=#{class_id} AND (spec_id=#{spec_id} OR spec_id IS NULL)")
    rows.each do |row|
      h[row["id"]] = {:id => row["id"], :spell_id => row["spell_id"], :spec_id => row["spec_id"].to_i, :name => row["name"], :icon => row["icon"], :tier => row["tier"], :col => row["col"]}

      k = "#{row["tier"]}-#{row["col"]}"
      if !tier_col.has_key?(k) || tier_col[k][:spec_id] == 0
        talent_spec_id = row["spec_id"].nil? ? 0 : row["spec_id"].to_i
        tier_col[k] = {:id => row["id"], :spec_id => talent_spec_id}
      end
    end

    h.delete_if do |_id, talent|
      talent[:spec_id] == 0 && (tier_col["#{talent[:tier]}-#{talent[:col]}"][:spec_id] != talent[:spec_id])
    end

    return h
	end
end