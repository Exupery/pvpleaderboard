class Talents
	def self.get_talents class_id
		h = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT id, name, description, icon, tier, col FROM talents WHERE class_id=#{class_id}")
    rows.each do |row|
      h[row["id"]] = {:id => row["id"], :name => row["name"], :description => row["description"], :icon => row["icon"], :tier => row["tier"], :col => row["col"]}
    end

    return h
	end
end