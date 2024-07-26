class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render 'not_found', status: :not_found }
      format.json { render json: { error: 'Not Found' }, status: :not_found }
      format.all { render plain: 'Not Found', status: :not_found }
    end
  end
end
