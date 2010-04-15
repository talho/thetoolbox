class UsersController < ApplicationController

  def show
    @user = get_user
  end

  def reset_password
    @user = get_user
    if valid_params?
      @user.reset_password(params[:ldap_user][:new_password])
      @reset_result = true;
    else
      @reset_result = false;
    end
    render :action => 'show'
  end

  protected

  def valid_params?
    errors = ''
    if params[:ldap_user][:new_password].blank?
      errors = errors + "- Please enter a password.<br/>"
    end
    if params[:ldap_user][:confirm_password].blank? || (params[:ldap_user][:confirm_password] != params[:ldap_user][:new_password])
      errors = errors + "- Please confirm password.<br/>"
    end
    if !errors.blank?
      flash[:error] = "Please correct the following items:<br/>"+errors
      return false
    end
    return true
  end

  def get_user

    if current_user.nil? || current_user.admin?
      user = LdapUsers.find_by_id(params[:id])
    else
      cn = current_user.dn.split(",")[0].split('=')[1]
      ou = current_user.dn.split(",")[1].split('=')[1]
      user = LdapUsers.all :conditions => ['cn = "'+cn+'"  AND ou = "'+ou+'"']
      if user.first.nil?
        user = LdapUsers.create(:cn => cn, :ou => ou)
      else
        user = user.first
      end
    end
    user
  end

end