module FilterUtils extend ActiveSupport::Concern
  def filter_leaderboard(bracket, region, where)
    players = Array.new

    bracket_clause = "AND leaderboards.bracket='#{bracket}'"
    region_clause = "AND leaderboards.region='#{region}'"

    rows = ActiveRecord::Base.connection.execute("SELECT players.id AS id, ranking, rating, season_wins AS wins, season_losses AS losses, players.name AS name, factions.name AS faction, races.name AS race, players.gender AS gender, classes.name AS class, specs.name AS spec, specs.icon AS spec_icon, realms.slug AS realm_slug, realms.name AS realm, realms.region AS region, players.guild FROM leaderboards LEFT JOIN players ON leaderboards.player_id=players.id LEFT JOIN factions ON players.faction_id=factions.id LEFT JOIN races ON players.race_id=races.id LEFT JOIN classes on players.class_id=classes.id LEFT JOIN specs ON players.spec_id=specs.id LEFT JOIN realms ON players.realm_id=realms.id #{where} #{bracket_clause} #{region_clause} ORDER BY ranking ASC")

    rows.each do |row|
      players << Player.new(row)
    end

    return players
  end

  def create_where_clause
    where = ""

    if @selected[:class]
      clazz = Classes.list[slugify @selected[:class]]
      return "" if clazz.nil?
      where += "players.class_id=#{clazz[:id]}" if clazz
    end

    if @selected[:spec]
      spec = Specs.slugs[slugify "#{@selected[:class]}_#{@selected[:spec]}"]
      return "" if spec.nil?
      where += " AND players.spec_id=#{spec[:id]}" if spec
    end

    where += factions_clause if @selected[:factions]
    where += races_clause if @selected[:races]
    where += realm_clause if @selected[:realm]
    where += " AND players.honorable_kills > #{@selected[:hks].to_i}" if (@selected[:hks] && @selected[:hks].to_i > 0)

    return where.start_with?(" AND ") ? where.sub(" AND ", "") : where
  end

  def factions_clause
    ## omit clause if both factions are selected
    return "" if @selected[:factions].downcase.include?("alliance") && @selected[:factions].downcase.include?("horde")

    faction = Factions.list[slugify @selected[:factions]]
    return faction ? " AND players.faction_id=#{faction[:id]}" : ""
  end

  def races_clause
    a = Array.new

    # Pandas (and potential future races) can be either faction (and thus mutiple slugs/ids)
    # so iterating through the races and using include on the param string instead of tokenizing
    selected_races = @selected[:races].nil? ? "" : @selected[:races].split(" ")
    Races.list.each do |_slug, hash|
      a.push(hash[:id]) if selected_races.include?(urlify hash[:name])
    end

    return a.empty? ? "" : " AND players.race_id IN (#{a.join(",")})"
  end

  def realm_clause
    return Realms.list[@selected[:realm] + @region].nil? ? "" : " AND realms.slug='#{@selected[:realm]}'"
  end

  def narrow_by_cr ids
    if @selected[:"current-rating"]
      if @selected[:"cr-bracket"]
        bracket = @selected[:"cr-bracket"].downcase
        bracket_clause = "AND bracket='#{bracket}'" if Brackets.list.include?(bracket)
      end
      cr = @selected[:"current-rating"].to_i
      if cr > 0
        cr_ids = Set.new
        rows = ActiveRecord::Base.connection.execute("SELECT player_id FROM leaderboards WHERE rating > #{cr} #{bracket_clause}")
        rows.each do |row|
          cr_ids.add(row["player_id"])
        end

        return ids.intersection cr_ids
      end
    end

    return ids
  end

  def narrow_by_achievements ids
    id_array = ids.to_a

    arena_narrowed = Set.new
    if @selected[:"arena-achievements"]
      arena_achievements = arena_achievement_ids @selected[:"arena-achievements"]
      rows = ActiveRecord::Base.connection.execute("SELECT player_id FROM players_achievements WHERE player_id IN (#{id_array.join(",")}) AND achievement_id IN (#{arena_achievements.join(",")})")
      rows.each do |row|
        arena_narrowed.add(row["player_id"])
      end

      return arena_narrowed unless @selected[:"rbg-achievements"]
    end

    rbg_narrowed = Set.new
    if @selected[:"rbg-achievements"]
      rbg_achievements = rbg_achievement_id_pairs
      if rbg_achievements.length == 2
        rows = ActiveRecord::Base.connection.execute("SELECT player_id FROM players_achievements WHERE player_id IN (#{id_array.join(",")}) AND (achievement_id IN (#{rbg_achievements[0].join(",")}) OR achievement_id IN (#{rbg_achievements[1].join(",")}))")
        rows.each do |row|
          rbg_narrowed.add(row["player_id"])
        end
      end

      return @selected[:"arena-achievements"] ? (arena_narrowed & rbg_narrowed) : rbg_narrowed
    end

    return Set.new
  end

  def rbg_achievement_id_pairs
    rbg_alliance = Array.new
    rbg_horde = Array.new
    ctr = 0
    @selected[:"rbg-achievements"].split(/[\-\s]/).each do |achiev|
      if ctr.even?
        rbg_alliance.push(achiev)
      else
        rbg_horde.push(achiev)
      end
      ctr += 1
    end
    return [rbg_alliance, rbg_horde]
  end

  def arena_achievement_ids achievements
    ids = Array.new
    return ids if (achievements.nil? || achievements.empty?)

    achievements.split("-").each do |achiev|
      i = achiev.to_i
      ids.push i if i > 0
    end

    return ids
  end
end