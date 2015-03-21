class Glyphs
	def self.get_glyphs class_id
		h = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT id, name, icon, item_id, type_id FROM glyphs WHERE class_id=#{class_id}")
    rows.each do |row|
      h[row["id"]] = {"name" => row["name"], "icon" => row["icon"], "item_id" => row["item_id"], "type_id" => row["type_id"]}
    end

    return h
	end
end