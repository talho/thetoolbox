Feature: Manage Distribution List
  An Admin User
  Will be able to
  Create and Manage Distribution List

  Scenario: User Creates A New Distribution List
    Given I am logged in as "admin_tester/Password1"
    When I go to the dashboard
    And I follow "Create New Distribution List"
    And I fill in "List Name" with "Test List"
    And I press "Submit" within ".distribution_container"
    Then I should see "Distribution List Added"

  Scenario: Admin adds users to distribution list
    Given I am logged in as "admin_tester/Password1"
    When I go to the dashboard
    And I follow "Add to Distribution List"
    And I follow "Test List"
    And I follow "Add New User"
    And I select "admin_tester" from "User List"
    And I press "Add User"
    Then I should see "User Added" within ".distribution_container"

  Scenario: Admin adds new contact to distribution list
    Given I am logged in as "admin_test/Password1"
    When I go to the dashboard
    And I follow "Add to Distribution List"
    And I follow "Test List"
    And I follow "Add New Contact"
    And I fill in "First Name" with "Contact"
    And I fill in "Last Name" with "Tester"
    And I fill in "Display Name" with "Contact Tester"
    And I fill in "Alias" with "ContactTester"
    And I press "Add Contact"
    Then I should see "Contact Added" within ".distribution_container"

    
