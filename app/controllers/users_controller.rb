class UsersController < ApplicationController
  before_filter :require_user, :except => [:create, :forgot_password]
  verify :method => :get, :only => [ :delete, :enable_user, :forgot_password ], :redirect_to => { :action => :index }

  def index
    begin
      user = User.find_by_login(current_user[:login])
      if user.is_admin?
        options            = {}
        options[:page]     = params[:page] || 1
        options[:per_page] = params[:per_page] || 10
        options[:vpn_only] = params[:vpn_only] || false
        options[:ou]       = user.create_ou_string
        @ldap_user_results = ExchangeUser.find(:all, :params => options)
        unless params[:vpn_only].blank?
          respond_to do |format|
            format.html {render :partial => "users/vpn_users"}
          end
        end
        
      else
        redirect_to user_path(current_user)
      end
      @new_user = User.new
    rescue
      flash[:error] = "The exchange restful service is currently down, please contact your administrator."  
    end

  end

  def show
    begin
      @user = User.find_by_id(params[:id])
    rescue
      flash[:error] = "The exchange restful service is currently down, please contact your administrator."
    end

  end

  def create
    unless !valid_params?
      dn           = current_user.dn.gsub(/CN=[^,]*,/, "")
      email_domain = current_user.email.split("@")[1]
      begin
        attr_ldap = {
          :cn                 => params[:user][:first_name] + " " + params[:user][:last_name],
          :name               => params[:user][:first_name] + " " + params[:user][:last_name],
          :displayName        => params[:user][:first_name] + " " + params[:user][:last_name],
          :distinguishedName  => dn,
          :givenName          => params[:user][:first_name],
          :samAccountName     => params[:user][:logon_name],
          :userPrincipalName  => params[:user][:logon_name] + "@" + email_domain,
          :password           => params[:user][:password],
          :sn                 => params[:user][:last_name],
          :domain             => email_domain,
          :alias              => params[:user][:logon_name],
          :ou                 => current_user.ou,
          :useOAB             => current_user.use_oab,
          :securityGroup      => current_user.security_group,
          :changePwd          => params[:user][:ch_pwd]
        }
      rescue
        attr_ldap = {
          :cn                 => params[:user_vpn][:first_name] + " " + params[:user_vpn][:last_name],
          :name               => params[:user_vpn][:first_name] + " " + params[:user_vpn][:last_name],
          :displayName        => params[:user_vpn][:first_name] + " " + params[:user_vpn][:last_name],
          :distinguishedName  => dn,
          :givenName          => params[:user_vpn][:first_name],
          :samAccountName     => params[:user_vpn][:logon_name],
          :userPrincipalName  => params[:user_vpn][:logon_name] + "@" + email_domain,
          :password           => params[:user_vpn][:password],
          :sn                 => params[:user_vpn][:last_name],
          :domain             => email_domain.split('@')[1],
          :alias              => params[:user_vpn][:logon_name],
          :ou                 => current_user.ou,
          :useOAB             => current_user.use_oab,
          :securityGroup      => current_user.security_group,
          :changePwd          => params[:user_vpn][:ch_pwd].blank? ? "0" : params[:user_vpn][:ch_pwd],
          :acctDisabled       => params[:user_vpn][:acct_dsbl] == "0" ? "1" : "0",
          :pwdExpires         => params[:user_vpn][:pwd_exp],
          :vpnUsr             => params[:user_vpn][:vpn_usr_only]
        }
      end
      begin
        e = ExchangeUser.create(attr_ldap)
        if e.attributes["mailboxEnabled"] != "true"
          flash[:completed] = "Unable to create user.  You can try to enable the mailbox again by enabling the user, or contact your administrator."
        else
          flash[:completed] = "User added"
        end  
      rescue
         flash[:error] = "Entry #{attr_ldap[:alias]} Already Exists"
      end
    end
    unless params[:vpn_only].blank?
      redirect_to users_path :vpn_only => params[:vpn_only]
    else
      redirect_to users_path
    end
  end

  def delete
    begin
      e = ExchangeUser.find(params[:id])
    rescue
      flash[:error] = "Unable to delete user, please contact your administrator."
      redirect_to users_path
      return
    end
    unless e.attributes["login"].blank?
      e.destroy
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

  def forgot_password
    @forgot_password
  end
                                                                                                    
  def reset_password
    begin
      unless User.exists?(params[:id])
        e = ExchangeUser.find(params[:id])  
      else
        e = ExchangeUser.find(current_user.login)
      end
      unless e.attributes["login"].blank?
        e.attributes.delete("xmlns:i")
        e.attributes.delete("error")
        e.attributes.delete("xmlns")
        e.password = params[:ldap_user][:new_password]
        e.identity = e.attributes["login"].gsub("-vpn","")
        e.update
        if e.has_vpn_account?
          e.identity += "-vpn@thetoolbox.com"
          e.update()
        end
        flash[:completed] = "User password changed successfully."
      else
        flash[:error] = "Unable change password, please contact your administrator."
      end
    rescue
      flash[:error] = "Unable to change password, please contact your administrator."
      redirect_to users_path
      return
    end
    redirect_to users_path
  end

  def cacti_save
    begin
      @user = User.find(current_user.id)
      if(params[:cacti_username].blank? || params[:cacti_password].blank?)
        render :text => "Error", :status => 400
      else
        uri              = URI.parse(LDAP_Config[:cacti]+"graph_view.php")
        http             = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request          = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data({"action" => "login", "login_username" => params[:cacti_username], "login_password" => params[:cacti_password]})
        response = http.request(request)
        if(response.code == "302" && response.body.blank?)
          @user.update_attributes({:cacti_username => params[:cacti_username], :cacti_password => params[:cacti_password]})
          render :text => "OK", :status => 200
        else
          render :text => "Error", :status => 400
        end
      end
    rescue
      render :text => "Error", :status => 400
    end
  end

  def cacti_log_in
    begin
      @user = User.find(current_user.id)
      @user.update_attributes({:cacti_logged_in => true})
      render :text => "OK", :status => 200
    rescue
      render :text => "Error", :status => 400
    end
  end

  def cacti_log_out
    begin
      @user = User.find(current_user.id)
      @user.update_attributes(:cacti_logged_in => false)
      render :text => "OK", :status => 200
    rescue
      render :text => "Error", :status => 400  
    end
  end

  def reset_password_form
    @ExchangeUser = ExchangeUser.find(params[:id])
    render :partial => "users/reset_password_form"
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

  def valid_params?
    begin
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
      if params[:user][:logon_name].length > 20
        errors = errors + "- Please make sure your log name is less than 20 characters long.<br/>"
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
    rescue
      errors = ''
      if params[:user_vpn][:first_name].blank?
        errors = errors + "- Please enter a first name.<br/>"
      end
      if params[:user_vpn][:last_name].blank?
        errors = errors + "- Please enter a last name.<br/>"
      end
      if params[:user_vpn][:logon_name].blank?
        errors = errors + "- Please enter a log on name.<br/>"
      end
      if params[:user_vpn][:logon_name].length > 16
        errors = errors + "- Please make sure your log name is less than 16 characters long.<br/>"
      end
      if params[:user_vpn][:password].blank?
        errors = errors + "- Please enter a password.<br/>"
      end
      if params[:user_vpn][:confirm_password].blank?
        errors = errors + "- Please confirm password.<br/>"
      end
      if !errors.blank?
        flash[:error] = "Please correct the following items:<br/>"+errors
        return false
      end
      return true
    end
  end

end