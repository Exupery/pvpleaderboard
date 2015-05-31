class OverviewController < ApplicationController
  protect_from_forgery with: :exception

  @@BRACKETS = ["2v2", "3v3", "5v5", "rbg"]

  def overview
  	bracket = params[:bracket]
  	bracket.downcase! if bracket
  	if bracket && !@@BRACKETS.include?(bracket)
  		redirect_to "/overview"
  		return nil
  	end
  	title_bracket = bracket.eql?("rbg") ? "RBG" : bracket
  	@title = "#{title_bracket || 'Leaderboard'} Overview"
  	@description = "World of Warcraft PvP leaderboard overview"

  	@factions = Hash.new(0)
    @races = Hash.new(0)
    @classes = Hash.new(0)
    @specs = Hash.new(nil)
    @realms = Hash.new(0)

    find_counts bracket

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

  def find_counts bracket
    if bracket.nil?
      @@BRACKETS.each do |b|
        (faction_counts b).each do |f, c|
          @factions[f] += c
        end

        (race_counts b).each do |r, c|
          @races[r] += c
        end

        (class_counts b).each do |cl, c|
          @classes[cl] += c
        end

        (spec_counts b).each do |s, info|
          if @specs[s].nil?
            @specs[s] = info
          else
            @specs[s].count += info.count
          end
        end

        (realm_counts b).each do |r, c|
          @realms[r] += c
        end
      end
    else
      @factions = faction_counts bracket
      @races = race_counts bracket
      @classes = class_counts bracket
      @specs = spec_counts bracket
      @realms = realm_counts bracket
    end
  end

  def faction_counts bracket
  	h = Hash.new

  	rows = ActiveRecord::Base.connection.execute("SELECT factions.name AS faction, COUNT(*) FROM bracket_#{bracket} JOIN players ON player_id=players.id JOIN factions ON players.faction_id=factions.id GROUP BY faction ORDER BY faction ASC")
  	rows.each do |row|
  		h[row["faction"]] = row["count"].to_i
  	end

  	return h
	end

  def race_counts bracket
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT races.name AS race, COUNT(*) FROM bracket_#{bracket} JOIN players ON player_id=players.id JOIN races ON players.race_id=races.id GROUP BY race ORDER BY race ASC")
    rows.each do |row|
      h[row["race"]] = row["count"].to_i
    end

    return h
  end

  def class_counts bracket
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT classes.name AS class, COUNT(*) FROM bracket_#{bracket} JOIN players ON player_id=players.id JOIN classes ON players.class_id=classes.id GROUP BY class ORDER BY class ASC")
    rows.each do |row|
      h[row["class"]] = row["count"].to_i
    end

    return h
  end

  def spec_counts bracket
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT specs.name AS spec, specs.icon, classes.name AS class, COUNT(*) FROM bracket_#{bracket} JOIN players ON player_id=players.id JOIN specs ON players.spec_id=specs.id JOIN classes ON specs.class_id=classes.id GROUP BY spec, specs.icon, class ORDER BY spec ASC")
    rows.each do |row|
      h[row["class"] + row["spec"]] = SpecInfo.new(row["spec"], row["count"].to_i, row["icon"], row["class"])
    end

    return h
  end

  def realm_counts bracket
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT realms.name AS realm, COUNT(*) FROM bracket_#{bracket} JOIN players ON player_id=players.id JOIN realms ON players.realm_slug=realms.slug GROUP BY realm ORDER BY COUNT(*) DESC LIMIT 25")
    rows.each do |row|
      h[row["realm"]] = row["count"].to_i
    end

    return h
  end
end

class SpecInfo
  attr_reader :name, :icon, :class_name
  attr_accessor :count

  def initialize(name, count, icon, class_name)
    @name = name
    @count = count
    @icon = icon
    @class_name = class_name
  end
end
