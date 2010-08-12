When /^I have found the user with alias "([^\"]*)"$/ do |userName|
  elem = find("#" + userName + ".delete") # look for the delete container with the user name
  if elem.nil?
    unless  find_link("Next").nil?
      When %{I follow "Next"}
      And  %{I close ".cacti_cred_container" modal box}
      And  %{I have found the user with alias "#{userName}"}
    end
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
      :dn => "OU=TALHO,DC=thetoolbox,DC=com",
      :givenName => "Junk",
      :samAccountName => "#{userName}",
      :userPrincipalName => "#{userName}@thetoolbox.com",
      :password => "Password1",
      :sn => "Junk",
      :domain => "thetoolbox.com",
      :alias => "#{userName}", 
      :ou => "TALHO",
      :changePwd => 0,
      :isVPN => 0,
      :acctDisabled => 0,
      :pwdExpires => 0
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
    evaluate_script("try{$('#{dom_selector}').dialog('close');}cactch(err){}")
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

Then /^I refresh page$/ do
  evaluate_script("window.location.reload()")
end

