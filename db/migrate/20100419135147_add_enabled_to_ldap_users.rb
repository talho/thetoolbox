class AddEnabledToLdapUsers < ActiveRecord::Migration
  def self.up
    add_column :ldap_users, :enabled, :boolean
  end

  def self.down
    remove_column :ldap_users, :enabled
  end
end
