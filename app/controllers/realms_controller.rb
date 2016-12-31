class RealmsController < OverviewController
  include FilterUtils

  def show
    @title = "Realms - #{@title_region}#{@title_bracket || 'All Brackets'}"
    @description = "World of Warcraft PvP #{@title_region + @title_bracket + ' ' unless @title_bracket.nil?}leaderboard players per realm"

    @realms = Hash.new(nil)

    if @bracket.nil?
      if params[:bracket] && params[:bracket].downcase != "all"
        redirect_to "/realms"
        return nil
      end
      @@BRACKETS.each do |b|
        (realm_counts(@region, b, "ALL")).each do |k, h|
          if @realms.has_key?(k)
            @realms[k][:count] += h[:count]
          else
            @realms[k] = h
          end
        end
      end
    else
      @realms = realm_counts(@region, @bracket, "ALL")
    end
  end

  def details
    if @bracket.nil? || @region.nil?
      redirect_to "/realms"
      return nil
    end
    @realm_slug = params[:realm_slug].downcase.delete("'").gsub(/\s/, "-") if params[:realm_slug]
    @realm = Realms.list[@realm_slug + @region.upcase]

    if @realm.nil?
      redirect_to "/realms/#{@bracket}/#{@region}"
      return nil
    end

    @title = "#{@realm.name} (#{@region}) - #{@title_bracket}"
    @description = "World of Warcraft #{@title_bracket} PvP leaderboard players on #{@realm.name} (#{@region})"

    @leaderboard = filter_leaderboard(@bracket, @region, "WHERE slug='#{@realm_slug}'")
    @last = 0
  end

end
