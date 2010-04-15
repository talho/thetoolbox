class DashboardController < ApplicationController
  def index
    lines   = current_user[:dn].split(",")
    user_ou = Hash.new
    user    = User.find_by_login(current_user[:login])
    lines.each{|i| user_ou[i.split("=")[0]] = i.split("=")[1]}
    if user.is_admin?
      @ldap_user_results = user.ous(user_ou['OU']).paginate(:page => params[:page], :per_page => 10)
    else
      redirect_to "/users/#{current_user.id}"
    end
  end

  verify :method => :put, :only => [ :create_new_user ], :redirect_to => { :action => :index }
  verify :method => :get, :only => [ :delete_user, :forgot_password ], :redirect_to => { :action => :index }

  def create_new_user
    unless !valid_params?
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

      if params[:user][:acct_dsbl].to_i == 1
        if params[:user][:pwd_exp].to_i == 1
          attr[:userAccountControl] = "66082"
        else
          attr[:userAccountControl] = "546"
        end
      else
        if params[:user][:pwd_exp].to_i == 1
          attr[:userAccountControl] = "66080"
        else
          attr[:userAccountControl] = "544"
        end
      end

      ldap.add(:dn => dn, :attributes => attr)

      if !ldap.get_operation_result.code.nil? && ldap.get_operation_result.code != 0
        flash[:error] = ldap.get_operation_result.message
      else
        flash[:completed] = "User added"
      end    
    end
    redirect_to "/dashboard"
  end

  def delete_user
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
    ldap_user = LdapUsers.find_by_id(params[:id])
    dn        = "CN=" + ldap_user.cn + ",OU=" + ldap_user.ou + "," + LDAP_Config[:base][LDAP_Config[:auth_to]]
    ldap.delete :dn => dn

    if !ldap.get_operation_result.code.nil? && ldap.get_operation_result.code != 0
      flash[:error] = ldap.get_operation_result.message
    else
      LdapUsers.find(params[:id]).destroy
      flash[:completed] = "User Deleted"
    end
    redirect_to "/dashboard"
  end

  def forgot_password
    @forgot_password  
  end

  protected

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

end
