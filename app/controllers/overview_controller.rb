class OverviewController < ApplicationController
  protect_from_forgery with: :exception

  @@db = ActiveRecord::Base.connection
  @@BRACKETS = ["2v2", "3v3", "5v5", "rbg"]

  def stats
  	bracket = params[:bracket]
  	bracket.downcase! if bracket
  	if bracket && !@@BRACKETS.include?(bracket)
  		redirect_to "/overview"
  		return nil
  	end
  	title_bracket = bracket.eql?("rbg") ? "RBG" : bracket
  	@title = "#{title_bracket || 'Leaderboard'} Overview"
  	@description = "WoW PvP leaderboard overview"

  	@counts = Hash.new(0)
  	if bracket.nil?
  		@@BRACKETS.each do |b|
  			fc = faction_counts b
  			fc.each do |f, c|
  				@counts[f] = @counts[f] + c
  			end
  		end
  	else
  		@counts = faction_counts bracket
  	end

  	case bracket
  	when nil
  		@bracket = "All Leaderboards"
  	when "rbg"
  		@bracket = "Rated Battlegrounds"
  	else
  		@bracket = bracket
  	end
  end

  private

  def faction_counts bracket
  	h = Hash.new

  	rows = @@db.execute("SELECT factions.name AS faction, COUNT(*) FROM bracket_#{bracket} JOIN players ON player_id=players.id JOIN factions ON players.faction_id=factions.id GROUP BY faction ORDER BY faction ASC")
  	rows.each do |row|
  		h[row["faction"]] = row["count"].to_i
  	end

  	return h
	end
end
