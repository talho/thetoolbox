# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_torch_gui_session',
  :secret      => '2d8c99ab7d3fd7670c5808d80d4081376bf6031c0106c059c211973d2b3759c25c05871f44e5aabe2b1419ac54cadb81fa255032e89e0aa202707fa520538752'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
