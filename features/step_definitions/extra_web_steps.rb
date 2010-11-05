When /^I have found the user with alias "([^\"]*)"(?: within "([^\"]*)")?$/ do |userName, selector|
  sleep 1
  elem = find(:xpath,".//td[@id='#{userName}'][@class='delete']") # look for the delete container with the user name
  if elem.nil?
    elem = find("#vpn_del_"+userName)
  end
  
  if elem.nil?
    unless  find_link("Next").nil?
      with_scope(selector) do
        When %{I follow "Next"}
        sleep 1
      end
      And  %{I close ".cacti_cred_container" modal box}
    end
    And  %{I have found the user with alias "#{userName}" within "#{selector}"}
  end
  elem
end

When /^I have a user with alias "([^\"]*)"$/ do |userName|
  begin
    e_user = ExchangeUser.find(userName)
  rescue
  end

  if e_user.nil?
    e_user = ExchangeUser.create({
      :cn => "Junk User",
      :name => "Junk User",
      :displayName => "Junk User",
      :distinguishedName => User.find_by_login("admin_tester").dn.gsub(/CN=[^,]*,/, ""),
      :givenName => "Junk",
      :samAccountName => "#{userName}",
      :userPrincipalName => "#{userName}@#{User.find_by_login("admin_tester").email.split("@")[1]}",
      :password => "Password1",
      :sn => "Junk",
      :domain => "#{User.find_by_login("admin_tester").email.split("@")[1]}",
      :alias => "#{userName}", 
      :ou => User.find_by_login("admin_tester").ou,
      :useOAB => User.find_by_login("admin_tester").use_oab,
      :securityGroup => User.find_by_login("admin_tester").security_group,
      :changePwd => 0
    })
  end
end

When /^I have a vpn user with alias "([^\"]*)"$/ do |userName|
  begin
    e_user = ExchangeUser.find(userName+"-vpn@"+User.find_by_login("admin_tester").dc.split(",")[0].split("DC=")[1]+"."+User.find_by_login("admin_tester").dc.split(",")[1].split("DC=")[1])
  rescue
  end
  if e_user.nil?
    e_user = ExchangeUser.create({
      :cn => "Junk User VPN",
      :name => "Junk User VPN",
      :displayName => "Junk User VPN",
      :distinguishedName => User.find_by_login("admin_tester").dn.gsub(/CN=[^,]*,/, ""),
      :givenName => "Junk",
      :samAccountName => "#{userName}",
      :userPrincipalName => "#{userName}@#{User.find_by_login("admin_tester").email.split("@")[1]}",
      :password => "Password1",
      :sn => "Junk",
      :domain => "thetoolbox.com",
      :alias => "#{userName}",
      :ou => User.find_by_login("admin_tester").ou,
      :changePwd => 0,
      :vpnUsr => true,
      :useOAB => User.find_by_login("admin_tester").use_oab,
      :securityGroup => User.find_by_login("admin_tester").security_group
    })
  end
end

When /^"([^\"]*)" should not be a user$/ do |userName|
  begin
    e_user = ExchangeUser.find(userName)
    e_user.destroy
    e_user = nil
  rescue
    e_user = nil
  end
  assert (e_user.nil?)
end

When /^I will confirm on next step$/ do
  begin
    evaluate_script("window.alert = function(msg) { window.alert_message = msg; return msg; }")
    evaluate_script("window.confirm = function(msg) { window.confirmation_message = msg; return msg; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

Then /^I should see "([^\"]*)" within the alert box$/ do |msg|
  assert !(evaluate_script("window.alert_message") =~ Regexp.new(msg)).nil?
end

Then /^I should see "([^\"]*)" within the confirmation box$/ do |msg|
  assert !(evaluate_script("window.confirmation_message") =~ Regexp.new(msg)).nil?
end

When /^I close "([^\"]*)" modal box$/ do |dom_selector|
  begin
    wait_until{page.find("#{dom_selector}").nil? == false}
    page.execute_script("$('#{dom_selector}').dialog('close');")
  rescue
    Capybara::NotSupportedByDriverError
  end
end

When /^I override alert$/ do
  begin
    evaluate_script("window.alert = function(msg) { window.alert_message = msg; return msg; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

When /^I click on "([^\"]*)"$/ do |element|
  page.execute_script("$('#{element}').click()") 
end

Then /^I refresh page$/ do
  execute_script("window.location.reload()")
end

When /^I wait "([^\"]*)" second(?:s)?$/ do |seconds|
  sleep seconds.to_i
end

