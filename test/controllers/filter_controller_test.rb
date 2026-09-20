require "test_helper"

class FilterControllerTest < ActionDispatch::IntegrationTest
  def test_set_title_and_description
    get "/pvp/filter"
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  def test_redirect_if_no_class_or_spec
    get "/pvp/filter/results"
    assert_response :redirect

    get("/pvp/filter/results", params: {class: "death-knight"})
    assert_response :redirect

    get("/pvp/filter/results", params: {spec: "frost"})
    assert_response :redirect
  end

  def test_get_selected_params
    get("/pvp/filter/results", params: {class: "mage", spec: "frost"})
    assert_response :success
    assert_not_nil assigns(:selected)
    assert_not_empty assigns(:selected)
    assert_not_nil  assigns(:selected)[:class]
  end

  def test_find_filtered_results
    base_params = {class: "mage", spec: "frost"}
    test_params = [
      base_params,
      base_params.merge({factions: "alliance"}),
      base_params.merge({races: "tauren"}),
      base_params.merge({realm: "realm0"}),
      base_params.merge({leaderboards: "3v3"}),
      base_params.merge({regions: "EU"}),
      base_params.merge({name: "player"}),
      base_params.merge({"cr-bracket": "2v2", "current-rating": 2000}),
      base_params.merge({"active-since": 12}),
      base_params.merge({"arena-achievements": 5341}),
      base_params.merge({"rbg-achievements": "5341-5355"}),
      base_params.merge({"arena-achievements": 5341, "rbg-achievements": "5341-5355"}),
    ]

    test_params.each do |params|
      get("/pvp/filter/results", params: params)

      assert_response :success
      assert_not_equal(0, @controller.instance_variable_get(:@total), "No players returned for #{params}")
      assert_not_nil assigns(:class_id)
      assert_not_nil assigns(:class_talent_counts)
      assert_not_nil assigns(:spec_talent_counts)
      assert_not_nil assigns(:pvp_talent_counts)
      assert_not_nil assigns(:stat_counts)
      assert_not_nil assigns(:gear)
      assert_not_nil assigns(:total)
      assert_not_nil assigns(:players_title)
      assert_not_nil assigns(:top_players)
    end
  end

  def test_filter_by_hero_tree
    base_params = {class: "mage", spec: "frost"}
    get("/pvp/filter/results", params: base_params)
    total = @controller.instance_variable_get(:@total)

    trees = Herotrees.for_spec(64)
    assert_equal 2, trees.length

    narrowed = trees.map do |tree|
      get("/pvp/filter/results", params: base_params.merge({"hero-tree": tree[:slug]}))

      assert_response :success
      count = @controller.instance_variable_get(:@total)
      assert_operator count, :>, 0, "No players returned for #{tree[:slug]}"
      assert_operator count, :<, total, "#{tree[:slug]} did not narrow the results"
      count
    end

    assert_equal total, narrowed.sum, "Every player should land in exactly one hero tree"
  end

  def test_ignore_unknown_hero_tree
    base_params = {class: "mage", spec: "frost"}
    get("/pvp/filter/results", params: base_params)
    total = @controller.instance_variable_get(:@total)

    # A tree another spec owns is no more selectable than a made up one
    other_spec_tree = Herotrees.for_spec(65).first
    [other_spec_tree.nil? ? "not-a-tree" : other_spec_tree[:slug], "not-a-tree", ""].each do |slug|
      get("/pvp/filter/results", params: base_params.merge({"hero-tree": slug}))

      assert_response :success
      assert_equal total, @controller.instance_variable_get(:@total), "#{slug} should not have filtered"
    end
  end
end
