require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  def initialize arg
    super arg
    @player = create_player
  end

  test "should calculate win ratio" do
    assert_not_nil @player
    assert_not_nil @player.win_ratio
    assert @player.win_ratio == 66.7
  end

  test "should create an armory link" do
    assert_not_nil @player
    assert_not_nil @player.armory_link
    assert @player.armory_link == "https://worldofwarcraft.com/en-us/character/ENCOM/Tron"
  end

  def create_player
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

    return Player.new hash
  end
end
