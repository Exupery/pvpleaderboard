class Pvptalents
	def self.get_talents(spec_id)
		h = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT id, spell_id, spec_id, name, icon FROM pvp_talents WHERE spec_id=#{spec_id}")
    rows.each do |row|
      h[row["id"]] = {:id => row["id"], :spell_id => row["spell_id"], :spec_id => row["spec_id"].to_i, :name => row["name"], :icon => row["icon"]}
    end

    return h
	end
end