class Player
  attr_reader :id, :ranking, :rating, :bracket, :wins, :losses, :name, :faction, :race,
    :gender, :class, :class_id, :spec, :spec_id, :spec_icon, :realm, :realm_slug, :region, :guild, :main_image,
    :ratings, :titles, :ilvl, :class_talents, :spec_talents, :hero_talents, :pvp_talents, :loadout, :dates

  @@armory_locales = { "US" => "en-us", "EU" => "en-gb", "KR" => "ko_kr", "TW" => "zh-tw" }

  def initialize hash
    @id = hash["id"]
    @ranking = hash["ranking"]
    @rating = hash["rating"]
    @bracket = style_bracket hash["bracket"]
    @wins = hash["wins"].to_i
    @losses = hash["losses"].to_i
    @name = hash["name"]
    @faction = hash["faction"]
    @race = hash["race"]
    @gender = hash["gender"].to_i == 0 ? "male" : "female"
    @class = hash["class"]
    @class_id = hash["class_id"]
    @spec = hash["spec"]
    @spec_id = hash["spec_id"]
    @spec_icon = hash["spec_icon"]
    @realm = hash["realm"]
    @realm_slug = hash["realm_slug"]
    @region = hash["region"]
    @guild = hash["guild"]

    # Player audit-only attributes
    @main_image = hash["thumbnail"]
    @ratings = hash["ratings"]
    @titles = trim_titles(hash["titles"]) if hash["titles"]
    @ilvl = hash["ilvl"]
    @class_talents = hash["class_talents"]
    @spec_talents = hash["spec_talents"]
    @hero_talents = hash["hero_talents"]
    @pvp_talents = hash["pvp_talents"]
    @loadout = hash["loadout_code"]
    @dates = populate_dates hash["achiev_dates"]
  end

  def win_ratio
    total = @wins + @losses
    return 0 if total == 0
    return (@wins.to_f / total * 100).round(1)
  end

  def armory_link
    locale = @@armory_locales[@region]
    return "https://worldofwarcraft.com/#{locale}/character/#{@realm_slug}/#{@name}".downcase
  end

  private

  # Trims the list to the highest title for each
  # season if more than one earned in a season
  def trim_titles titles
    h = Hash.new
    prev_time = 0
    titles.each do |title|
      # Some DFS1 Glad titles are missing timestamps
      title.date = prev_time + 1 if title.date.nil?
      prev_time = title.date

      if h.include? title.season
        h[title.season] = title if title > h[title.season]
      else
        h[title.season] = title
      end
    end

    time_sorted = h.values.sort {|a, b| b.date <=> a.date}
    return cleanup_r1 time_sorted
  end

  # In BFA it was changed so titles were earned during
  # the season instead of after it ended except for R1
  # so we need to handle a player earning a Season X
  # title before being awareded their Season X - 1 R1
  def cleanup_r1 titles
    return titles if titles.length < 2

    for i in 1..titles.length-1 do
      swap_if_needed(titles, i-1, i)
    end

    return titles
  end

  def swap_if_needed(titles, pos1, pos2)
    title_a = titles[pos1]
    title_b = titles[pos2]
    if title_a.season.start_with?(title_b.season.slice(0, 3))
      title_a_season_num = title_a.season.slice(/[0-9]/)
      title_b_season_num = title_b.season.slice(/[0-9]/)
      if title_a_season_num < title_b_season_num
        titles[pos1] = title_b
        titles[pos2] = title_a
      end
    end

    return titles
  end

  def populate_dates achiev_dates
    a = Array.new
    return a if (@ratings.nil? || @ratings.empty? || achiev_dates.nil?)
    ordered = PlayerAchievement.ordered_rating_achievements
    ordered.each do |id, hash|
      if achiev_dates.include? id
        achiev = achiev_dates[id]
        bracket = hash["b"]
        highest = @ratings[bracket]["high"].nil? ? 0 : @ratings[bracket]["high"]
        if highest >= hash["r"]
          achiev.char_date = achiev.raw_date
        else
          achiev.alt_date = achiev.raw_date
        end
        a.push achiev
      end
    end

    return a
  end

  def style_bracket bracket
    return nil if bracket.nil?

    return "RBG" if bracket.downcase == "rbg"
    return "Solo" if bracket.downcase.start_with?("solo")
    return "BG Blitz" if bracket.downcase.start_with?("blitz")

    return bracket
  end

end
