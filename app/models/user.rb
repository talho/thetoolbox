class User < ActiveRecord::Base
  #before_create :sync_with_ldap
  #before_save :sync_with_ldap
  
  acts_as_authentic do |c|
    c.validate_password_field = false
    c.validate_email_field    = false
  end

  def self.find_by_login_method(login_name)
    dc   = LDAP_Config[:base][LDAP_Config[:auth_to]]
    user = User.find_by_login_and_dc(login_name, dc)
    user = LdapUser.find_by_login_and_dc(login_name, dc) unless user
    unless !user.blank?
      return false
    end
    user.save if user.new_record?
    user
  end

  def refresh_ou_members
    if is_admin?
      users = LdapUser.find_by_ou(ou)
      users.each do |user|
        user.save! if user.new_record?
      end
    end
  end

  def toggle
    if LdapUser.update(self)
      self.enabled = !self.enabled
      self.save
    end
  end

  def is_admin?
    if self.admin && !self.admin_expire.nil? && self.admin_expire > Time.now
      return self.admin
    else
      user = LdapUser.find_by_login_and_dc(login, dc)
      user.admin
     end

  end

  def reset_password(password_plaintext)
    LdapUser.reset_password(self.login, password_plaintext)
  end

  def valid_credentials?(password_plaintext)
    LdapUser.valid_credentials?(dn, password_plaintext)
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

  private

  def sync_with_ldap
    if new_record?
      if login && dc
        user         = LdapUser.find_by_login_and_dc(login, dc)
        self.cn      = user.cn
        self.dn      = user.dn
        self.ou      = user.ou
        self.email   = user.email
        self.enabled = user.enabled
        true
      else
        false
      end
    else
      #raise "We need to fix this!"
      #LdapUser.update(self)
    end
  end
end