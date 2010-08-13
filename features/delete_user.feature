Feature: Delete user
  An admin user
  Should be able to
  Delete user

  Background:
    Given I have a user with alias "test_delete"
    And I am logged in as "admin_tester/Password1"
    And I close "#cacti_cred_container" modal box

  Scenario: Admin deletes user successfully    
    And I have found the user with alias "test_delete"
    And I will confirm on next step
    And I follow "Delete" within "#test_delete"
    Then I should see "User deleted"