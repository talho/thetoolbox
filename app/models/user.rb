class User < ActiveRecord::Base

  acts_as_authentic do |c|
    c.validate_password_field = false
    c.validate_email_field    = false
  end

  def self.find_by_login_method(login_name)
    dc   = LDAP_Config[:base][LDAP_Config[:auth_to]]
    user = LdapUser.find_by_login_and_dc(login_name, dc)
    unless !user.blank?
      return false
    end
    user.save if user.new_record?
    user
  end

  def is_admin?
    if self.admin && !self.admin_expire.nil? && self.admin_expire > Time.now
      return self.admin
    else
      user = LdapUser.find_by_login_and_dc(login, dc)
      user.admin
     end

  end

  def valid_credentials?(password_plaintext)
    LdapUser.valid_credentials?(dn, password_plaintext)
  end

  def create_ou_string
    dn_array = self.dn.split(",")
    ou_string = dn_array[dn_array.length-2].split("=")[1]+"."+dn_array[dn_array.length-1].split("=")[1]
    dn_index = dn_array.length-3
    for dn_item in dn_array
      unless dn_array[dn_index].nil?
        if dn_array[dn_index].split("=")[0] == "OU"
          ou_string += "/" + dn_array[dn_index].split("=")[1]
        else
          break
        end
        dn_index-=1
      end
    end
    return ou_string
  end

  protected

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
    return ldap
  end

end