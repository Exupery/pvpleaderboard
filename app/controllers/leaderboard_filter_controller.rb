require "set"

class LeaderboardFilterController < ApplicationController
  include Utils, FilterUtils
  protect_from_forgery with: :exception
  before_action :get_selected

  @@FILTERS = [:leaderboard, :region, :class, :spec, :factions, :"arena-achievements", :"rbg-achievements", :races, :realm, :name, :"current-rating"]

  def filter
    @title = "Leaderboard Filter"
    @description = "Filter World of Warcraft PvP leaderboards by class, realm, achievements, and more"
  end

  def results
    @title = "Leaderboard Filter Results"
    @description = "World of Warcraft PvP leaderboard player filter results"
    @filtered = true

    @bracket = get_bracket
    @region = get_leaderboard_region
    if @bracket.nil? || @region.nil?
      redirect_to "/leaderboards/filter"
      return nil
    end

    @leaderboard = players_on_leaderboard
    @last = 0
  end

  private

  def players_on_leaderboard
    where = create_where_clause
    where = "WHERE #{where.empty? ? 'TRUE' : where}"

    players = filter_leaderboard(@bracket, @region, where)

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

    @@FILTERS.each do |filter|
      @selected[filter] = dashify params[filter]
    end
  end
end
