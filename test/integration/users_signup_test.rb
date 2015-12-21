require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name: "",
                               email: "user@invalid",
                               password: "foo",
                               password_confirmation: "bar" }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
    assert_select 'div#error_explanation > ul > li:nth-child(1)', "Name can't be blank"
    assert_select 'div#error_explanation > ul > li:nth-child(2)', "Email is invalid"
    assert_select 'div#error_explanation > ul > li:nth-child(3)', "Password confirmation doesn't match Password"
    assert_select 'div#error_explanation > ul > li:nth-child(4)',
                  "Password confirmation is too short (minimum is 6 characters)"
    assert_select 'div#error_explanation > ul > li:nth-child(5)', "Password is too short (minimum is 6 characters)"

  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name: "Example1 User",
                                            email: "user1@example.com",
                                            password: "password",
                                            password_confirmation: "password" }
    end

  end


  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: { name: "Example User",
                               email: "user@example.com",
                               password: "password",
                               password_confirmation: "password" }
    end
    #Check that only 1 mail has been sent
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
    assert_not flash.nil?
    flashassertion = false
    flash.each do |messagetype, message|
       flashassertion = true if messagetype == "success" && message == "Account activated! Welcome to the Sample App!"
    end
    assert flashassertion

  end

  test "ensure non-activated users not showing on index page and profile page" do

    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: { name: "Example User",
                               email: "user@example.com",
                               password: "password",
                               password_confirmation: "password" }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    log_in_as(user)
    assert_not is_logged_in?
    other_user = users(:rahul)
    log_in_as(other_user)
    get users_path
    assert_no_match response.body, user.name
    get users_path, page:2
    assert_no_match response.body, user.name
    get user_path(user)
    assert_redirected_to root_url
    delete logout_path
  end


end
