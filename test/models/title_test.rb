require "test_helper"

class TitleTest < ActiveSupport::TestCase
  def initialize arg
    super arg
    @combatant = create_title "Combatant"
    @challenger = create_title "Challenger"
    @battle_mender = create_title "Battle Mender"
    @rival = create_title "Rival"
    @duelist = create_title "Duelist"
    @elite = create_title "Elite"
    @gladiator = create_title "Gladiator"
    @legend = create_title "Legend"
    @strategist = create_title "Strategist"
    @rank_one = create_title "Foo Gladiator"
    @solo_rank_one = create_title "Foo Legend"
    @blitz_rank_one_horde = create_title "Foo Warlord"
    @blitz_rank_one_alliance = create_title "Foo Marshal"
  end

  def test_sort_by_title_name
    # Check hierarchy
    assert @combatant < @challenger
    assert @challenger < @battle_mender
    assert @challenger < @rival
    assert @rival < @duelist
    assert @duelist < @elite
    assert @elite < @gladiator
    assert @elite < @strategist
    assert @elite < @legend
    assert @strategist < @legend
    assert @legend < @gladiator
    assert @gladiator < @rank_one

    # Check equality
    assert @gladiator == @gladiator

    # Check rank one handling
    assert @rank_one == @rank_one
    assert @solo_rank_one == @solo_rank_one
    assert @rank_one > @challenger
    assert @challenger < @rank_one
    assert @gladiator < @solo_rank_one
    assert @solo_rank_one > @gladiator
    assert @blitz_rank_one_horde > @gladiator
    assert @blitz_rank_one_alliance > @gladiator
    assert @solo_rank_one < @rank_one
    assert @rank_one > @solo_rank_one
    assert @rank_one > @blitz_rank_one_horde
    assert @rank_one > @blitz_rank_one_alliance
    assert @solo_rank_one > @blitz_rank_one_horde
    assert @blitz_rank_one_horde > @blitz_rank_one_alliance
  end

  private
  def create_title name
    return Title.new(name + ": Season Foo", "Foo", 1548109980000)
  end
end