class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    LDAP_Config[:host_to_auth] = LDAP_Config[:host][params[:host][:authenticate]]
    LDAP_Config[:user_to_auth] = LDAP_Config[:username][params[:host][:authenticate]]
    LDAP_Config[:base_to_auth] = LDAP_Config[:base][params[:host][:authenticate]]

    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end

end