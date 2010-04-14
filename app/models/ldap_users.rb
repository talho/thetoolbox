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
    if !ldap.get_operation_result.code.nil? && ldap.get_operation_result.code != 0
      return false
    end
    return true
  end
  
  protected

  def microsoft_encode_password(pwd)
    newPass = ""
    pwd = "\"" + pwd + "\""
    pwd.length.times{|i| newPass+= "#{pwd[i..i]}\000"}
    newPass
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
    return ldap
  end

end
