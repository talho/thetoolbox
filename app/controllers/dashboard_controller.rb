class DashboardController < ApplicationController
  def index
    lines   = current_user[:dn].split(",")
    user_ou = Hash.new
    user    = User.find_by_login(current_user[:login])
    lines.each{|i| user_ou[i.split("=")[0]] = i.split("=")[1]}
    if user.is_admin?
      @ldap_user_results = user.ous(user_ou['OU']).paginate(:page => params[:page], :per_page => 10)
      #@ldap_user_results, @ldap_user = paginate :ldapusers, :per_page => 10
    else
      @ldap_user_results = false
    end
  end

  verify :method => :get, :only => [ :delete_user, :create_new_user ], :redirect_to => { :action => :index }

  def create_new_user
    begin
      ldap = Net::LDAP.new(
        :host => LDAP_Config[:host][LDAP_Config[:auth_to]],
        :port => LDAP_Config[:port].to_i,
        :auth => {:method => :simple, :username => LDAP_Config[:username][LDAP_Config[:auth_to]], :password => LDAP_Config[:password]})
    rescue
      return false
    end
    unless ldap.bind
      return false
    end
    dn   = "CN=" + params[:users][:first_name] + " " + params[:users][:last_name] + ",OU=TALHO," + LDAP_Config[:base][LDAP_Config[:auth_to]]
    attr = {
      :cn          => params[:users][:first_name] + " " + params[:users][:last_name],
      :name        => params[:users][:first_name] + " " + params[:users][:last_name],
      :objectclass => ["top", "User"],
      :sn          => params[:users][:last_name]
    }
    ldap.add(:dn => dn, :attributes => attr)
    if !ldap.get_operation_result.code.nil? && ldap.get_operation_result.code != 0
      flash[:error] = ldap.get_operation_result.error_message
    else
      flash[:notice] = "User added"
    end
    redirect_to "/dashboard"
  end

  def delete_user
    begin
      ldap = Net::LDAP.new(
        :host => LDAP_Config[:host][LDAP_Config[:auth_to]],
        :port => LDAP_Config[:port].to_i,
        :auth => {:method => :simple, :username => LDAP_Config[:username][LDAP_Config[:auth_to]], :password => LDAP_Config[:password]})
    rescue
      return false
    end
    unless ldap.bind
      return false
    end
    ldap_user = LdapUsers.find_by_id(params[:id])
    dn   = "CN=" + ldap_user.cn + ",OU=" + ldap_user.ou + "," + LDAP_Config[:base][LDAP_Config[:auth_to]]
    ldap.delete :dn => dn

    if !ldap.get_operation_result.code.nil? && ldap.get_operation_result.code != 0
      flash[:error] = ldap.get_operation_result.error_message || ldap.get_operation_result.message
    else
      LdapUsers.find(params[:id]).destroy
      flash[:notice] = "User Deleted"
    end
    redirect_to "/dashboard"
  end
end
