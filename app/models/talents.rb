class Talents
  def self.get_class_talents(class_id)
		return get_talents "class_id=#{class_id} AND spec_id=0"
	end

  def self.get_spec_talents(spec_id)
		return get_talents "spec_id=#{spec_id}"
	end

  private

	def self.get_talents(where)
		h = Hash.new

		rows = ActiveRecord::Base.connection.execute("SELECT id, spell_id, spec_id, name, icon FROM talents WHERE #{where}")
    rows.each do |row|
      icon = row["icon"] == "" ? "placeholder" : row["icon"]
      h[row["id"]] = {:id => row["id"], :spell_id => row["spell_id"], :spec_id => row["spec_id"].to_i, :name => row["name"], :icon => icon}
    end

    return h
	end
end