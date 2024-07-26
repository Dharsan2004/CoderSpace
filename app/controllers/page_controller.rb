class PageController < ApplicationController

  before_action :require_user , only:[:index,:leaderboard]

  def index
    @user=current_user
  end

  def show
    @user = User.find_by(id: params[:id])

    if @user.nil?
      flash[:alert] = "User not found."
      redirect_to root_path # Redirect to a safe page, such as the root page
    end
  end

  def leaderboard
    users = User.includes(:coding_problems).reject(&:is_admin?).sort_by { |user| -user_points(user) }
    @users = Kaminari.paginate_array(users).page(params[:page]).per(2)
    starting_number = (@users.current_page - 1) * @users.limit_value + 1
    @sno = starting_number..(starting_number + @users.count - 1)
  end



end
