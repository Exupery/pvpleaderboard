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
    this_rank = get_rank @name
    other_rank = get_rank other.name

    # prioritize arena titles over RBG titles of same rank
    if this_rank == other_rank
      return 1 if @@ARENA_TITLES_SET.include? @name and !(@@ARENA_TITLES_SET.include? other.name)
      return -1 if !(@@ARENA_TITLES_SET.include? @name) and @@ARENA_TITLES_SET.include? other.name
    end

    return this_rank <=> other_rank
  end

  def to_s
    return "#{@name} #{@season} #{@date}"
  end

  private

  def convert_to_arena name
    return name if @@ARENA_TITLES_SET.include? name

    return @@HORDE_RBG_TITLES[name] if @@HORDE_RBG_TITLES.has_key? name

    return @@ALLIANCE_RBG_TITLES[name] if @@ALLIANCE_RBG_TITLES.has_key? name

    return nil
  end

  def get_rank name
    arena_name = convert_to_arena name
    arena_rank = @@ARENA_TITLES.index arena_name
    return arena_rank unless arena_rank.nil?

    # Not in @@ARENA_TITLES means it's an R1 title
    base = @@ARENA_TITLES.length
    return (base + 1) if name.end_with? "Marshal"
    return (base + 2) if name.end_with? "Warlord"
    return (base + 3) if name.end_with? "Legend"
    return (base + 4) if name.end_with? "Gladiator"

    return -1
  end

end