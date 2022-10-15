require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  def initialize arg
    super arg
    @player = create_player nil
  end

  def test_calculate_win_ratio
    assert_not_nil @player
    assert_not_nil @player.win_ratio
    assert @player.win_ratio == 66.7
  end

  def test_create_an_armory_link
    assert_not_nil @player
    assert_not_nil @player.armory_link
    assert @player.armory_link == "https://worldofwarcraft.com/en-us/character/ENCOM/Tron"
  end

  def test_audit_calculations
    player = create_auditable_player

    assert_not_nil player.ratings
    assert_not_nil player.titles
    assert_not_nil player.dates

    ## Verify seasons are reverse chrono order
    assert player.titles[0].name == "Rival"
    assert player.titles[0].season == "Foo Season 2"
    assert player.titles[1].name == "Gladiator"
    assert player.titles[1].season == "Foo Season 1"

    assert player.dates[0].char_date == 2000
    assert player.dates[0].alt_date.nil?
    assert player.dates[0].raw_date == player.dates[0].char_date
    assert player.dates[1].alt_date == 1000
    assert player.dates[1].char_date.nil?
    assert player.dates[1].raw_date == player.dates[1].alt_date
    assert player.dates[2].alt_date == 3000
    assert player.dates[2].char_date.nil?
    assert player.dates[2].raw_date == player.dates[2].alt_date
  end

  def create_auditable_player
    audit_props = Hash.new

    audit_props["ratings"] = { "2v2" => { "high" => 1701 }, "3v3" => {} }
    audit_props["titles"] = [
      Title.new("Rival: Foo Season 1", "rival", 1101240666),
      Title.new("Gladiator: Foo Season 1", "gladiator", 1701666666),
      Title.new("Duelist: Foo Season 1", "duelist", 1101240777),
      Title.new("Rival: Foo Season 2", "rival", 1101240999)
    ]
    ra = PlayerAchievement.get_rating_achievements
    audit_props["achiev_dates"] = {
      ## 2v2 1550 earned on this char
      399 => PlayerAchievement.new(ra[399], 2000),
      ## 2v2 1750 earned on another char (older timestamp)
      400 => PlayerAchievement.new(ra[400], 1000),
      ## 3v3 1550 earon on another char (no 3v3 ratings info for this char)
      402 => PlayerAchievement.new(ra[402], 3000)
    }

    return create_player audit_props
  end

  def create_player audit_props
    hash = Hash.new

    hash["ranking"] = 1
    hash["rating"] = 2000
    hash["wins"] = 100
    hash["losses"] = 50
    hash["name"] = "Tron"
    hash["faction"] = "Horde"
    hash["race"] = "Goblin"
    hash["gender"] = 0
    hash["class"] = "Hunter"
    hash["spec"] = "Beast Mastery"
    hash["spec_icon"] = "ability_hunter_bestialdiscipline"
    hash["realm"] = "ENCOM"
    hash["realm_slug"] = "ENCOM"
    hash["region"] = "US"
    hash["guild"] = "Tyranny"

    hash["ratings"] = audit_props["ratings"] unless audit_props.nil?
    hash["titles"] = audit_props["titles"] unless audit_props.nil?
    hash["achiev_dates"] = audit_props["achiev_dates"] unless audit_props.nil?

    return Player.new hash
  end
end
