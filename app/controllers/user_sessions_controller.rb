class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    begin
      LDAP_Config[:auth_to] = params[:host][:authenticate]
      @user_session         = UserSession.new(params[:user_session])
      if @user_session.save
        flash[:completed] = "Login successful!"
        redirect_to dashboard_path
      else
        current_user_session.destroy unless current_user_session.blank?
        render :action => :new
      end
    rescue
      flash[:error] = "The exchange restful service is currently down, please contact your administrator."
      redirect_back_or_default new_user_session_url
    end
  end

  def destroy
    current_user_session.destroy
    flash[:completed] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end

end