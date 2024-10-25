class Title
  include Comparable
  attr_reader :name, :season, :description
  attr_accessor :date

  @@ARENA_TITLES = ["Combatant", "Combatant I", "Combatant II", "Challenger", "Challenger I", "Challenger II", "Battle Mender", "Rival", "Rival I", "Rival II", "Duelist", "Elite", "Legend", "Gladiator"]
  @@ARENA_TITLES_SET = @@ARENA_TITLES.to_set
  @@ALLIANCE_RBG_TITLES = {
    "Soldier of the Alliance" => "Challenger",
    "Defender of the Alliance" => "Rival",
    "Guardian of the Alliance" => "Duelist",
    "Hero of the Alliance" => "Legend",
    "Strategist" => "Legend"
  }
  @@HORDE_RBG_TITLES = {
    "Soldier of the Horde" => "Challenger",
    "Defender of the Horde" => "Rival",
    "Guardian of the Horde" => "Duelist",
    "Hero of the Horde" => "Legend",
    "Strategist" => "Legend"
  }

  def initialize(achievement_name, achievement_description, date)
    tokens = achievement_name.split /:\s+/
    @name = tokens[0]
    @season = tokens[1]
    @date = date
    @description = achievement_description
  end

  def <=>(other)
    this_name = convert_to_arena @name
    other_name = convert_to_arena other.name
    this_rank = @@ARENA_TITLES.index this_name
    other_rank = @@ARENA_TITLES.index other_name

    if this_rank.nil? and other_rank.nil?
      return 1 if @name.end_with? "Gladiator"
      return -1 if other.name.end_with? "Gladiator"
    end
    return 1 if this_rank.nil? and (@name.end_with? "Gladiator" or @name.end_with? "Legend")
    return -1 if other_rank.nil? and (other.name.end_with? "Gladiator" or other.name.end_with? "Legend")

    # prioritize arena titles over RBG titles of same rank
    if this_rank == other_rank
      return 1 if @@ARENA_TITLES_SET.include? @name and !(@@ARENA_TITLES_SET.include? other.name)
      return -1 if !(@@ARENA_TITLES_SET.include? @name) and @@ARENA_TITLES_SET.include? other.name
    end

    return this_rank <=> other_rank
  end

  def convert_to_arena name
    return name if @@ARENA_TITLES_SET.include? name

    return @@HORDE_RBG_TITLES[name] if @@HORDE_RBG_TITLES.has_key? name

    return @@ALLIANCE_RBG_TITLES[name] if @@ALLIANCE_RBG_TITLES.has_key? name
  end

  def to_s
    return "#{@name} #{@season} #{@date}"
  end
end