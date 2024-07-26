class UsersController < ApplicationController
  def new
    if logged_in?

      if admin?
        redirect_to "/admin_page" , notice: "Logged In as Admin successfully"
      else
        redirect_to page_index_path, notice: 'Logged in successfully.'
      end
    end

    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.is_admin = false
    if @user.save
      session[:user_id] = @user.id
      redirect_to "/page", notice: 'Signed up successfully.'
    else
      flash[:alert] = "User is not created"
      render :new,status: :unprocessable_entity
    end

  end



  private

  def user_params
    params.permit(:name, :email, :college, :profile_image, :linkedin_link, :password)
  end
end
