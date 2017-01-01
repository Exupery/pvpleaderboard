class LeaderboardsController < BracketRegionController
  include Utils

  @@DEFAULT_MAX_RESULTS = 500

  def show
    expires_in 1.day, public: true
    fresh_when(last_modified: last_players_update) if Rails.env.production?

    if @bracket && @region
      @title = "#{@title_region}#{@title_bracket} Leaderboard"
      @description = "Players currently on the World of Warcraft #{@title_region}#{@title_bracket} PvP leaderboard"

      @active_bracket = @bracket.eql?("rbg") ? "Rated Battleground" : @bracket
      @total = total
      @leaderboard = players_on_leaderboard(0, @@DEFAULT_MAX_RESULTS)
      @last = last_ranking
    else
      @title = "Leaderboard Selection"
      @description = "World of Warcraft PvP leaderboards"
    end
  end

  def more
    @bracket = get_bracket
    @region = get_region
    if @bracket && @region && params[:min]
      max_results = params[:all] == "true" ? nil : @@DEFAULT_MAX_RESULTS
      @leaderboard = players_on_leaderboard(params[:min], max_results)
      respond_to do |format|
        format.js { render partial: "layouts/leaderboard_table_body" }
      end
    end
  end

  private

  def players_on_leaderboard(min_rank, max_results)
    cache_key = "#{@region}_{@bracket}_players_#{min_rank}_#{max_results}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    players = Array.new
    limit = max_results.nil? ? "" : "LIMIT #{max_results}"

    bracket_clause = "AND leaderboards.bracket='#{@bracket}'"

    rows = ActiveRecord::Base.connection.execute("SELECT ranking, rating, season_wins AS wins, season_losses AS losses, players.name AS name, factions.name AS faction, races.name AS race, players.gender AS gender, classes.name AS class, specs.name AS spec, specs.icon AS spec_icon, realms.slug AS realm_slug, realms.name AS realm, realms.region AS region, players.guild FROM leaderboards LEFT JOIN players ON leaderboards.player_id=players.id LEFT JOIN factions ON players.faction_id=factions.id LEFT JOIN races ON players.race_id=races.id LEFT JOIN classes on players.class_id=classes.id LEFT JOIN specs ON players.spec_id=specs.id LEFT JOIN realms ON players.realm_id=realms.id WHERE ranking > #{min_rank} #{bracket_clause} #{@region_clause} ORDER BY ranking ASC #{limit}")

    rows.each do |row|
      players << Player.new(row)
    end

    Rails.cache.write(cache_key, players) unless max_results.nil?
    return players
  end

  def last_ranking
    cache_key = "#{@region}_#{@bracket}_last_ranking"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    last = 0

    rows = ActiveRecord::Base.connection.execute("SELECT MAX(ranking) AS ranking FROM leaderboards WHERE bracket='#{@bracket}' #{@region_clause}")

    rows.each do |row|
      last = row["ranking"].to_i
    end

    Rails.cache.write(cache_key, last)
    return last
  end

  def total
    cache_key = "#{@region}_#{@bracket}_count"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    count = 0

    rows = ActiveRecord::Base.connection.execute("SELECT COUNT(*) AS count FROM leaderboards WHERE bracket='#{@bracket}' #{@region_clause}")

    rows.each do |row|
      count = row["count"].to_i
    end

    Rails.cache.write(cache_key, count)
    return count
  end

end
