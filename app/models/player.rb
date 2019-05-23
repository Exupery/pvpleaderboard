class Player
  attr_reader :id, :ranking, :rating, :wins, :losses, :name, :faction, :race, :gender, :class, :spec, :spec_icon, :realm, :realm_slug, :region, :guild, :avatar_image, :main_image, :ratings, :titles

  def initialize hash
    @id = hash["id"]
    @ranking = hash["ranking"]
    @rating = hash["rating"]
    @wins = hash["wins"].to_i
    @losses = hash["losses"].to_i
    @name = hash["name"]
    @faction = hash["faction"]
    @race = hash["race"]
    @gender = hash["gender"].to_i == 0 ? "male" : "female"
    @class = hash["class"]
    @spec = hash["spec"]
    @spec_icon = hash["spec_icon"]
    @realm = hash["realm"]
    @realm_slug = hash["realm_slug"]
    @region = hash["region"]
    @guild = hash["guild"]

    # Player audit-only attributes
    @avatar_image = image_link hash["thumbnail"]
    @main_image = @avatar_image.sub("avatar", "main") unless @avatar_image.nil?
    @ratings = hash["ratings"]
    @titles = trim_titles(hash["titles"]) if hash["titles"]
  end

  def win_ratio
    total = @wins + @losses
    return 0 if total == 0
    return (@wins.to_f / total * 100).round(1)
  end

  def armory_link
    locale = @region == "US" ? "en-us" : "en-gb"
    return "https://worldofwarcraft.com/#{locale}/character/#{@realm_slug}/#{@name}"
  end

  private

  def image_link thumbnail
    return nil if thumbnail.nil?
    locale = @region == "US" ? "us" : "eu"
    return "https://render-#{locale}.worldofwarcraft.com/character/#{thumbnail}"
  end

  # Trims the list to the highest title for each
  # season if more than one earned in a season
  def trim_titles titles
    h = Hash.new
    titles.each do |title|
      if h.include? title.season
        h[title.season] = title if title > h[title.season]
      else
        h[title.season] = title
      end
    end

    return h.values.sort {|a, b| b.date <=> a.date}
  end

end
