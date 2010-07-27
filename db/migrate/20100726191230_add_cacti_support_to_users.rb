class AddCactiSupportToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :cacti_username, :string
    add_column :users, :cacti_password, :string
    add_column :users, :cacti_logged_in, :boolean, :default => false
  end

  def self.down
    remove_column :users, :cacti_username
    remove_column :users, :cacti_password
    remove_column :users, :cacti_logged_in
  end
end
