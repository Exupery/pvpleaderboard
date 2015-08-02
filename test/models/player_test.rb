require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  test "should calculate win ratio" do
    player = create_player("Tron", "ENCOM", 100, 50)

    assert_not_nil player
    assert_not_nil player.win_ratio
    assert player.win_ratio == 66.7
  end

  test "should create an armory link" do
    player = create_player("Tron", "ENCOM", 100, 50)

    assert_not_nil player
    assert_not_nil player.armory_link
    assert player.armory_link == "https://us.battle.net/wow/en/character/ENCOM/Tron/advanced"
  end

  def create_player(name, realm, wins, losses)
    hash = Hash.new

    hash["ranking"] = 1
    hash["rating"] = 2000
    hash["wins"] = wins
    hash["losses"] = losses
    hash["name"] = name
    hash["faction"] = "Horde"
    hash["race"] = "Goblin"
    hash["gender"] = 0
    hash["class"] = "Hunter"
    hash["spec"] = "Beast Mastery"
    hash["realm"] = realm
    hash["realm_slug"] = realm
    hash["guild"] = "Tyranny"

    return Player.new hash
  end
end
