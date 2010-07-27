class AddVpnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :vpn, :boolean
  end

  def self.down
    remove_column :users, :vpn
  end
end
