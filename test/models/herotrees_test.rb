require "test_helper"
require "minitest/mock"

class HerotreesTest < ActiveSupport::TestCase
  # Monk trees, plus the kind of placeholder tree Blizzard mixes into the
  # Druid spec responses - "Red [DNT]" shares Keeper of the Grove's specs,
  # so it has to be dropped by id or it wins the spec set
  @@INDEX = {
    "hero_talent_trees" => [
      {"id" => 64, "name" => "Conduit of the Celestials"},
      {"id" => 65, "name" => "Shado-Pan"},
      {"id" => 66, "name" => "Master of Harmony"},
      {"id" => 23, "name" => "Keeper of the Grove"}
    ]
  }

  @@SPEC_TREES = {
    268 => [[66, "Master of Harmony"], [65, "Shado-Pan"]],
    269 => [[65, "Shado-Pan"], [64, "Conduit of the Celestials"]],
    270 => [[66, "Master of Harmony"], [64, "Conduit of the Celestials"]],
    102 => [[23, "Keeper of the Grove"], [12, "Red [DNT]"]],
    105 => [[23, "Keeper of the Grove"], [12, "Red [DNT]"]]
  }

  @@CLASS_IDS = {268 => 10, 269 => 10, 270 => 10, 102 => 11, 105 => 11}

  def setup
    Herotrees.reset!
  end

  def teardown
    Herotrees.reset!
  end

  def with_stubbed_api
    Herotrees.stub(:api_enabled?, true) do
      Herotrees.stub(:create_headers, {}) do
        Herotrees.stub(:get, ->(uri, _headers) { api_response uri }) do
          yield
        end
      end
    end
  end

  def api_response uri
    return @@INDEX if uri.include? "talent-tree/index"

    spec_id = uri[%r{playable-specialization/(\d+)}, 1].to_i
    trees = @@SPEC_TREES[spec_id]
    return Hash.new if trees.nil?

    return {
      "playable_class" => {"id" => @@CLASS_IDS[spec_id]},
      "hero_talent_trees" => trees.map { |id, name| {"id" => id, "name" => name} }
    }
  end

  def test_builds_trees_keyed_by_spec_set
    with_stubbed_api do
      trees = Herotrees.list

      assert_equal "Master of Harmony", trees["268_270"][:name]
      assert_equal "Shado-Pan", trees["268_269"][:name]
      assert_equal "Conduit of the Celestials", trees["269_270"][:name]
      assert_equal [268, 270], trees["268_270"][:specs]
      assert_equal 10, trees["268_270"][:class_id]
    end
  end

  def test_ignore_trees_missing_from_the_index
    with_stubbed_api do
      trees = Herotrees.list

      assert_equal "Keeper of the Grove", trees["102_105"][:name]
      assert_empty trees.values.select { |tree| tree[:name].include? "DNT" }
    end
  end

  def test_slugify_names
    with_stubbed_api do
      assert_equal "master-of-harmony", Herotrees.list["268_270"][:slug]
      assert_equal "conduit-of-the-celestials", Herotrees.list["269_270"][:slug]
    end
  end

  def test_for_spec_returns_both_trees_sorted_by_name
    with_stubbed_api do
      assert_equal ["Conduit of the Celestials", "Master of Harmony"],
        Herotrees.for_spec(270).map { |tree| tree[:name] }
      assert_equal ["Conduit of the Celestials", "Shado-Pan"],
        Herotrees.for_spec(269).map { |tree| tree[:name] }
    end
  end

  def test_for_spec_without_a_spec
    with_stubbed_api do
      assert_empty Herotrees.for_spec(nil)
      assert_empty Herotrees.for_spec("270")
    end
  end

  def test_find_only_matches_trees_the_spec_can_pick
    with_stubbed_api do
      assert_equal 66, Herotrees.find(270, "master-of-harmony")[:id]
      assert_nil Herotrees.find(270, "shado-pan")
      assert_nil Herotrees.find(270, "not-a-tree")
      assert_nil Herotrees.find(270, nil)
    end
  end

  def test_name_for_spec_set
    with_stubbed_api do
      assert_equal "Master of Harmony", Herotrees.name_for("268_270")
      assert_nil Herotrees.name_for("268_271")
    end
  end

  def test_fall_back_to_first_talent_names_when_the_api_fails
    Herotrees.stub(:api_enabled?, true) do
      Herotrees.stub(:create_headers, nil) do
        trees = Herotrees.list

        assert_not_empty trees
        trees.each_value do |tree|
          assert_nil tree[:id]
          assert_not_nil tree[:name]
          assert_equal tree[:slug], tree[:slug].downcase
          assert_no_match(/[^a-z0-9\-]/, tree[:slug])
        end
      end
    end
  end

  def test_fall_back_when_the_api_is_disabled
    # What the test environment does, so no stubbing needed
    assert_not_empty Herotrees.list
  end
end
