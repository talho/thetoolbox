class User < ActiveRecord::Base
  belongs_to :as_ldap_user, :primary_key => :cn, :foreign_key => :cn, :class_name => 'LdapUser'

  acts_as_authentic do |c|
    c.validate_password_field = false
  end

  def self.find_or_create_from_ldap(login_name)
   login = find_by_login(login_name)
   if login && login[:dc] == LDAP_Config[:base][LDAP_Config[:auth_to]]
     login = validate_dn(login)
     login
   else
    create_from_ldap_if_valid(login_name)
   end
  end

  def self.create_from_ldap_if_valid(login)
    begin
      ldap_entry = find_from_ldap(login)
      dn = ldap_entry[:dn]
      email = ldap_entry[:email] || ""
      dc = dn[dn.index("DC")..-1]
      cn = ldap_entry[:cn]
      if dn
        user = User.find(:all, :conditions => {:login => login, :dc => dc})
        if user.blank?
          User.create(:login => login, :dn => dn, :dc => dc, :cn => cn, :email => email)
        else
          return user
        end
      end     
    rescue
      nil
    end
  end

  def ous(ou)
    ldap = ldap_connect
    unless ldap
      return false
    end
    attrs = ["cn", "member", "useraccountcontrol"]
    ldap.search( :base => "OU=#{ou}, #{LDAP_Config[:base][LDAP_Config[:auth_to]]}", :attributes=> attrs) do |entry|
      l_cn      = ''
      l_ou      = ''
      l_enabled = ''
      entry.each do |attr, values|
        if "#{attr}" == "dn"
          values.each do |str|
            if str.split(',')[0].split('=')[0] == 'CN'
              l_cn = str.split(',')[0].split('=')[1]
              l_ou = str.split(',')[1].split('=')[1]
            end
          end
        end
        if "#{attr}" == "useraccountcontrol"
          values.each do |str|
            if str == "512" || str == "66048"
              l_enabled = true
            else
              l_enabled = false
            end
          end
        end
        unless l_enabled == ''
          unless LdapUser.find_by_cn(l_cn)
            LdapUser.create(:cn => l_cn, :ou => l_ou, :enabled => l_enabled) if l_cn != "Email Admins"
          end
        end
      end
    end
    return LdapUser.find_all_by_ou(ou)
  end

  def is_admin?
    if self.admin && !self.admin_expire.nil? && self.admin_expire > Time.now
      return self.admin
    else
      ldap = ldap_connect
      unless ldap
        return false
      end
      filter  = Net::LDAP::Filter.eq('samAccountName', self.login)
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
        :host       => LDAP_Config[:host][LDAP_Config[:auth_to]],
        :port       => LDAP_Config[:port].to_i,
        :encryption => :simple_tls,
        :auth       => {:method => :simple, :username => dn, :password => password_plaintext})
    rescue
      return false
    end
    unless ldap.bind
      return false
    end
    return true
  end

  def self.validate_dn(login)
    ldap = ldap_connect_self
    unless ldap
      return false
    end
    filter = Net::LDAP::Filter.eq('samAccountName', login[:login])
    s      = ldap.search(:base => LDAP_Config[:base][LDAP_Config[:auth_to]], :filter => filter)
    login  = User.update(login[:id], :dn => s[0][:dn].first) if s[0][:dn].first != login[:dn]
    login
  end

  def self.find_from_ldap(login, return_string = true)
    ldap = ldap_connect_self
    unless ldap
      return false
    end
    filter = Net::LDAP::Filter.eq('samAccountName', login)
    s      = ldap.search(:base => LDAP_Config[:base][LDAP_Config[:auth_to]], :filter => filter)
    if s.size > 0
       unless return_string
         return s
       end
       return {:dn => s[0][:dn].first, :cn => s[0][:cn].first, :email => s[0][:mail].first}
    else
      nil
    end
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

  def self.ldap_connect_self
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