class SessionsController < ApplicationController
  def new
    if logged_in?

      if admin?
        redirect_to "/admin_page" , notice: "Logged In as Admin successfully"
      else
        redirect_to page_index_path, notice: 'Logged in successfully.'
      end
    end

  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      if admin?
        p "helo its admin"
        redirect_to "/admin_page" , notice: "Logged In as Admin successfully"
      else
        redirect_to page_index_path, notice: 'Logged in successfully.'
      end
    else
      flash.now[:alert] = 'Invalid email or password'
      render :new,status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'Logged out successfully.'
  end


end
