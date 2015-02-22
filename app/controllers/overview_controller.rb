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
  	
  	if bracket.nil?
  		@@BRACKETS.each do |b|
  			faction_counts b
  		end
  	else
  		faction_counts bracket
  	end
  	@bracket = bracket || "All"
  end

  private

  def faction_counts bracket
  	# TODO
  	rows = @@db.execute("SELECT factions.name AS faction, COUNT(*) FROM players JOIN factions ON players.faction_id=factions.id GROUP BY faction")
  	rows.each do |row|
  		puts row 	## TODO DELME
  	end
	end
end
