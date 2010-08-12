Feature: Create new user
  An admin user
  Should be able to
  Create a new user

  Background:
    Given I am logged in as "admin_tester/Password1"
    When I go to the dashboard

  Scenario: User creates user successfully
    Given "tester_b_test" should not be a user
    When I follow "Create User"
    And I fill in "First Name" with "Tester_b"
    And I fill in "Last Name" with "Test"
    And I fill in "Full Name" with "Tester Test"
    And I fill in "Log On Name" with "tester_b_test"
    And I fill in "User Password" with "Password1"
    And I fill in "Confirm Password" with "Password1"
    And I check "User must change password"
    And I press "Submit" within ".create_new_user_container"
    Then I should see "User added"
    And I have found the user with alias "tester_b_test"
    And I clean up
        | name          | exchangetype |
        | tester_b_test | user         |


  Scenario: User fails to enter proper information
    And I will confirm on next step
    And I follow "Create User"
    And I fill in "First Name" with "Tester"
    And I fill in "Last Name" with "Test"
    And I fill in "User Password" with "Password1"
    And I press "Submit" within ".create_new_user_container"
    Then I should see "Please correct the following items" within the alert box

  Scenario: User attempts to create existing member
    Given I have a user with alias "junk_tester"
    And I follow "Create User"
    And I fill in "First Name" with "Junk"
    And I fill in "Last Name" with "Tester"
    And I fill in "Full Name" with "Junk Tester"
    And I fill in "Log On Name" with "junk_tester"
    And I fill in "User Password" with "Password1"
    And I fill in "Confirm Password" with "Password1"
    And I check "User must change password"
    And I press "Submit" within ".create_new_user_container"
    Then I should see "Entry junk_tester Already Exists"
    And I clean up
      | name         | exchangetype |
      | junk_tester  | user |
