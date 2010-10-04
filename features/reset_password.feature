Feature: Reset user password
  An admin user
  Should be able to
  Reset a user password

  Background:
    Given I am logged in as "admin_tester/Password1"
    And I go to the dashboard
    And I close "#cacti_cred_container" modal box

  Scenario: User resets user password successfully
    And I follow "Reset Password"
    And I fill in "New password" with "Password1"
    And I fill in "Confirm password" with "Password1"
    And I press "Submit" within "#reset_password_container"
    Then I should see "User password changed successfully"

  Scenario: User fails to enter proper information
    When I will confirm on next step
    And I follow "Reset Password"
    And I press "Submit" within "#reset_password_container"
    Then I should see "Please make sure that both fields are not empty" within the alert box

  Scenario: User fails to properly confirm password
    When I will confirm on next step
    And I follow "Reset Password"
    And I fill in "New password" with "Password1"
    And I fill in "Confirm password" with "Password2"
    And I press "Submit" within "#reset_password_container"
    Then I should see "Please make sure that both passwords match" within the alert box

  Scenario: User enters invalid password
    When I will confirm on next step
    And I follow "Reset Password"
    And I fill in "New password" with "password1"
    And I fill in "Confirm password" with "password1"
    And I press "Submit" within "#reset_password_container"
    Then I should see "The password did not meet password complexity requirements" within the alert box

  Scenario: User attempts another invalid password change
    When I will confirm on next step
    And I follow "Reset Password"
    And I fill in "New password" with "pass.word"
    And I fill in "Confirm password" with "pass.word"
    And I press "Submit" within "#reset_password_container"
    Then I should see "The password did not meet password complexity requirements" within the alert box