Feature: Delete user
  An admin user
  Should be able to
  Delete user

  Scenario: Admin deletes user successfully
    Given I am logged in as "admin_tester/Password1"
    When I go to the dashboard
    And I follow "Create New User"
    And I fill in "First Name" with "Test"
    And I fill in "Last Name" with "Delete"
    And I fill in "Full Name" with "Test Delete"
    And I fill in "Log On Name" with "test_delete"
    And I fill in "Password" with "Password1"
    And I fill in "Confirm Password" with "Password1"
    And I check "User must change password"
    And I press "Submit" within ".create_new_user_container"
    Then I should see "User added"
    And I will confirm on next step
    And I follow "Delete" within "[@id='test_delete']"
    Then I should see "User deleted"