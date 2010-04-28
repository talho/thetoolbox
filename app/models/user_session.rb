class UserSession < Authlogic::Session::Base
  find_by_login_method :find_by_login_method
  verify_password_method :valid_credentials?
end
