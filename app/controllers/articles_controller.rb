class ArticlesController < ApplicationController
  before_action :logged_in_user, only: [:new, :edit, :update, :destroy, :create]
  before_action :correct_user, only: [:destroy, :edit, :update,]


  def new
    @article = Article.new
  end
  def index
    @articles = Article.paginate(page: params[:page], :per_page => 15)
  end
  def edit
    @article = Article.find(params[:id])
  end
  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(article_params)
      # Handle a successful update.
      flash[:success] = "Article updated"
      render 'show'
    else
      flash[:danger] = "Your article must have title and contents"
      render 'edit'
    end
  end
  def create
    @article = current_user.articles.build(article_params)
    if @article.save
      flash[:success] = "Article created!"
      redirect_to root_url
    else
      # @feed_items = []
      # render 'static_pages/home'
      flash[:danger] = "There were errors in your submission"
      redirect_to new_article_path
    end
  end


  def show
    @article = Article.find(params[:id])
    # redirect_to root_url and return unless @user.activated == true
    # @microposts = @user.microposts.paginate(page: params[:page], :per_page => 15)
    # @articles = @user.articles.paginate(page: params[:page], :per_page => 5)
    # @articles = truncate(sanitize(@user.articles.content)).paginate(page: params[:page], :per_page => 5)
    # debugger
  end

  def destroy
    @article.destroy
    flash[:success] = "Article deleted"
    redirect_to root_url
  end

  private

  def article_params
    params.require(:article).permit(:content, :title)
  end
  def correct_user
    @article = current_user.articles.find_by(id: params[:id])
    redirect_to root_url if @article.nil?
  end

end
