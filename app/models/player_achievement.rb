class PlayerAchievement
  attr_reader :achievement, :raw_date
  attr_accessor :char_date, :alt_date

  @@CACHE_KEY = "pvp_rating_achievements"
  @@ORDERED_CACHE_KEY = "ordered_rating_achievements"
  @@ACHIEVEMENT_IDS = [ 399, 400, 401, 1159, 402, 403, 405, 1160, 5266, 5267, 2091 ]

  def initialize(achievement, date)
    @achievement = achievement
    @raw_date = date
  end

  def self.ordered_rating_achievements
    return Rails.cache.read(@@ORDERED_CACHE_KEY) if Rails.cache.exist?(@@ORDERED_CACHE_KEY)
    ordered_achievements = {
      399 => { "b" => "2v2", "r" => 1550 },
      400 => { "b" => "2v2", "r" => 1750 },
      401 => { "b" => "2v2", "r" => 2000 },
      1159 => { "b" => "2v2", "r" => 2200 },

      402 => { "b" => "3v3", "r" => 1550 },
      403 => { "b" => "3v3", "r" => 1750 },
      405 => { "b" => "3v3", "r" => 2000 },
      1160 => { "b" => "3v3", "r" => 2200 },
      5266 => { "b" => "3v3", "r" => 2400 },
      5267 => { "b" => "3v3", "r" => 2700 }
    }
    Rails.cache.write(@@ORDERED_CACHE_KEY, ordered_achievements, :expires_in => 24.hours)
    return ordered_achievements
  end

  def self.get_rating_achievements
    return Rails.cache.read(@@CACHE_KEY) if Rails.cache.exist?(@@CACHE_KEY)
    achievements = Achievement.get_achievements Set.new(@@ACHIEVEMENT_IDS)
    Rails.cache.write(@@CACHE_KEY, achievements, :expires_in => 24.hours)
    return achievements
  end
end