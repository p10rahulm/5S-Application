require 'test_helper'

class ArticleTest < ActiveSupport::TestCase

  def setup
    @user = users(:rahul)
    @article = Article.new(title: "This is my first post", content: "hellow how are you", user_id:@user.id)
  end

  test "this is valid" do
    assert @article.valid?
  end

  test "user id and title should be present" do
    @article.user_id = nil
    assert_not @article.valid?
    @article.title = nil
    assert_not @article.valid?
    @article.user_id = nil
    assert_not @article.valid?
    @article.content = nil
    assert_not @article.valid?
  end


end
