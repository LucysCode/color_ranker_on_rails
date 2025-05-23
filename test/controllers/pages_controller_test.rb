require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get rank_color_pairs" do
    get pages_rank_color_pairs_url
    assert_response :success
  end
end
