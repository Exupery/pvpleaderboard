require "set"

class LeaderboardFilterController < ApplicationController
  include Utils, FilterUtils
  protect_from_forgery with: :exception
  before_action :get_selected

  def filter
    @title = "Leaderboard Filter"
    @description = "World of Warcraft PvP leaderboard player filter"
  end

  def results
    @title = "Leaderboard Filter Results"
    @description = "World of Warcraft PvP leaderboard player filter results"

    @bracket = get_bracket
    if @bracket.nil?
      redirect_to "/leaderboards/filter"
      return nil
    end

    @leaderboard = players_on_leaderboard
    @last = 0
  end

  private

  def players_on_leaderboard
    players = Array.new
    where = create_where_clause
    where = "WHERE #{where}" unless where.empty?

    rows = ActiveRecord::Base.connection.execute("SELECT players.id AS id, ranking, rating, season_wins AS wins, season_losses AS losses, players.name AS name, factions.name AS faction, races.name AS race, players.gender AS gender, classes.name AS class, specs.name AS spec, specs.icon AS spec_icon, realms.slug AS realm_slug, realms.name AS realm, players.guild FROM bracket_#{@bracket} LEFT JOIN players ON bracket_#{@bracket}.player_id=players.id LEFT JOIN factions ON players.faction_id=factions.id LEFT JOIN races ON players.race_id=races.id LEFT JOIN classes on players.class_id=classes.id LEFT JOIN specs ON players.spec_id=specs.id LEFT JOIN realms ON players.realm_slug=realms.slug #{where} ORDER BY ranking ASC")

    rows.each do |row|
      players << Player.new(row)
    end

    return players if players.empty?

    if (@selected[:"arena-achievements"] || @selected[:"rbg-achievements"])
      ids = Set.new
      ids = narrow_by_achievements players.map {|p| p.id}
      return players.find_all {|p| ids.include? p.id}
    end

    return players
  end

  def get_selected
    @selected = Hash.new

    filters = [:leaderboard, :class, :spec, :factions, :"arena-achievements", :"rbg-achievements", :races, :hks]

    filters.each do |filter|
      @selected[filter] = urlify params[filter]
    end
  end
end
