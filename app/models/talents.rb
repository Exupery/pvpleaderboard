class Talents
	def self.get_talents(class_id, spec_id)
		h = Hash.new()
    tier_col = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT id, spell_id, spec_id, name, description, icon, tier, col FROM talents WHERE class_id=#{class_id} AND (spec_id=#{spec_id} OR spec_id=0)")
    rows.each do |row|
      h[row["id"]] = {:id => row["id"], :spell_id => row["spell_id"], :spec_id => row["spec_id"].to_i, :name => row["name"], :description => row["description"], :icon => row["icon"], :tier => row["tier"], :col => row["col"]}

      k = "#{row["tier"]}-#{row["col"]}"
      if !tier_col.has_key?(k) || tier_col[k][:spec_id] == 0
        tier_col[k] = {:id => row["id"], :spec_id => row["spec_id"].to_i}
      end
    end

    h.delete_if do |_id, talent|
      talent[:spec_id] == 0 && (tier_col["#{talent[:tier]}-#{talent[:col]}"][:spec_id] != talent[:spec_id])
    end

    return h
	end
end