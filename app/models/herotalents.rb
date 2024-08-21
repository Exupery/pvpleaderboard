class Herotalents
	def self.get_talents(spec_id)
		h = Hash.new()
    return h unless spec_id.is_a? Numeric

		rows = ActiveRecord::Base.connection.execute("SELECT id, spell_id, spec_id, name, icon FROM talents WHERE cat='HERO' AND #{spec_id}=ANY(hero_specs)")
    rows.each do |row|
      h[row["id"]] = {:id => row["id"], :spell_id => row["spell_id"], :spec_id => row["spec_id"].to_i, :name => row["name"], :icon => row["icon"]}
    end

    return h
	end
end