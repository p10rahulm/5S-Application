require 'test_helper'

class NewArticleTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:rahul)
    @article = articles(:two)
    @notmyarticle = articles(:one)
  end

  test "new article" do
    get new_article_path()
    assert_redirected_to login_url
    log_in_as(@user)
    get new_article_path()
    assert_template 'articles/new'
    content = "This article really ties the room together"
    title = "hello_how are you"
    title2 = "a"*257
    #unsuccessful updates
    assert_difference 'Article.count', 0 do
      post articles_path, article: { title: "", content: content }
    end
    assert_difference 'Article.count', 0 do
      post articles_path, article: { title: title, content: "" }
    end
    assert_difference 'Article.count', 0 do
      post articles_path, article: { title: title2, content: content }
    end
    #successful update
    assert_difference 'Article.count', 1 do
      post articles_path, article: { title: title, content: content }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body

  end

  test "article edit" do
    log_in_as(@user)
    #create new article to edit
    get new_article_path(@user)
    assert_template 'articles/new'
    content = "This article really ties the room together"
    title = "hello_how are you"
    assert_difference 'Article.count', 1 do
      post articles_path, article: { title: title, content: content }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_not flash.empty?

    @article2 = Article.find_by title: title
    assert_match @article2.title, response.body
    assert_match @article2.content, response.body
    assert_equal @article2.title, title
    assert_equal @article2.content, content
    get article_path(@article2)
    assert_match @article2.title, response.body
    assert_match @article2.content, response.body
    # binding.pry
    assert_match 'Delete' , response.body
    assert_match 'Edit' , response.body
    assert_select 'span.Edit-Link'
    assert_select 'span.Delete-Link'

    #Get down to editing
    get edit_article_path(@article2)
    assert_template 'articles/edit'
    patch article_path(@article2), article: { title: "",
                                    content: "foo@invalid"
    }
    @article2.reload
    assert_not_equal @article2.content,"foo@invalid"
    assert_not_equal @article2.title,""


    assert_template 'articles/edit'
    patch article_path(@article2), article: { title: "goodtitle",
                                              content: ""
    }
    @article2.reload
    assert_not_equal @article2.content,""
    assert_not_equal @article2.title,"goodtitle"

    assert_template 'articles/edit'
    titlenew = "goodtitle"
    contentnew = "goodcontent"
    patch article_path(@article2), article: { title: titlenew,
                                              content: contentnew    }
    @article2.reload
    assert_equal @article2.title, titlenew
    assert_equal @article2.content, contentnew

    assert_template 'articles/show'

    #try for editing my own old article
    get edit_article_path(@article)
    assert_template 'articles/edit'

    patch article_path(@article), article: { title: "",
                                              content: contentnew
    }
    @article.reload
    assert_not_equal @article.content,contentnew
    assert_not_equal @article.title,""

    assert_template 'articles/edit'
    patch article_path(@article), article: { title: titlenew,
                                              content: ""
    }
    @article.reload
    assert_not_equal @article.content,""
    assert_not_equal @article.title,titlenew
    assert_template 'articles/edit'
    patch article_path(@article), article: { title: titlenew,
                                             content: contentnew    }
    assert_template 'articles/show'
    @article.reload
    assert_equal @article.title, titlenew
    assert_equal @article.content, contentnew
    assert_select 'span.Edit-Link'
    assert_select 'span.Delete-Link'



    #try for editing another person's article
    get article_path(@notmyarticle)
    assert_select 'span.Edit-Link', count: 0
    assert_select 'span.Delete-Link', count: 0


    get edit_article_path(@notmyarticle)

    assert_redirected_to root_url

  end
  test "successful edit without initial login" do
    get edit_article_path(@article)
    @test_path=request.url
    assert_equal session[:forwarding_url], @test_path
    log_in_as(@user)
    assert_redirected_to edit_article_path(@article)
    follow_redirect!
    title = "Roses are red and violets are blue"
    content = "I feel sweet but not as sweet as you"
    patch article_path(@article), article: { title: title,
                                             content: content    }
    @article.reload
    assert_not flash.empty?
    assert_template 'articles/show'
    assert_match content, response.body
    assert_match title, response.body
    @article.reload
    assert_equal title, @article.title
    assert_equal content, @article.content

    assert_nil session[:forwarding_url]
  end


  test "article index including pagination" do
    log_in_as(@user)
    get articles_path
    assert_template 'articles/index'
    assert_select 'div.pagination'
    Article.paginate(page: 1, :per_page => 15).each do |article|
      assert_select 'a[href=?]', article_path(article), text: article.title
    end
  end
  test "article index as owner including pagination and delete links" do
    log_in_as(@user)
    get articles_path
    assert_template 'articles/index'
    assert_select 'div.pagination'
    first_page_of_articles = Article.paginate(page: 1, :per_page => 15)
    first_page_of_articles.each do |article|
      assert_select 'a[href=?]', article_path(article), text: article.title
      if article.user == @user
        assert_select 'a[data-method]', text: 'delete'
        @deletion_article = article
      end
    end
    assert_difference 'Article.count', -1 do
      delete article_path(@deletion_article)
    end
  end

  test "delete articles" do
    log_in_as(@user)
    get articles_path
    first_page_of_articles = Article.paginate(page: 1, :per_page => 15)
    first_page_of_articles.each do |article|
      assert_select 'a[href=?]', article_path(article), text: article.title
      if article.user == @user
        assert_select 'a[data-method]', text: 'delete'
        @deletion_article = article
      end
      if article.user != @user
        @non_deletion_article = article
      end
    end
    assert_difference 'Article.count', -1 do
      delete article_path(@deletion_article)
    end
    assert_difference 'Article.count', 0 do
      delete article_path(@non_deletion_article)
    end


  end

  test "index as not logged in" do
    get articles_path
    assert_select 'a', text: 'delete', count: 0
  end


end
