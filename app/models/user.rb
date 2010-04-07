class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validate_password_field = false
  end

  def self.find_or_create_from_ldap(login_name)
   login = find_by_login(login_name)
   if login && login[:host_to_auth] == LDAP_Config[:host_to_auth]
     login = validate_dn(login)
     login
   else
    create_from_ldap_if_valid(login_name)
   end
  end

  def self.create_from_ldap_if_valid(login)
    begin
      dn = find_from_ldap(login)
      User.create(:login => login, :dn => dn, :host_to_auth => LDAP_Config[:host_to_auth]) if dn
    rescue
      nil # Don't do anything since we can't find an entry
    end
  end

  def self.ous(ou)
    begin
      ldap = Net::LDAP.new(
        :host => LDAP_Config[:host_to_auth],
        :port => LDAP_Config[:port].to_i,
        :auth => {:method => :simple, :username => LDAP_Config[:user_to_auth], :password => LDAP_Config[:password]})
    rescue
      return false
    end
    unless ldap.bind
      return false
    end
    op_filter = Net::LDAP::Filter.eq( "objectClass", "group" )
    attrs     = ["cn", "member"]
    ldap.search( :base => "OU=#{ou}, #{LDAP_Config[:base_to_auth]}", :attributes=> attrs) do |entry|
      entry.each do |attr, values|
        if "#{attr}" == "dn"
          values.each do |str|
            unless str.split(',')[1].split('=')[1].nil?
              unless LdapUsers.find_by_cn(str.split(',')[0].split('=')[1])
                LdapUsers.create(:cn => str.split(',')[0].split('=')[1], :ou => str.split(',')[1].split('=')[1]) if str.split(',')[0].split('=')[1] != "Email Admins"
              end
            end
          end
        end
      end
    end
    return LdapUsers.find_all_by_ou(ou)
  end

  def is_admin?
    if !self.admin_expire.nil? && self.admin_expire > Time.now
      return self.admin
    else
      begin
        ldap = Net::LDAP.new(
          :host => LDAP_Config[:host_to_auth],
          :port => LDAP_Config[:port].to_i,
          :auth => {:method => :simple, :username => LDAP_Config[:user_to_auth], :password => LDAP_Config[:password]})
      rescue
        return false
      end
      unless ldap.bind
        return false
      end
      filter  = Net::LDAP::Filter.eq('samAccountName', self.login)
      s       = ldap.search(:base => LDAP_Config[:base_to_auth], :filter => filter)
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
      self.admin        = isAdmin
      self.admin_expire = Time.now + 15.minutes
      self.save
      return isAdmin
     end
  end

  protected

  def valid_ldap_credentials?(password_plaintext)
    begin
      ldap = Net::LDAP.new(
        :host => LDAP_Config[:host_to_auth],
        :port => LDAP_Config[:port].to_i,
        :auth => {:method => :simple, :username => dn, :password => password_plaintext})
    rescue
      return false
    end
    ldap.bind
  end

  def self.validate_dn(login)
    begin
      ldap = Net::LDAP.new(
        :host => LDAP_Config[:host_to_auth],
        :port => LDAP_Config[:port].to_i,
        :auth => {:method => :simple, :username => LDAP_Config[:user_to_auth], :password => LDAP_Config[:password]})
    rescue
      return false
    end
    unless ldap.bind
      return false
    end
    filter = Net::LDAP::Filter.eq('samAccountName', login[:login])
    s      = ldap.search(:base => LDAP_Config[:base_to_auth], :filter => filter)
    login  = User.update(login[:id], :dn => s[0][:dn].first) if s[0][:dn].first != login[:dn]
    login
  end

  def self.find_from_ldap(login, return_string = true)
    begin
      ldap = Net::LDAP.new(
        :host => LDAP_Config[:host_to_auth],
        :port => LDAP_Config[:port].to_i,
        :auth => {:method => :simple, :username => LDAP_Config[:user_to_auth], :password => LDAP_Config[:password]})
    rescue
      return false
    end
    unless ldap.bind
      return false
    end
    filter = Net::LDAP::Filter.eq('samAccountName', login)
    s      = ldap.search(:base => LDAP_Config[:base_to_auth], :filter => filter)
    if s.size > 0
       unless return_string
         return s
       end
       return s[0][:dn].first
    else
      nil
    end
  end

end