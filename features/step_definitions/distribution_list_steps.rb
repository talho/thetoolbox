
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

  user = ExchangeUser.new :cn => contactName, :alias => contactName.gsub(" ", ""), :type => "MailContact", :ou => adminUser.ou, :email => "doesnt@matter.com"
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
    ExchangeUser.create(:cn          => userName,
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
                 :changePwd          => 0,
                 :isVPN              => 0,
                 :acctDisabled       => 0,
                 :pwdExpires         => 0
    )
  end
end

When /^I select "([^\"]*)" within "([^\"]*)"$/ do |listItem, selector|
  within (selector) do
    find_link(listItem).click
  end
end

When /^I select member "([^\"]*)" for list "([^"]*)" within "([^\"]*)"$/ do |listItem, listName, selector|
  within (selector) do
    elem = find('li.' + listName.gsub(" ", "_")).find("li", :text => listItem)
    # capybara's wait isn't working for us, so do our own sleeping
    if elem.nil?
      i = 0
      while i < 4 and elem.nil?
        i += 1
        sleep 1
        elem = find('li.' + listName.gsub(" ", "_")).find("li", :text => listItem)        
      end
    end

    elem.click
  end
end


When /^I have found the distribution group with display name "([^\"]*)"$/ do |displayName|
  sleep 2
  elem = find("#distribution_list ." + displayName.gsub(" ", "_") )
  if elem.nil?
    within ("#distribution_list") do
      elem_link = find('.next_page')
      elem_link.click()
    end
    And %{I have found the distribution group with display name "#{displayName}"}
  end
  elem
end

Then /^"([^\"]*)" should be a member of "([^\"]*)"$/ do |userOrContactName, groupName|
  group = DistributionGroup.find(groupName)
  assert !(group.ExchangeUsers.find {|g| g.cn == userOrContactName }.nil?)
end

Then /^"([^\"]*)" should not be a member of "([^\"]*)"$/ do |userOrContactName, groupName|    
  group = DistributionGroup.find(groupName)
  assert (group.ExchangeUsers.find {|g| g.cn == userOrContactName }.nil?)
end