require "test_helper"

class RealmsTest < ActiveSupport::TestCase
  def test_get_a_list_of_realms
    assert_not_nil Realms.list
    assert_not_empty Realms.list

    realm = Realms.list.values.first
    assert_not_nil realm
    assert_not_nil realm.slug
    assert_not_nil realm.name
    assert_not_nil realm.region
  end
end
