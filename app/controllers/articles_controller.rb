class ArticlesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  def index
    @articles = Article.all
  end
  
  def show
   url = request.original_url
   if url.include?("/articles")
     @url = "/articles"
   else
     @url = "/users"
   end
   begin 
     @article = Article.find(params[:id])
     @user = @article.user_id
   rescue
     redirect_to errorhandler_path
   end
  end
  
  def new
    begin
      @user = User.find(params[:user_id]) if params[:user_id].present?
      @article = Article.new(user_id: @user&.id)
    rescue
      redirect_to errorhandler_path
    end
  end
  
  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit 
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    article = Article.find(params[:id])
    user = User.find(article.user_id)
    article.destroy
    redirect_to user
  end
  
  private
    def article_params
      params.expect(article: [:title, :content, :user_id])
    end
end
