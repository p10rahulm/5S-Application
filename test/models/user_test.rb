require 'test_helper'
class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")

  end
  test "should be valid" do
    assert @user.valid?
  end
  test "name should be present" do
    @user.name = "   "
    assert_not @user.valid?
  end
  test "email should be present" do
    @user.email = "   "
    assert_not @user.valid?
  end
  test "name is not too long" do
    @user.name = "a"*51
    assert_not  @user.valid?
  end
  test "email is not too long" do
    @user.email = "a"*244+"@example.com"
    assert_not @user.valid?
  end
  test "email addresses is unique" do
    @duplicate = @user.dup
    @user.save
    assert_not @duplicate.valid?
  end
  test "valid email IDs" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end


  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
foo@bar_baz.com foo@bar+baz.com]

    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "password has minimum length" do
    @user.password = "a"*5
    @user.password_confirmation = @user.password
    assert_not @user.valid?
  end
  test "password not blank" do
    @user.password = " "*6
    @user.password_confirmation = @user.password
    assert_not @user.valid?
  end
  test "email should be unique" do
    @duplicateuser = @user.dup
    @duplicateuser.email = @user.email.upcase
    @user.save
    assert_not @duplicateuser.valid?

  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember,'')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    rahul = users(:rahul)
    hombalappa = users(:hombalappa)
    assert_not rahul.following?(hombalappa)
    rahul.follow(hombalappa)
    assert rahul.following?(hombalappa)
    assert hombalappa.followers.include?(rahul)
    rahul.unfollow(hombalappa)
    assert_not rahul.following?(hombalappa)
    assert_not hombalappa.followers.include?(rahul)
  end

  test "feed should have the right posts" do
    rahul = users(:rahul)
    hombalappa = users(:hombalappa)
    lana = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert rahul.feed.include?(post_following)
    end
    # Posts from self
    rahul.microposts.each do |post_self|
      assert rahul.feed.include?(post_self)
    end
    # Posts from unfollowed user
    hombalappa.microposts.each do |post_unfollowed|
      assert_not rahul.feed.include?(post_unfollowed)
    end
  end

end
