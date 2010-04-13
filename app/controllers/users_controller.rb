class UsersController < ApplicationController

  def show
    @user = LdapUsers.find_by_id(params[:id])
  end

  def reset_password
    ldap_user    = LdapUsers.find_by_id(params[:id])
    @reset_result = ldap_user.reset_password(params[:users][:new_password])
    render :action => 'show'
  end

end