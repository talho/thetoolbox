Feature: Create new user
  An admin user
  Should be able to
  Create a new user

  Background:
    Given I am logged in as "admin_tester/Password1"
    And I go to the dashboard
    And I close "#cacti_cred_container" modal box

  Scenario: User creates user successfully
    Given "tester_b_test" should not be a user
    When I follow "Create User"
    And I fill in "First Name" with "Tester_b" within "#create_new_user_container" 
    And I fill in "Last Name" with "Test" within "#create_new_user_container"
    And I fill in "Full Name" with "Tester Test" within "#create_new_user_container"
    And I fill in "Log On Name" with "tester_b_test" within "#create_new_user_container"
    And I fill in "User Password" with "Password1" within "#create_new_user_container"
    And I fill in "Confirm Password" with "Password1" within "#create_new_user_container"
    And I click on "#_user_ch_pwd"
    And I press "Submit" within "#create_new_user_container"
    Then I should see "User added"
    And I close "#cacti_cred_container" modal box
    And I have found the user with alias "tester_b_test" within "#application"
    And I clean up
        | name          | exchangetype |
        | tester_b_test | user         |

  Scenario: User attempts to create a user with a password containing their login name
    Given "tester_b_test" should not be a user
    And I will confirm on next step
    And I follow "Create User"
    And I fill in "First Name" with "Tester_b" within "#create_new_user_container"
    And I fill in "Last Name" with "Test" within "#create_new_user_container"
    And I fill in "Full Name" with "Tester Test" within "#create_new_user_container"
    And I fill in "Log On Name" with "tester_b_test" within "#create_new_user_container"
    And I fill in "User Password" with "Tester_b_test1" within "#create_new_user_container"
    And I fill in "Confirm Password" with "Tester_b_test1" within "#create_new_user_container"
    And I click on "#_user_ch_pwd"
    And I press "Submit" within "#create_new_user_container"
    Then I should see "Please make sure your password does not contain your login name" within the alert box

  Scenario: User attempts to create a user with a password containing part of their full name
    Given "tester_b_test" should not be a user
    And I will confirm on next step
    And I follow "Create User"
    And I fill in "First Name" with "Tester_b" within "#create_new_user_container"
    And I fill in "Last Name" with "Test" within "#create_new_user_container"
    And I fill in "Full Name" with "Tester Test" within "#create_new_user_container"
    And I fill in "Log On Name" with "tester_b_test" within "#create_new_user_container"
    And I fill in "User Password" with "TesterPassword1" within "#create_new_user_container"
    And I fill in "Confirm Password" with "TesterPassword1" within "#create_new_user_container"
    And I click on "#_user_ch_pwd"
    And I press "Submit" within "#create_new_user_container"
    And I will confirm on next step
    Then I should see "Please make sure your password does not contain part of your first or last name" within the alert box

  Scenario: User fails to enter proper information
    And I will confirm on next step
    And I follow "Create User"
    And I fill in "First Name" with "Tester" within "#create_new_user_container"
    And I fill in "Last Name" with "Test" within "#create_new_user_container"
    And I fill in "User Password" with "Password1" within "#create_new_user_container"
    And I press "Submit" within "#create_new_user_container"
    Then I should see "Please correct the following items" within the alert box

  Scenario: User attempts to create existing member
    Given I have a user with alias "junk_tester"
    And I follow "Create User"
    And I fill in "First Name" with "Junk" within "#create_new_user_container"
    And I fill in "Last Name" with "Tester" within "#create_new_user_container"
    And I fill in "Full Name" with "Junk Tester" within "#create_new_user_container"
    And I fill in "Log On Name" with "junk_tester" within "#create_new_user_container"
    And I fill in "User Password" with "Password1" within "#create_new_user_container"
    And I fill in "Confirm Password" with "Password1" within "#create_new_user_container"
    And I click on "#_user_ch_pwd"
    And I press "Submit" within "#create_new_user_container"
    Then I should see "Entry junk_tester Already Exists"
    And I clean up
      | name         | exchangetype |
      | junk_tester  | user |