# General
Then /^I should see error messages$/ do
  assert_match /error(s)? prohibited/m, response.body
end

# Database

Given /^no user exists with a login of "(.*)"$/ do |login|
  assert_nil User.find_by_login(login)
end

Given /^I signed up with "(.*)\/(.*)"$/ do |login, password|
  user = Factory :user,
    :login                 => login
end

Given /^I am signed up as "(.*)\/(.*)\/(.*)\/(.*)\/(.*)"$/ do |login, cn, email, ou_branch, ou|
  include Authlogic::TestCase
  activate_authlogic
  user = Factory :user,
    :login => login,
    :email => email,
    :dn => "CN=#{cn},#{ou_branch},DC=thetoolbox,DC=com",
    :dc => 'DC=thetoolbox,DC=com',
    :cn => cn,
    :ou => ou,
    :admin => false,
    :use_oab => '',
    :security_group => '',
    :admin_expire => Time.now + 15.minutes
end

Given /^(.*) is an admin$/ do |login|
  user = User.find_by_login login
  user.admin = true
  user.admin_expire = Time.now + 15.minutes
  user.save!
end

Given /^(.*) is not an admin$/ do |login|
  user = User.find_by_login login
  user.admin = false
  user.save!
end

Given /^I am logged in as "([^\"]*)"$/ do |credentials|
  When %{I go to the sign in page}
  sleep 1
  And %{I select "Test" from "Authenticate"}
  And %{I sign in as "#{credentials}"}
  And %{I should see "Login successful"}
  #And %{I should be signed in}
end

# Session

Then /^I should be signed in$/ do
  assert UserSession.find
end

Then /^I should be signed out$/ do
  #assert ! UserSession.find
  When %{I go to the dashboard page}
  Then %{I should see "TALHO Toolbox: Login" within "body"}
end

When /^session is cleared$/ do
  controller.instance_variable_set(:@_current_user, nil)
end

# Actions

When /^I sign in( with "remember me")? as "(.*)\/(.*)"$/ do |remember, login, password| 
  When %{I go to the sign in page}
  And %{I fill in "Login" with "#{login}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I click on "#_user_session_remember_me"} if remember
  And %{I press "Sign In"}
end

When /^I sign out$/ do
  visit '/session', :delete
  unset_current_user
end

When /^I return next time$/ do
  When %{session is cleared}
  And %{I go to the homepage}
end