class Title
  include Comparable
  attr_reader :name, :season, :date, :description

  @@ARENA_TITLES = ["Combatant", "Challenger", "Rival", "Duelist", "Elite", "Gladiator"]
  @@ALLIANCE_RBG_TITLES = ["Soldier of the Alliance", "Defender of the Alliance", "Guardian of the Alliance"]
  @@HORDE_RBG_TITLES = ["Soldier of the Horde", "Defender of the Horde", "Guardian of the Horde"]

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

    return 0 if this_rank.nil? and other_rank.nil?
    return 1 if this_rank.nil? and @name.end_with? "Gladiator"
    return -1 if other_rank.nil? and other.name.end_with? "Gladiator"

    # prioritize arena titles over RBG titles of same rank
    if this_rank == other_rank
      return 1 if @@ARENA_TITLES.index @name and (@@ARENA_TITLES.index other.name).nil?
      return -1 if (@@ARENA_TITLES.index @name).nil? and @@ARENA_TITLES.index other.name
    end

    return this_rank <=> other_rank
  end

  def convert_to_arena name
    return name if @@ARENA_TITLES.index name

    alliance = @@ALLIANCE_RBG_TITLES.index name
    return @@ARENA_TITLES[alliance + 1] if alliance

    horde = @@HORDE_RBG_TITLES.index name
    return @@ARENA_TITLES[horde + 1] if horde
  end
end