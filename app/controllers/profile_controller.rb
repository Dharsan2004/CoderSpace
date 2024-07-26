class ProfileController < ApplicationController

  before_action :require_user , only: [:show]
  before_action :require_admin , only: [:index,:destroy]
  before_action :require_same_user , only: [:edit, :update]


  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])

    if @user.nil?
      flash.now[:notice] = "User not found."
      if admin?
        redirect_to "/admin_page"
      else
        redirect_to "/page"
      end
    end

  end

  def edit
    @user = User.find_by(id: params[:id])

    if @user.nil?
      if admin?
        redirect_to "/admin_page"
      else
        redirect_to "/page"
      end
    end

  end

  def update
    p params
    @user = User.find_by(id: params[:id])

    if @user.nil?
      flash[:alert] = "User not found."
      if admin?
        redirect_to "/admin_page"
      else
        redirect_to "/page"
      end

    else


      @user.name = params[:user][:name]
      @user.email = params[:user][:email]
      @user.password = params[:user][:password]
      @user.college = params[:user][:college]
      @user.profile_image = params[:user][:profile_image]
      @user.linkedin_link = params[:user][:linkedin_link]

      if @user.profile_image.attached? && !valid_image_format?(@user.profile_image)
        flash.now[:alert] = "Please upload a PNG or JPEG image."

        render :edit, status: :unprocessable_entity
        return
      end

      if @user.save
        flash[:notice] = "User is Edited #{@user.name}"
        redirect_to profile_path(@user)
      else
        render :edit, status: :unprocessable_entity
      end

    end

  end

  def destroy
    @user = User.find_by(id: params[:id])

    if @user.nil?
      flash[:alert] = "User not found."
      redirect_to "/users_admin"
    else
      @user.destroy
      flash[:notice] = "User was deleted successfully."
      redirect_to "/users_admin"
    end
  end



private
  def user_params
    params.require(user).permit(:name, :email, :college, :profile_image, :linkedin_link, :password)
  end

  def require_same_user
    @a = User.find_by(id: params[:id])

    if @a.nil?
      flash[:alert] = "User not found."
      redirect_to root_path
    elsif session[:user_id] != @a.id && !admin?
      flash[:alert] = "You can only edit or delete your own profile."
      redirect_to profile_path(@a)
    end
  end

  def valid_image_format?(image)
    image.content_type.in?(%w[image/jpeg image/png])
  end


end
