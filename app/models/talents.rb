class Talents

  def self.get_class_talents(class_id, spec_id)
    cache_key = "class_talents_#{class_id}_#{spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    or_clause = spec_id.nil? ? "" : "OR spec_id=#{spec_id}"
		talents = get_talents "class_id=#{class_id} AND cat='CLASS'"
    Rails.cache.write(cache_key, talents, :expires_in => 1.hour)
    return talents
	end

  def self.get_spec_talents(spec_id)
    return Hash.new if spec_id.nil?
    cache_key = "spec_talents_#{spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
		talents = get_talents "spec_id=#{spec_id} AND cat='SPEC'"
    Rails.cache.write(cache_key, talents, :expires_in => 1.hour)
    return talents
	end

  def self.get_hero_talents(spec_id)
    return Hash.new if spec_id.nil?
    cache_key = "hero_talents_#{spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
		talents = get_talents "#{spec_id}=ANY(hero_specs) AND cat='HERO'"
    Rails.cache.write(cache_key, talents, :expires_in => 1.hour)
    return talents
	end

  private

	def self.get_talents(where)
		h = Hash.new

		rows = ActiveRecord::Base.connection.execute("SELECT id, spell_id, spec_id, hero_specs, name, icon, node_id, display_row, display_col FROM talents WHERE #{where} ORDER BY node_id ASC")
    rows.each do |row|
      icon = row["icon"] == "" ? "placeholder" : row["icon"]
      h[row["id"]] = {
        :id => row["id"],
        :spell_id => row["spell_id"],
        :spec_id => row["spec_id"].to_i,
        :hero_specs => hero_specs_str(row["hero_specs"]),
        :name => row["name"],
        :row => row["display_row"],
        :col => row["display_col"],
        :icon => icon}
    end

    return h
	end

  def self.hero_specs_str specs_array
    return nil if specs_array.nil?
    return nil if specs_array.empty?

    return specs_array.gsub("{", "").gsub(" ", "").gsub(",", "_").gsub("}", "")
  end

end