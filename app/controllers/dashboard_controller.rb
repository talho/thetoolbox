class DashboardController < ApplicationController
  before_filter :require_user
  
  def index
    redirect_to users_path
  end
end
