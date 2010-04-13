class LdapUsers < ActiveRecord::Base

  def reset_password(new_password)
    ldap = ldap_connect
    unless ldap
      return false
    end
    res = ldap.modify(:dn => "CN=#{self.cn},OU=#{self.ou},#{LDAP_Config[:base][LDAP_Config[:auth_to]]}", :operations => [
      [:replace,
      :unicodePwd,
      microsoft_encode_password(new_password)]
      ])
    unless(res)
      return false
    end
    return true
  end
  
  protected

  def microsoft_encode_password(pwd)
    quotepwd   = '"' + pwd + '"'
    unicodepwd = Iconv.iconv('UTF-16', 'UTF-8', quotepwd).first
    return unicodepwd
  end

  def ldap_connect
    begin
      ldap = Net::LDAP.new(
        :host => LDAP_Config[:host][LDAP_Config[:auth_to]],
        :port => 636,
        :encryption => :simple_tls,
        :auth => {:username => LDAP_Config[:username][LDAP_Config[:auth_to]], :password => LDAP_Config[:password]})
    rescue
      return false
    end
    unless ldap.bind
      return false
    end
  end

end
