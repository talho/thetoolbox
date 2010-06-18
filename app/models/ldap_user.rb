class LdapUser
  def self.find_by_login_and_dc(login, dc)
    ldap = ldap_connect
    if ldap
      filter     = Net::LDAP::Filter.eq('samAccountName', login)
      ldap_entry = ldap.search(:base => dc, :filter => filter).first
      user       = User.find_by_login_and_dc(login, dc)
      user       = if user
        attributes = Hash.new
        {"email" => "mail", "cn" => "cn", "dn" => "dn"}.each do |key, value|
          attributes[key] = ldap_entry[value].first unless (attributes[key] || "") == (ldap_entry[value].first || "")
        end
        enabled              = is_enabled?(ldap_entry[:useraccountcontrol].first)
        attributes[:enabled] = enabled unless user.enabled == enabled
        if user.admin_expire.nil? || user.admin_expire < Time.now
          attributes["admin"]        = is_admin_from_memberof?(ldap_entry[:memberof])
          attributes["admin_expire"] = Time.now + 15.minutes
        end
        #update_ou(user, ldap_entry, attributes)
        user.update_attributes attributes unless attributes.empty?
        user
      else
        if ldap_entry.blank?
          return false
        end
        dn      = ldap_entry[:dn].first
        email   = ldap_entry[:mail].first || ""
        cn      = ldap_entry[:cn].first
        ou      = ldap_entry[:dn].first.split(',')[1].split('=')[1]
        enabled = is_enabled?(ldap_entry[:useraccountcontrol].first)
        User.new(:login => login, :dn => dn, :dc => dc, :cn => cn, :email => email, :ou => ou, :enabled => enabled)
      end

    end
  end

  def self.find_by_login(login)
    find_by_login_and_dc(login, LDAP_Config[:base][LDAP_Config[:auth_to]])
  end

  def self.find_by_ou(ou)
    ldap = ldap_connect
    if ldap
      base         = "OU=#{ou},#{LDAP_Config[:base][LDAP_Config[:auth_to]]}"
      filter       = Net::LDAP::Filter.eq('objectClass', "Person")
      ldap_entries = ldap.search(:base => base, :filter => filter)
      db_entries   = User.find_all_by_ou(ou)
      users        = ldap_entries.collect do |entry|
        user = db_entries.find{|i| i.login == entry['samaccountname'].first}
        if user
          attributes = Hash.new
          {"email" => "mail", "cn" => "cn", "dn" => "dn"}.each do |key, value|
            attributes[key] = entry[value].first unless (user.send(key) || "") == (entry[value].first || "")
          end
          enabled              = is_enabled?(entry[:useraccountcontrol].first)
          attributes[:enabled] = enabled unless user.enabled == enabled
          if user.admin_expire.nil? || user.admin_expire < Time.now
            attributes["admin"]        = is_admin_from_memberof?(entry[:memberof])
            attributes["admin_expire"] = Time.now + 15.minutes
          end
          #update_ou(user, entry, attributes)
          user.update_attributes attributes unless attributes.empty?
          user
        else
          login   = entry[:samaccountname].first
          dn      = entry[:dn].first
          email   = entry[:mail].first || ""
          cn      = entry[:cn].first
          ou      = entry[:dn].first.split(',')[1].split('=')[1]
          dc      = LDAP_Config[:base][LDAP_Config[:auth_to]]
          enabled = is_enabled?(entry[:useraccountcontrol].first)
          User.new(:login => login, :dn => dn, :dc => dc, :cn => cn, :email => email, :ou => ou, :enabled => enabled)
        end
      end

    end
  end

  def self.update(user)
    ldap = ldap_connect
    return false unless ldap
    uac = get_user_account_control user.dn
    ldap.modify(:dn => user.dn, :operations => [
      [:replace,
       :distinguishedName,
       user.dn]
      ])
    ldap.modify(:dn => user.dn, :operations => [
      [:replace,
       :cn,
       user.cn]
      ])
    ldap.modify(:dn => user.dn, :operations => [
      [:replace,
       :mail,
       user.email]
      ])
    ldap.modify(:dn => user.dn, :operations => [
      [:replace,
      :userAccountControl,
      uac]
      ])
    ldap.get_operation_result.code.nil? && ldap.get_operation_result.code == 0
  end

  def self.reset_password(login, new_password)
    ldap = ldap_connect
    return false unless ldap
    user = find_by_login login
    ldap.modify(:dn => user.dn, :operations => [
      [:replace,                                                                                            
      :unicodePwd,
      microsoft_encode_password(new_password)]
      ])
    !ldap.get_operation_result.code.nil? && ldap.get_operation_result.code == 0
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

  def self.microsoft_encode_password(pwd)
    newPass = ""
    pwd     = "\"" + pwd + "\""
    pwd.length.times{|i| newPass += "#{pwd[i..i]}\000"}
    newPass
  end

  def self.is_enabled?(user_account_control)
    return true if user_account_control == "512" || user_account_control == "66048"
    return false 
  end

  def self.get_user_account_control(dn)
    ldap = ldap_connect
    return false unless ldap
    filter    = Net::LDAP::Filter.eq('distinguishedName', dn)
    s         = ldap.search(:base => LDAP_Config[:base][LDAP_Config[:auth_to]], :filter => filter)
    uac       = "66050" if s.first[:useraccountcontrol].first == "66048"
    uac       = "514"   if s.first[:useraccountcontrol].first == "512"
    uac       = "66048" if s.first[:useraccountcontrol].first == "66050"
    uac       = "512"   if s.first[:useraccountcontrol].first == "514"
    uac       = "512" if uac.blank?
    uac
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

  def self.update_admin_status(user, ldap_entry, attributes)
    if user.admin_expire.nil? || user.admin_expire < Time.now
      ldap = ldap_connect
      return false unless ldap
      filter  = Net::LDAP::Filter.eq('samAccountName', user.login)
      s       = ldap.search(:base => LDAP_Config[:base][LDAP_Config[:auth_to]], :filter => filter)
      isAdmin = false
      if s.size > 0
        if !s[0][:memberof].empty?
          lines = s[0][:memberof].first.split(",")
        else
          lines = s[0][:dn].first.split(",")
        end
        lines.each do |value|
          if value.split("=")[1] == 'Email Admins'
            isAdmin = true
          end
        end
      else
        isAdmin = false
      end
      attributes["admin"]        = isAdmin
      attributes["admin_expire"] = Time.now + 15.minutes
    end
  end

  def self.update_ou(user, ldap_entry, attributes)

  end
end
