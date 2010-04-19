Feature: Disable/Enable user account
  An admin user
  Should be able to
  Disable/Enable a user account

  Scenario: Admin disables user account successfully
    Given I am signed up as "admin_tester"
    When I go to the sign in page
    And I select "Test" from "Authenticate"
    And I sign in as "admin_tester/Password1"
    And I should be signed in
    And I go to the dashboard
    And I follow "Disable"
    Then I should see "User Disabled"

  Scenario: Admin enables user account successfully
    Given I am signed up as "admin_tester"
    When I go to the sign in page
    And I select "Test" from "Authenticate"
    And I sign in as "admin_tester/Password1"
    And I should be signed in
    And I go to the dashboard
    And I follow "Enable"
    Then I should see "User Enabled"