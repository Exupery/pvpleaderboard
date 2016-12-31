require "test_helper"

class RealmsTest < ActiveSupport::TestCase
  test "should get a list of realms" do
    assert_not_nil Realms.list
    assert_not_empty Realms.list

    Realms.list.each do |slug, realm|
      assert_not_nil realm
      assert_not_nil realm.slug
      assert_not_nil realm.name
      assert_not_nil realm.region
    end
  end
end
