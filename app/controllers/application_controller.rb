class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :admin?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_user
    unless logged_in?
      flash[:notice] = "You must be logged in first"
      redirect_to login_path
    end
  end

  def require_admin
    unless logged_in?
      flash[:warning] = "Login to continue"
      redirect_to login_path
    else
      unless current_user.is_admin
        flash[:warning] = "You are not authorized to view this page"
        redirect_to root_path
      end
    end
  end

  def admin?
    logged_in? && current_user&.is_admin
  end

  def user_points(user)
    easy_points = user.coding_problems.where(difficulty: :easy).count
    medium_points = user.coding_problems.where(difficulty: :medium).count * 2
    hard_points = user.coding_problems.where(difficulty: :hard).count * 3
    total_points = easy_points + medium_points + hard_points
    return total_points
  end

end
