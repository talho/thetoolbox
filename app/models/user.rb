class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validate_password_field = false
  end

  def self.find_or_create_from_ldap(login_name)
   login = find_by_login(login_name)
   if login
     login = validate_dn(login)
     login
   else
    create_from_ldap_if_valid(login_name)
   end
  end

  def self.create_from_ldap_if_valid(login)
    begin
      dn = find_from_ldap(login)
      User.create(:login => login, :dn => dn) if dn
    rescue
      nil # Don't do anything since we can't find an entry
    end
  end

  def self.get_from_ldap(login)
    s = find_from_ldap(login, false)
    return s
  end

  def self.ous(ou)
    begin
      ldap = Net::LDAP.new(:host => LDAP_Config[:host],
        :port => LDAP_Config[:port].to_i,
        :auth => {:method => :simple, :username => LDAP_Config[:username], :password => LDAP_Config[:password]})
    rescue
      return false
    end
    
    unless ldap.bind
      return false
    end
    #filter = Net::LDAP::Filter.eq( "ou", ou )
    #attrs = ["mail", "uid", "cn", "ou", "fullname"]
    #s      = ldap.search(:base => "OU=#{ou}, #{LDAP_Config[:base]}", :return_result => true)
    #ldap.search( :base => "dc=mycompany, dc=com", :attributes => attrs, :filter =>
    #filter, :return_result => true ) do |entry|
    #puts entry.dn

    op_filter = Net::LDAP::Filter.eq( "objectClass", "group" )
    dn        = Array.new
    member    = Array.new
    member_ou = Array.new
    cn        = Array.new
    attrs     = ["cn", "member"]

    ldap.search( :base => "OU=#{ou}, #{LDAP_Config[:base]}", :filter => op_filter, :attributes=> attrs) do |entry|
      entry.each do |attr, values|
        if "#{attr}" == "member"
          members_of    = Array.new
          members_of_ou = Array.new
          values.each do |str|
            members_of    << str.split(',')[0].split('=')[1]
            members_of_ou << str.split(',')[1].split('=')[1]
            unless str.split(',')[1].split('=')[1].nil?
              unless LdapUsers.find_by_cn(str.split(',')[0].split('=')[1])
                LdapUsers.create(:cn => str.split(',')[0].split('=')[1], :ou => str.split(',')[1].split('=')[1])
              end
            end
          end
          #for element in members_of
          #  member << element
          #end
          #for element in members_of_ou
          #  member_ou << element
          #end
        end
      end
    end
    
    return member
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

    def self.validate_dn(login)
      begin
        ldap = Net::LDAP.new(:host => LDAP_Config[:host],
          :port => LDAP_Config[:port].to_i,
          :auth => {:method => :simple, :username => LDAP_Config[:username], :password => LDAP_Config[:password]})
      rescue
        return false
      end
      unless ldap.bind
        return false
      end
      filter = Net::LDAP::Filter.eq('samAccountName', login[:login])
      s      = ldap.search(:base => LDAP_Config[:base], :filter => filter)
      login  = User.update(login[:id], :dn => s[0][:dn].first) if s[0][:dn].first != login[:dn]
      login
    end

    def self.find_from_ldap(login, return_string = true)
      begin
        ldap = Net::LDAP.new(:host => LDAP_Config[:host],
          :port => LDAP_Config[:port].to_i,
          :auth => {:method => :simple, :username => LDAP_Config[:username], :password => LDAP_Config[:password]})
      rescue
        return false
      end
      unless ldap.bind
        return false
      end
      filter = Net::LDAP::Filter.eq('samAccountName', login)
      s      = ldap.search(:base => LDAP_Config[:base], :filter => filter)
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

