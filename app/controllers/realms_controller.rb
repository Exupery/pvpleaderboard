class RealmsController < OverviewController
  include FilterUtils

  def show
    @bracket = get_bracket
    title_bracket = get_title_bracket @bracket
    @title = "Realms - #{title_bracket || 'All Brackets'}"
    @description = "World of Warcraft PvP leaderboard players per realm"

    @realms = Hash.new(0)

    if @bracket.nil?
      if params[:bracket] && params[:bracket].downcase != "all"
        redirect_to "/realms"
        return nil
      end
      @@BRACKETS.each do |b|
        (realm_counts(b, "ALL")).each do |r, c|
          @realms[r] += c
        end
      end
    else
      @realms = realm_counts(@bracket, "ALL")
    end

    @bracket_fullname = get_bracket_fullname @bracket
  end

  def details
    @bracket = get_bracket
    title_bracket = get_title_bracket @bracket
    @realm_slug = params[:realm_slug].downcase.gsub(/'/, "").gsub(/\s/, "-") if params[:realm_slug]
    @realm_name = Realms.list[@realm_slug]

    if @bracket.nil?
      redirect_to "/realms"
      return nil
    elsif @realm_name.nil?
      redirect_to "/realms/#{@bracket}"
      return nil
    end

    @title = "#{@realm_name} - #{title_bracket || 'All Brackets'}"
    @description = "World of Warcraft PvP leaderboard players on #{@realm_name}"

    @bracket_fullname = get_bracket_fullname @bracket
    @leaderboard = filter_leaderboard(@bracket, "WHERE slug='#{@realm_slug}'")
    @last = 0
  end

end
