Feature: Create new vpn user
  An admin user
  Should be able to
  Create a new vpn user

  Scenario: User creates user successfully
    #Given I am signed up as "admin_tester/Admin Tester/admin_tester@example.com"
    Given I am logged in as "admin_tester/Password1"
    When I go to the dashboard
    And I follow "Create New User"
    And I fill in "First Name" with "Tester_b"
    And I fill in "Last Name" with "Test"
    And I fill in "Full Name" with "Tester Test"
    And I fill in "Log On Name" with "tester_b_test"
    And I fill in "Password" with "Password1"
    And I fill in "Confirm Password" with "Password1"
    And I check "User must change password"
    And I check "VPN User"
    And I press "Submit" within ".create_new_user_container"
    Then I should see "User added"
    And I should see "tester_b_test-vpn" within ".user_list"