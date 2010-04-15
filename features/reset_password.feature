Feature: Reset user password
  An admin user
  Should be able to
  Reset a user password

  Scenario: User resets user password successfully
    Given I am signed up as "admin_tester"
    When I go to the sign in page
    And I select "Test" from "Authenticate"
    And I sign in as "admin_tester/Password1"
    And I should be signed in
    And I go to the dashboard
    And I follow "Edit"
    And I fill in "New Password" with "Password1"
    And I fill in "Confirm Password" with "Password1"
    And I press "Submit"
    Then I should see "Password change successful"

  Scenario: User fails to enter proper information
    Given I am signed up as "admin_tester"
    When I go to the sign in page
    And I select "Test" from "Authenticate"
    And I sign in as "admin_tester/Password1"
    And I should be signed in
    And I go to the dashboard
    And I follow "Edit"
    And I press "Submit"
    Then I should see "Please correct the following items"

  Scenario: User fails to properly confirm password
    Given I am signed up as "admin_tester"
    When I go to the sign in page
    And I select "Test" from "Authenticate"
    And I sign in as "admin_tester/Password1"
    And I should be signed in
    And I go to the dashboard
    And I follow "Edit"
    And I fill in "New Password" with "Password1"
    And I fill in "Confirm Password" with "Password2"
    And I press "Submit"
    Then I should see "Please confirm password"