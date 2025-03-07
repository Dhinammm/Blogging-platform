class ArticlesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show noarticlehandler not_found_method ]

  def index
    @articles = Article.all
  end
  
  def show
    begin 
      @article = Article.find(params[:id])
      @user = @article.user_id
    rescue
      redirect_to noarticlehandler_path
    end
  end
  
  def new
    begin
      @user = User.find(params[:user_id]) if params[:user_id].present?
      @article = Article.new(user_id: @user&.id)
    rescue
      redirect_to errorhandler_path
    end
    user = User.find_by(id: session[:user_id])
    current_user = User.find(params[:user_id])
    if current_user.id != user.id
      redirect_to new_session_path
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
    current_user = User.find_by(id: session[:user_id])
    @article = Article.find(params[:id])
    editing_user = @article.user_id
    if current_user.id == editing_user
      'Do nothing'
    else
      redirect_to new_session_path
    end
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
    account_owner = User.find(article.user_id)
    delete_user = User.find_by(id: session[:user_id])
    if account_owner.id != delete_user.id
      redirect_to new_session_path
    else
      article.destroy
      redirect_to user_path(account_owner)
    end
  end

  def noarticlehandler
  end
  
  def not_found_method
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: true
  end

  private
    def article_params
      params.expect(article: [:title, :content, :user_id])
    end
end
