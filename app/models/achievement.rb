class Achievement
  attr_reader :id, :name, :description

  @@CACHE_KEY = "pvp_achievements"

  def initialize(id, name, description)
    @id = id
    @name = name
    @description = description
  end

  def self.get_pvp_achievements
    return Rails.cache.read(@@CACHE_KEY) if Rails.cache.exist?(@@CACHE_KEY)
    achievements = Hash.new
    rows = ActiveRecord::Base.connection.execute("SELECT id, name, description FROM achievements")
    rows.each do |row|
      next unless row["name"].downcase.include? "season"
      achievements[row["id"]] = Achievement.new(row["id"], row["name"], row["description"])
    end
    Rails.cache.write(@@CACHE_KEY, achievements, :expires_in => 12.hours)
    return achievements
  end
end