class UsersController < ApplicationController
  verify :method => :get, :only => [ :delete, :enable_user, :forgot_password ], :redirect_to => { :action => :index }

  def index
    user = User.find_by_login(current_user[:login])
    if user.is_admin?
      current_user.refresh_ou_members
      @ldap_user_results = User.paginate(:page => params[:page], :per_page => 10, :conditions => ["ou = ?", user.ou])
    else
      redirect_to user_path(current_user)
    end
    @new_user = User.new
  end


  def show
    @user = User.find(params[:id])
  end

  def create
    unless !valid_params?
      ldap = ldap_connect
      unless ldap
        return false
      end
      dn   = "CN=" + params[:user][:first_name] + " " + params[:user][:last_name] + ",OU=TALHO," + LDAP_Config[:base][LDAP_Config[:auth_to]]
      attr = {
        :cn                 => params[:user][:first_name] + " " + params[:user][:last_name],
        :name               => params[:user][:first_name] + " " + params[:user][:last_name],
        :displayName        => params[:user][:first_name] + " " + params[:user][:last_name],
        :distinguishedName  => dn,
        :givenName          => params[:user][:first_name],
        :samAccountName     => params[:user][:logon_name],
        :userPrincipalName  => params[:user][:logon_name] + "@" + dn.split(",")[dn.split(",").size - 2].split("=")[1] + "." + dn.split(",")[dn.split(",").size - 1].split("=")[1],
        :unicodePwd         => microsoft_encode_password(params[:user][:password]),
        :objectclass        => ["top", "User"],
        :sn                 => params[:user][:last_name]
      }
      if params[:user][:ch_pwd]
        attr[:pwdLastSet] = "0"
      end
      if params[:user][:vpn_usr] != "0"
        attr[:samAccountName] += "-vpn"
      end
      if params[:user][:acct_dsbl].to_i == 1
        if params[:user][:pwd_exp].to_i == 1
          attr[:userAccountControl] = "66050"
        else
          attr[:userAccountControl] = "514"
        end
      else
        if params[:user][:pwd_exp].to_i == 1
          attr[:userAccountControl] = "66048"
        else
          attr[:userAccountControl] = "512"
        end
      end

      ldap.add(:dn => dn, :attributes => attr)

      if !ldap.get_operation_result.code.nil? && ldap.get_operation_result.code != 0
        flash[:error] = ldap.get_operation_result.message
      else
        e = ExchangeUser.create(:domain => attr[:userPrincipalName].split('@')[1], :alias => attr[:userPrincipalName].split('@')[0])
        #todo: Place delayed jobs, after creating mailbox notify admin
        if e.attributes["mailboxEnabled"] != "true"
          flash[:completed] = "User added, but was not able to set up mailbox.  You can try to enable the mailbox again by enabling the user, or contact your administrator."
        else
          flash[:completed] = "User added"
        end
      end
    end
    redirect_to users_path
  end

  def delete
    ldap_user = User.find_by_id(params[:id])
    e = ExchangeUser.find(ldap_user.email)
    unless e.attributes["upn"].blank?
      e.destroy
      ldap_user.destroy
      flash[:completed] = "User deleted."
    else
      flash[:error] = "Unable to delete user, please contact your administrator."
    end
    redirect_to users_path
  end

  def create_white_list_entry
    pref = nil 
    unless params[:wl_domain].blank? || current_user.email.blank?
      if !params[:wl_domain][:domain].blank?
        begin
          pref = WhiteList.create :username => domainize(current_user.email), :value => params[:wl_domain][:domain]
          flash[:notice] = "Domain added to White List"
        rescue
          flash[:error] = "Unable to add white list entry."
        end
      elsif !params[:wl_domain][:email].blank?
        begin
          pref = WhiteList.create :username => domainize(current_user.email), :value => params[:wl_domain][:email]
          flash[:notice] = "Email added to White List"
        rescue
          flash[:error] = "Unable to add white list entry."  
        end
      else
        flash[:error] = "You do not have access to this record or there was an error processing your request."
      end
    end
    redirect_to users_path
  end
  
  def toggle
    user = User.find(params[:id])
    if user
      user.toggle
      if !user.enabled
        flash[:notice] = "User Enabled"
      else
        flash[:notice] = "User Disabled"
      end
    else
      flash[:error] = "You do not have access to this record or there was an error processing your request."
    end
    redirect_to users_path
  end

  def forgot_password
    @forgot_password
  end
                                                                                                    
  def reset_password
    @user = User.find(params[:id])
    if valid_password_params?
      if @user.reset_password(params[:ldap_user][:new_password])
        flash[:notice] = "Password changed successfully";
      else
        flash[:error]  = "You do not have access to this record or there was an error processing your request."
      end
    end
    redirect_to user_path(@user)
  end


  protected

  def valid_password_params?
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

  def microsoft_encode_password(pwd)
    newPass = ""
    pwd     = "\"" + pwd + "\""
    pwd.length.times{|i| newPass += "#{pwd[i..i]}\000"}
    newPass
  end

  def valid_params?
    errors = ''
    if params[:user][:first_name].blank?
      errors = errors + "- Please enter a first name.<br/>"
    end
    if params[:user][:last_name].blank?
      errors = errors + "- Please enter a last name.<br/>"
    end
    if params[:user][:logon_name].blank?
      errors = errors + "- Please enter a log on name.<br/>"
    end
    if params[:user][:password].blank?
      errors = errors + "- Please enter a password.<br/>"
    end
    if params[:user][:confirm_password].blank?
      errors = errors + "- Please confirm password.<br/>"
    end
    if !errors.blank?
      flash[:error] = "Please correct the following items:<br/>"+errors
      return false
    end
    return true
  end

  def ldap_connect
    begin
      ldap = Net::LDAP.new(
        :host       => LDAP_Config[:host][LDAP_Config[:auth_to]],
        :port       => LDAP_Config[:port].to_i,
        :encryption => :simple_tls,
        :auth       => {:method => :simple, :username => LDAP_Config[:username][LDAP_Config[:auth_to]], :password => LDAP_Config[:password]})
    rescue
      return false
    end
    unless ldap.bind
      return false
    end
    ldap
  end
end