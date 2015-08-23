module FilterUtils extend ActiveSupport::Concern
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
    where += cr_clause if (@selected[:"cr-bracket"] && @selected[:"current-rating"])
    where += races_clause if @selected[:races]
    where += " AND players.honorable_kills > #{@selected[:hks].to_i}" if (@selected[:hks] && @selected[:hks].to_i > 0)

    return where
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
    Races.list.each do |slug, hash|
      a.push(hash[:id]) if @selected[:races].include?(urlify hash[:name])
    end

    return a.empty? ? "" : " AND players.race_id IN (#{a.join(",")})"
  end

  def cr_clause
    bracket = @selected[:"cr-bracket"].downcase
    cr = @selected[:"current-rating"].to_i
    return "" if (!["2v2", "3v3", "5v5", "rbg"].include?(bracket) || cr <= 0)

    return " AND cr_bracket.rating > #{cr}"
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
    @selected[:"rbg-achievements"].split("-").each do |achiev|
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