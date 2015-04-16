class Glyphs
  @@MAJOR_TYPE_ID = 0
  @@MINOR_TYPE_ID = 1

  def self.MAJOR_ID
    return @@MAJOR_TYPE_ID
  end

  def self.MINOR_ID
    return @@MINOR_TYPE_ID
  end

	def self.get_glyphs class_id
		h = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT id, name, icon, item_id, type_id, spell_id FROM glyphs WHERE class_id=#{class_id}")
    rows.each do |row|
      h[row["id"]] = {:name => row["name"], :icon => row["icon"], :item_id => row["item_id"], :type_id => row["type_id"], :spell_id => row["spell_id"]}
    end

    return h
	end
end