class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validate_password_field = false
  end

  def self.find_or_create_from_ldap(login)
    find_by_login(login) || create_from_ldap_if_valid(login)
  end

  def self.create_from_ldap_if_valid(login)
    begin
      dn = find_from_ldap(login)
      User.create(:login => login, :dn => dn) if dn
    rescue
      nil # Don't do anything since we can't find an entry
    end
  end


  protected


    def valid_ldap_credentials?(password_plaintext)
      begin
        ldap = Net::LDAP.new(:host => LDAP_Config[:host],
        :port => LDAP_Config[:port].to_i,
        :auth => {:method => :simple, :username => dn, :password => password_plaintext})
      rescue
        return false
      end
      ldap.bind
    end

    def validate_dn(dn)
      begin

      rescue
        return false
      end
    end

    def self.find_from_ldap(login)
      begin
        ldap = Net::LDAP.new(:host => LDAP_Config[:host],
        :port => LDAP_Config[:port].to_i,
        :auth => {:method => :simple, :username => LDAP_Config[:username], :password => LDAP_Config[:password]})
      rescue
        return false
      end
      #ldap.encryption :simple_tls
      unless ldap.bind
        return false
      end
      filter = Net::LDAP::Filter.eq('samAccountName', login)
      s = ldap.search(:base => LDAP_Config[:base], :filter => filter)
      if s.size > 0
        debugger
        s[0][:dn].first
      else
        nil
      end
    end
end

