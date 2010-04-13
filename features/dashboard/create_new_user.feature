Feature: Create new user
  An admin user
  Should be able to
  Create a new user

  Scenario: User signs in successfully
    Given I am signed up as "thetoolbox"
    When I go to the sign in page
    And I select "Test" from "Authenticate"
    And I sign in as "thetoolbox/Talh0Talh0"
    And I should be signed in
    And I fill in "First Name" with "Tester"
    And I fill in "Last Name" with "Test"
    And I fill in "Full Name" with "Tester Test"
    And I fill in "Password" with "Password1"
    And I fill in "Confirm Password" with "Password1"
    And I check "User must change password"
    And I press "Submit"
    Then I should see "User added"