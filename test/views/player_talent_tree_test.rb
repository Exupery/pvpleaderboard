require "test_helper"

class PlayerTalentTreeTest < ActionView::TestCase
  helper TalentsHelper

  # A hero tree's shape: one talent on top, full rows in the middle, and
  # one talent on the bottom that doesn't sit in the first column
  @@hero_talents = {
    [1, 2] => "Top",
    [2, 1] => "Left", [2, 2] => "Middle", [2, 3] => "Right",
    [3, 3] => "Bottom"
  }.to_h { |(row, col), name|
    ["#{row}-#{col}", { :id => row * 10 + col, :spell_id => row * 10 + col, :name => name, :icon => "placeholder", :row => row, :col => col }]
  }

  def setup
    @player = Player.new({})
  end

  def test_center_first_and_last_hero_talents
    render_tree(center_ends: true)

    assert_select "tr:first-child td", 1
    assert_select "tr:first-child td[colspan='3']", text: "Top"
    assert_select "tr:last-child td", 1
    assert_select "tr:last-child td[colspan='3']", text: "Bottom"
    assert_select "tr:nth-child(2) td", 3
    assert_select "td[colspan]", 2
  end

  def test_keep_talents_in_their_columns_by_default
    render_tree

    assert_select "tr td", 9
    assert_select "td[colspan]", 0
    assert_select "tr:first-child td:nth-child(2)", text: "Top"
    assert_select "tr:last-child td:nth-child(3)", text: "Bottom"
  end

  private

  def render_tree(**locals)
    render partial: "player/talent_tree", locals: { talents: @@hero_talents, all_talents: @@hero_talents }.merge(locals)
  end
end
