class DashboardController < ApplicationController
  #before_filter :require_no_user, :only => [:cacti_graphs_login]
  #before_filter :require_user, :only => [:index]
  
  def index
    redirect_to users_path
  end

  def cacti_graphs_login
    @cacti_graph = true
    render :template => "cacti_graph/_login"
  end

  def cacti_graphs
    render :template => "cacti_graph/index"
  end
end
