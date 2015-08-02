class LeaderboardsController < ApplicationController

  def show
    @bracket = get_bracket
    title_bracket = @bracket.eql?("rbg") ? "RBG" : @bracket
    if title_bracket
      @title = "#{title_bracket} Leaderboard"
      @description = "World of Warcraft #{title_bracket} PvP leaderboard"
    else
      @title = "Leaderboard Selection"
      @description = "World of Warcraft PvP leaderboards"
    end

    @active_bracket = @bracket.eql?("rbg") ? "Rated Battleground" : @bracket
    @leaderboard = players_on_leaderboard if @bracket
  end

  private

  def players_on_leaderboard
    cache_key = "#{@bracket}_players"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    players = Array.new

    rows = ActiveRecord::Base.connection.execute("SELECT ranking, rating, season_wins AS wins, season_losses AS losses, players.name AS name, factions.name AS faction, races.name AS race, classes.name AS class, specs.name AS spec, realms.slug AS realm_slug, realms.name AS realm, players.guild FROM bracket_#{@bracket} LEFT JOIN players ON bracket_#{@bracket}.player_id=players.id LEFT JOIN factions ON players.faction_id=factions.id LEFT JOIN races ON players.race_id=races.id LEFT JOIN classes on players.class_id=classes.id LEFT JOIN specs ON players.spec_id=specs.id LEFT JOIN realms ON players.realm_slug=realms.slug ORDER BY ranking ASC")

    rows.each do |row|
      players << Player.new(row)
    end

    Rails.cache.write(cache_key, players)
    return players
  end

end
