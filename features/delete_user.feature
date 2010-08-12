Feature: Delete user
  An admin user
  Should be able to
  Delete user

  Background:
    Given I am logged in as "admin_tester/Password1"
    Given I have a user with alias "test_delete"

  Scenario: Admin deletes user successfully    
    And I have found the user with alias "test_delete"
    And I will confirm on next step
    And I follow "Delete" within "#test_delete"
    Then I should see "User deleted"