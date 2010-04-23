class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :login,               :null => false                # optional, you can use email instead, or both
      t.string    :dn,                  :null => false
      t.string    :dc,                  :null => false
      t.string    :cn,                  :null => false
      t.string    :persistence_token,   :null => false                # required
      t.string    :single_access_token, :null => false                # optional, see Authlogic::Session::Params
      t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability
      t.boolean   :admin,               :null => false, :default => false
      t.datetime  :admin_expire
      t.string    :email

      # Magic columns, just like ActiveRecord's created_at and updated_at. These are automatically maintained by Authlogic if they are present.
      t.integer   :login_count,         :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      t.integer   :failed_login_count,  :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      t.datetime  :last_request_at                                    # optional, see Authlogic::Session::MagicColumns
      t.datetime  :current_login_at                                   # optional, see Authlogic::Session::MagicColumns
      t.datetime  :last_login_at                                      # optional, see Authlogic::Session::MagicColumns
      t.string    :current_login_ip                                   # optional, see Authlogic::Session::MagicColumns
      t.string    :last_login_ip                                      # optional, see Authlogic::Session::MagicColumns

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
