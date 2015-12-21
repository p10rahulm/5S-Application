require 'test_helper'
require 'helpers/application_helper_test'
class SiteLayoutTest < ActionDispatch::IntegrationTest
  # include ApplicationHelperTest
  def setup
    @user = users(:rahul)
    @non_admin_user = users(:hombalappa)
  end
  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    assert_select "a[href=?]", login_path
    get signup_path
    assert_select "title", full_title("Sign up")
  end
  test "layout links with login" do
    get root_path
    assert_template 'static_pages/home'
    log_in_as(@user)
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)

  end
end