class RealmsController < OverviewController

  def show
    bracket = get_bracket
    title_bracket = bracket.eql?("rbg") ? "RBG" : bracket
    @title = "All Realms #{title_bracket || 'All Brackets'} Overview"
    @description = "World of Warcraft PvP leaderboard realms"

    @realms = Hash.new(0)

    if bracket.nil?
      @@BRACKETS.each do |b|
        (realm_counts(b, "ALL")).each do |r, c|
          @realms[r] += c
        end
      end
    else
      @realms = realm_counts(bracket, "ALL")
    end

    set_bracket bracket
  end

end
