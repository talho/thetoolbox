Feature: Create new vpn user
  An admin user
  Should be able to
  Create a new vpn user

  Background:
    Given I am logged in as "admin_tester/Password1"
    And I go to the dashboard
    And I close "#cacti_cred_container" modal box

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
    And I check "VPN User"
    And I press "Submit" within ".create_new_user_container"
    Then I should see "User added"
    And I have found the user with alias "tester_b_test"
    And I clean up
        | name              | exchangetype |
        | tester_b_test     | user         |
