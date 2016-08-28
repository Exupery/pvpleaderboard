module FilterHelper
  def arena_achievements
    ids = [401, 405, 404, 1159, 1160, 1161, 5266, 5267, 876, 2090, 2093, 2092, 2091]

    return find ids
  end

  def rbg_achievements
    h = Hash.new

    join_ids = {5329 => 5326, 5339 => 5353, 5341 => 5355, 5343 => 5356, 6942 => 6941}
    achievements = find join_ids.keys + join_ids.values

    join_ids.each do |first, second|
      f = achievements[first]
      s = achievements[second]
      if !f.nil? && !s.nil? then
        id = "#{f[:id]}-#{s[:id]}"
        name = "#{f[:name]} / #{s[:name]}"
        h[id] = {:id => id, :name => name, :description => f[:description]}
      end
    end

    return h
  end

  private

  def find achievements
    h = Hash.new
    ids = "(#{achievements.join(",")})"

    rows = ActiveRecord::Base.connection.execute("SELECT id, name, description FROM achievements WHERE id in #{ids}")
    rows.each do |row|
      id = row["id"].to_i
      h[id] = {:id => id, :name => row["name"], :description => row["description"]}
    end

    return h
  end
end
