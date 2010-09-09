Feature: Create new vpn user
  An admin user
  Should be able to
  Create a new vpn user

  Background:
    Given I am logged in as "admin_tester/Password1"
    And I go to the dashboard
    And I close "#cacti_cred_container" modal box

  Scenario: User creates user-mailbox/user-vpn successfully
    Given "tester_b_test" should not be a user 
    When I follow "Create User"
    And I fill in "First Name" with "Tester_b" within "#create_new_user_container"
    And I fill in "Last Name" with "Test" within "#create_new_user_container"
    And I fill in "Full Name" with "Tester Test" within "#create_new_user_container"
    And I fill in "Log On Name" with "tester_b_test" within "#create_new_user_container"
    And I fill in "User Password" with "Password1" within "#create_new_user_container"
    And I fill in "Confirm Password" with "Password1" within "#create_new_user_container"
    And I click on "#_user_ch_pwd"
    And I click on "#_user_vpn_usr"
    And I press "Submit" within "#create_new_user_container"
    Then I should see "User added"
    And I have found the user with alias "tester_b_test" within "#application"
    And I clean up
        | name              | exchangetype |
        | tester_b_test     | user         |

  Scenario: User creates vpn user successfully
    Given "tester_b_test" should not be a user
    When I follow "Manage VPN Users"
    And I follow "Create VPN User"
    And I fill in "First Name" with "Tester_b" within "#create_vpn_user_container"
    And I fill in "Last Name" with "Test" within "#create_vpn_user_container"
    And I fill in "Full Name" with "Tester Test" within "#create_vpn_user_container"
    And I fill in "Log On Name" with "tester_b_test" within "#create_vpn_user_container"
    And I fill in "User Password" with "Password1" within "#create_vpn_user_container"
    And I fill in "Confirm Password" with "Password1" within "#create_vpn_user_container"
    And I click on "#_user_vpn_ch_pwd"
    And I press "Submit" within "#create_vpn_user_container"
    Then I should see "User added"
    And I have found the user with alias "tester_b_test-vpn" within "#vpn_users_container"
    And I clean up
        | name              | exchangetype |
        | tester_b_test-vpn | vpn-user     |   