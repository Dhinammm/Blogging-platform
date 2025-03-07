class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ index new create show errorhandler logg not_found_method ]
  before_action :user_authenticate, only: %i[ destroy ]
  
  def index
    @users = User.all
  end
   
  def show
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      redirect_to errorhandler_path
    end
    begin
      @articles = Article.where("user_id = ?",params[:id])
    rescue ActiveRecord::RecordNotFound => e
      @articles = nil
    end
  end

  def new 
    if session[:user_id]
      redirect_to logg_path
    else
      @user = User.new
    end
  end

  def create 
    @user = User.new(user_params)
    if !User.where(name: @user.name).exists?
      if @user.save
        @user.update(password: @user.password_digest)
        @user.save
        redirect_to @user
      else
        render :new, status: :unprocessable_entity
      end
    else
      redirect_to errorhandler_path
    end
  end
  
  def destroy
    session[:user_id] = nil
    current_user = User.find(params[ :id ])
    begin
      article = Article.where("user_id = ?", params[:id])
    rescue
      article = nil
    end

    if !article.nil?
      article.each do |iterate|
        iterate.destroy
        iterate.save
      end
    end
    current_user.destroy
    redirect_to users_path
  end
  
  def errorhandler
  end
  
  def logg
  end

  def user_authenticate
    session_user = User.find_by(id: session[:user_id])
    current_user = User.find(params[:id])
    if current_user.id != session_user.id
      redirect_to new_session_path
    end
  end

  private
    def user_params
      params.expect(user:[ :name, :email_address, :password_digest ])
    end
end
