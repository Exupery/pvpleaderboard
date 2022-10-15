class Achievement
  attr_reader :id, :name, :description, :icon

  @@CACHE_KEY = "seasonal_pvp_achievements"

  def initialize(id, name, description, icon)
    @id = id
    @name = name
    @description = description
    @icon = icon
  end

  def self.get_seasonal_achievements
    return Rails.cache.read(@@CACHE_KEY) if Rails.cache.exist?(@@CACHE_KEY)
    achievements = get_achievements Set.new
    Rails.cache.write(@@CACHE_KEY, achievements, :expires_in => 12.hours)
    return achievements
  end

  def self.get_achievements ids
    achievements = Hash.new
    sql = "SELECT id, name, description, icon FROM achievements"
    (sql += " WHERE id IN (#{ids.join(',')})") unless ids.empty?
    rows = ActiveRecord::Base.connection.execute(sql)
    rows.each do |row|
      next unless (row["name"].downcase.include?("season") || ids.include?(row["id"]))
      achievements[row["id"]] =
        Achievement.new(row["id"], row["name"], row["description"], row["icon"])
    end
    return achievements
  end
end