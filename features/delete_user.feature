Feature: Delete user
  An admin user
  Should be able to
  Delete user

  Background:
    Given I close "#cacti_cred_container" modal box

  Scenario: Admin deletes user successfully
    Given I am logged in as "admin_tester/Password1"
    Given I have a user with alias "test_delete"
    When I go to the dashboard
    And I have found the user with alias "test_delete" within "#application"
    And I will confirm on next step
    And I follow "Delete" within "#test_delete"
    Then I should see "User deleted"

  Scenario: Admin deletes vpn user successfully
    Given I am logged in as "admin_tester/Password1"
    Given I have a vpn user with alias "test_delete_two"
    When I go to the dashboard
    When I follow "Manage VPN Users"
    And I have found the user with alias "test_delete_two-vpn" within "#vpn_users_container"
    And I follow "vpn_del_test_delete_two-vpn"
    And I press "Delete"
    Then I should see "User Deleted"