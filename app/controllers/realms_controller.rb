class RealmsController < StatisticsController
  include FilterUtils

  def show
    @title = "Realms - #{@title_region}#{@title_bracket || 'All Brackets'}"
    @description = "World of Warcraft PvP #{@title_region + @title_bracket + ' ' unless @title_bracket.nil?}leaderboard players per realm"

    ## Original (pre multi-region support) paths were realms/:realm_slug/:bracket so redirect
    ## if the current bracket location is a valid US realm slug and the current region is
    ## a valid bracket. [Cannot be done via routing due to ambiguity].
    if (params[:bracket] && Realms.list.include?(params[:bracket].downcase + "US")) &&
      (params[:region] && @@BRACKETS.include?(params[:region].downcase))
      redirect_to "/realms/#{params[:region].downcase}/us/#{params[:bracket].downcase}", :status => 301
      return nil
    end

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
