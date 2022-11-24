class Talents
  def self.get_class_talents(class_id)
    cache_key = "class_talents_#{class_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
		talents = get_talents "class_id=#{class_id} AND spec_id=0"
    Rails.cache.write(cache_key, talents, :expires_in => 1.hour)
    return talents
	end

  def self.get_spec_talents(spec_id)
    cache_key = "spec_talents_#{spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
		talents = get_talents "spec_id=#{spec_id}"
    Rails.cache.write(cache_key, talents, :expires_in => 1.hour)
    return talents
	end

  private

	def self.get_talents(where)
		h = Hash.new

		rows = ActiveRecord::Base.connection.execute("SELECT id, spell_id, spec_id, name, icon, node_id, display_row, display_col FROM talents WHERE #{where} ORDER BY node_id ASC")
    rows.each do |row|
      icon = row["icon"] == "" ? "placeholder" : row["icon"]
      h[row["id"]] = {
        :id => row["id"],
        :spell_id => row["spell_id"],
        :spec_id => row["spec_id"].to_i,
        :name => row["name"],
        :row => row["display_row"],
        :col => row["display_col"],
        :icon => icon}
    end

    return h
	end
end