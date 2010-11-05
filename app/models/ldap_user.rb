class LdapUser
  def self.find_by_login_and_dc(login, dc)
    ldap = ldap_connect
    if ldap
      filter     = Net::LDAP::Filter.eq('samAccountName', login)
      ldap_entry = ldap.search(:base => dc, :filter => filter).first
      user       = User.find_by_login_and_dc(login, dc)
      user       = if user
        attributes = Hash.new
        {"email" => "mail", "cn" => "cn", "dn" => "dn","security_group" => "extensionattribute11",
         "use_oab" => "msexchuseoab"}.each do |key, value|
          attributes[key] = ldap_entry[value].first unless (attributes[key] || "") == (ldap_entry[value].first || "")
        end
        enabled              = is_enabled?(ldap_entry[:useraccountcontrol].first)
        attributes[:enabled] = enabled unless user.enabled == enabled
        if user.admin_expire.nil? || user.admin_expire < Time.now
          attributes["admin"]        = is_admin_from_memberof?(ldap_entry[:memberof])
          attributes["admin_expire"] = Time.now + 15.minutes
        end
        user.update_attributes attributes unless attributes.empty?
        user
      else
        if ldap_entry.blank?
          return false
        end
        dn             = ldap_entry[:dn].first
        email          = ldap_entry[:mail].first || ""
        cn             = ldap_entry[:cn].first
        ou             = ldap_entry[:dn].first.split(',')[1].split('=')[1]
        security_group = ldap_entry[:extensionattribute11].first
        use_oab        = ldap_entry[:msexchuseoab].first
        enabled = is_enabled?(ldap_entry[:useraccountcontrol].first)
        User.new(:login => login, :dn => dn, :dc => dc, :cn => cn, :email => email, :ou => ou, :security_group => security_group,
                 :use_oab => use_oab, :enabled => enabled)
      end
    end
  end

  def self.find_by_login(login)
    find_by_login_and_dc(login, LDAP_Config[:base][LDAP_Config[:auth_to]])
  end

  def self.valid_credentials?(dn, password_plaintext)
    ldap = begin
      Net::LDAP.new(
        :host       => LDAP_Config[:host][LDAP_Config[:auth_to]],
        :port       => LDAP_Config[:port].to_i,
        :encryption => :simple_tls,
        :auth       => {:method => :simple, :username => dn, :password => password_plaintext})
    rescue
    end
    ldap.bind
  end

  protected

  def self.is_enabled?(user_account_control)
    return true if user_account_control == "512" || user_account_control == "66048"
    return false 
  end

  def self.ldap_connect
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

  private

  def self.is_admin_from_memberof?(memberof)
    if memberof.size > 0
      memberof.each do |item|
        return true unless (item =~ /CN=Email Admin/).nil? 
      end
    end
    false
  end
  
end
