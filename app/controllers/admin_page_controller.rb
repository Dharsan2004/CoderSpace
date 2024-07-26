class AdminPageController < ApplicationController

  before_action :require_admin , only: [:users,:index]

  def index

  end

  def users
    @all_user = User.all
  end


end
