Feature: Reset user password
  An admin user
  Should be able to
  Reset a user password

  Scenario: User resets user password successfully
    Given I am logged in as "admin_tester/Password1"
    And I go to the dashboard
    And I follow "Edit"
    And I fill in "New password" with "Password1"
    And I fill in "Confirm password" with "Password1"
    And I press "Submit"
    Then I should see "Password changed successfully"

  Scenario: User fails to enter proper information
    Given I am logged in as "admin_tester/Password1"
    And I go to the dashboard
    And I follow "Edit"
    And I press "Submit"
    Then I should see "Please correct the following items"

  Scenario: User fails to properly confirm password
    Given I am logged in as "admin_tester/Password1"
    And I go to the dashboard
    And I follow "Edit"
    And I fill in "New password" with "Password1"
    And I fill in "Confirm password" with "Password2"
    And I press "Submit"
    Then I should see "Please confirm password"