class BlitzController < PrefixedController

  def get_bracket_title
    return "BG Blitz"
  end

  def get_bracket_name spec_id
    return "blitz_#{spec_id}"
  end

  def get_page_title(region, clazz, spec, title_region, title_bracket)
    class_name = clazz[:name]
    spec_name = spec[:name]
    return "#{title_region}#{spec_name} #{class_name} #{title_bracket} Leaderboard"
  end

  def get_page_description(region, clazz, spec, title_region, title_bracket)
    class_name = clazz[:name]
    spec_name = spec[:name]
    return "Players currently on the World of Warcraft #{title_region}#{spec_name} #{class_name} #{title_bracket} PvP leaderboard"
  end

  def get_selection_page_title
    return "BG Blitz Leaderboard Selection"
  end

  def get_selection_page_description
    return "World of Warcraft BG Blitz Leaderboards"
  end

end