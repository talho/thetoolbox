class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validate_password_field = false
    #c.ldap_host = LDAP_Config[:host]
    #c.ldap_port = LDAP_Config[:port]
  end
end

