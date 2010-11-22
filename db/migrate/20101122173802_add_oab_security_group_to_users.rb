class AddOabSecurityGroupToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :use_oab, :string
    add_column :users, :security_group, :string, :null => false, :default => false
  end

  def self.down
    remove_column :users, :use_oab
    remove_column :users, :security_group
  end
end
