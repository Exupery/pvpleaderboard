class Player
  attr_reader :id, :ranking, :rating, :wins, :losses, :name, :faction, :race, :gender, :class, :spec, :spec_icon, :realm, :realm_slug, :region, :guild, :thumbnail, :ratings

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
    @thumbnail = hash["thumbnail"]
    @ratings = hash["ratings"]
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

end
