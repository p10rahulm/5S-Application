require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
include SessionsHelper

  def setup
    @article = articles(:two)
    @user1 = users(:rahul)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Article.count' do
      post :create, article: { content: "Lorem ipsum" }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Article.count' do
      delete :destroy, id: @article
    end
    assert_redirected_to login_url
  end
  test "should redirect destroy for wrong article" do
    log_in_as(@user1)
    article = articles(:one)
    assert_no_difference 'Article.count' do
      delete :destroy, id: article
    end
    assert_redirected_to root_url
  end
  test "should get new when logged in" do
    log_in_as(@user1)
    get :new
    content = "This article really ties the room together"
    title = "hello_how are you"
    #successful update
    assert_difference 'Article.count', 1 do
      post :create, article: { title: title, content: content }
    end
    log_out()
    assert_no_difference 'Article.count' do
      post :create, article: { title: title, content: content, user:@user1 }
    end


  end

  test "should redirect edit when not logged in" do
    get :edit, id: @article
    assert_not flash.empty?
    assert_redirected_to login_url
  end

end
