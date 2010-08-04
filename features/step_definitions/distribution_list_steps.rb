
Given /^"([^\"]*)" does not exist$/ do |listName|
  begin
    group = DistributionGroup.find(listName)
    group.delete
  rescue
  end
end

Given /^I have a distribution list named "([^\"]*)"$/ do |listName|
  begin
    group = DistributionGroup.find(listName)
  rescue
  end
  
  if group.nil?
    user = User.all.first
    group = DistributionGroup.new(:group_name => listName, :ou => user.ou)
    group.save
  end
end

Given /^"([^\"]*)" is a contact and a member of "([^\"]*)"$/ do |contactName, listName|
  group = DistributionGroup.find(listName)
  if group.nil?
    Given 'I have a distribution list named "#{listName}"'
  end
  adminUser = User.all.first

  user = ExchangeUser.new :cn => contactName, :type => "MailContact", :ou => adminUser.ou, :email => "doesnt@matter.com"
  group.ExchangeUsers.push(user)
  group.update
end

Given /^"([^\"]*)" has no members$/ do |listName|
  group = DistributionGroup.find(listName)
  unless group.nil?
    group.ExchangeUsers.clear
    group.update
  end
end

Given /^"([^\"]*)" is a user with alias "([^\"]*)"$/ do |userName, userAlias|
  begin #try to find the user. If it throws an error (which the system does if no user is found, then create the user
    EchangeUser.find(userName)
  rescue
    user = User.all.first
    ExchangeUser.create(:cn                 => userName,
                 :name               => userName,
                 :displayName        => userName,
                 :distinguishedName  => userName,
                 :givenName          => userName,
                 :samAccountName     => userAlias,
                 :userPrincipalName  => userAlias + "@upn.com",
                 :password           => "Password1",
                 :sn                 => userName,
                 :domain             => "upn.com",
                 :alias              => userAlias,
                 :ou                 => user.ou,
                 :changePwd          => false,
                 :isVPN              => false,
                 :acctDisabled       => false,
                 :pwdExpires         => false
    )
  end
end

When /^I select "([^\"]*)" within "([^\"]*)"$/ do |listItem, selector|
  within (selector) do
    Capybara.default_wait_time = 5
    find('li .displayName', :text => listItem).click
  end
end

Then /^"([^\"]*)" should be a member of "([^\"]*)"$/ do |userOrContactName, groupName|
  group = DistributionGroup.find(groupName)
  group.ExchangeUsers.find(:cn => userOrContactName).should != nil
end

Then /^"([^\"]*)" should not be a member of "([^\"]*)"$/ do |userOrContactName, groupName|    
  group = DistributionGroup.find(groupName)
  group.ExchangeUsers.find(:cn => userOrContactName).should == nil
end