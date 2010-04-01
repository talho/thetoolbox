class CreateLdapUsers < ActiveRecord::Migration
  def self.up
    create_table :ldap_users do |t|
      t.string    :cn,                  :null => false  
      t.string    :ou,                  :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :ldap_users
  end
end
