require 'test_helper'
class ApplicationHelperTest < ActionView::TestCase
  test "fill title helper"do
    assert_equal full_title, "Shingo Institute 5S App"
    assert_equal full_title("Help"), "Help | Shingo Institute 5S App"
  end

end
