class LeaderboardsController < ApplicationController

  def show
    expires_in 1.day, public: true
    fresh_when last_modified: last_players_update

    @bracket = get_bracket
    title_bracket = @bracket.eql?("rbg") ? "RBG" : @bracket
    if title_bracket
      @title = "#{title_bracket} Leaderboard"
      @description = "Players currently on the World of Warcraft #{title_bracket} PvP leaderboard"
    else
      @title = "Leaderboard Selection"
      @description = "World of Warcraft PvP leaderboards"
    end

    @active_bracket = @bracket.eql?("rbg") ? "Rated Battleground" : @bracket
    if @bracket
      @total = total
      @leaderboard = players_on_leaderboard 0
      @last = last_ranking
    end
  end

  def more
    @bracket = get_bracket
    if @bracket && params[:min]
      @leaderboard = players_on_leaderboard params[:min]
      respond_to do |format|
        format.js { render partial: "layouts/leaderboard_table_body" }
      end
    end
  end

  private

  def players_on_leaderboard min
    cache_key = "#{@bracket}_players_#{min}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    players = Array.new

    rows = ActiveRecord::Base.connection.execute("SELECT ranking, rating, season_wins AS wins, season_losses AS losses, players.name AS name, factions.name AS faction, races.name AS race, players.gender AS gender, classes.name AS class, specs.name AS spec, specs.icon AS spec_icon, realms.slug AS realm_slug, realms.name AS realm, players.guild FROM bracket_#{@bracket} LEFT JOIN players ON bracket_#{@bracket}.player_id=players.id LEFT JOIN factions ON players.faction_id=factions.id LEFT JOIN races ON players.race_id=races.id LEFT JOIN classes on players.class_id=classes.id LEFT JOIN specs ON players.spec_id=specs.id LEFT JOIN realms ON players.realm_slug=realms.slug WHERE ranking > #{min} ORDER BY ranking ASC LIMIT 250")

    rows.each do |row|
      players << Player.new(row)
    end

    Rails.cache.write(cache_key, players)
    return players
  end

  def last_ranking
    cache_key = "#{@bracket}_last_ranking"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    last = 0

    rows = ActiveRecord::Base.connection.execute("SELECT MAX(ranking) AS ranking FROM bracket_#{@bracket}")

    rows.each do |row|
      last = row["ranking"].to_i
    end

    Rails.cache.write(cache_key, last)
    return last
  end

  def total
    cache_key = "#{@bracket}_count"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    count = 0

    rows = ActiveRecord::Base.connection.execute("SELECT COUNT(*) AS count FROM bracket_#{@bracket}")

    rows.each do |row|
      count = row["count"].to_i
    end

    Rails.cache.write(cache_key, count)
    return count
  end

end
