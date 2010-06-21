Feature: Sign in
  In order to get access to protected sections of the site
  A user
  Should be able to sign in

  Scenario: User is not valid
    Given no user exists with a login of "example_user"
    When I go to the sign in page
    And I sign in as "example_user/Password1"
    Then I should see "Login is not valid" within "body"
    And I should be signed out

  Scenario: User enters wrong password
    Given I am signed up as "tester_test/Tester Test/tester_test@example.com/TALHO"
    When I go to the sign in page
    And I fill in "Login" with "tester_test"
    And I fill in "Password" with "WrongPasswordOne"
    And I select "Test" from "Authenticate"
    And I press "Sign In"
    #And I sign in as "tester_test/WrongPasswordOne"
    Then I should see "Password is not valid"
    And this is not finished
    And I should be signed out

  Scenario: User signs in successfully
    Given I am signed up as "tester_test/Tester Test/tester_test@example.com/TALHO"
    When I go to the sign in page
    And I select "Test" from "Authenticate"
    And I sign in as "tester_test/Password1"
    And I should be signed in

  Scenario: User signs in and checks "remember me"
    Given I am signed up as "tester_test/Tester Test/tester_test@example.com/TALHO"
    When I go to the sign in page
    And I select "Test" from "Authenticate"
    And I sign in with "remember me" as "tester_test/Password1"
    And I should be signed in
    When I return next time
    Then I should be signed in