Feature: Disable/Enable user account
  An admin user
  Should be able to
  Disable/Enable a user account

  Scenario: Admin disables user account successfully
    #Given I am signed up as "admin_tester"
    Given I am logged in as "admin_tester/Password1"
    And I go to the dashboard
    And I follow "Disable"
    Then I should see "User Disabled"

  Scenario: Admin enables user account successfully
    #Given I am signed up as "admin_tester"
    Given I am logged in as "admin_tester/Password1"
    And I go to the dashboard
    And I follow "Enable"
    Then I should see "User Enabled"