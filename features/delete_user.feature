Feature: Delete user
  An admin user
  Should be able to
  Delete user

  Background:
    Given I am logged in as "admin_tester/Password1"

  Scenario: Admin deletes user successfully
    When I follow "Create User"
    And I fill in "First Name" with "Test"
    And I fill in "Last Name" with "Delete"
    And I fill in "Full Name" with "Test Delete"
    And I fill in "Log On Name" with "test_delete"
    And I fill in "User Password" with "Password1"
    And I fill in "Confirm Password" with "Password1"
    And I check "User must change password"
    And I press "Submit" within ".create_new_user_container"
    Then I should see "User added"
    And I have found the user with alias "test_delete"
    And I will confirm on next step
    And I follow "Delete" within "[@id='test_delete']"
    Then I should see "User deleted"