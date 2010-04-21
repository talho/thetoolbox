Feature: White List Settings
  As an admin/user
  I should be able to view and change White List Settings for the OU and users
  To allow certain external email users to bypass the spam filters

  Scenario: Admin can add a domain to the OU White List
    Given I am logged in as "admin_tester/Password1"
    When I go to the dashboard
    And I should not see "example.com"
    And I select "Domain" from "Scope"
    And I fill in "Domain" with "example.com"
    And I press "Add Domain"
    Then I should see "Domain added to White List"
    And I should see "example.com"

  Scenario: Admin can add an email to the OU White List
    Given I am logged in as "admin_tester/Password1"
    When I go to the dashboard
    And I follow "White List Settings"
    And I should not see "email@example.com"
    And I select "Email" from "Scope"
    And I fill in "Email" with "email@example.com"
    And I press "Add Email"
    Then I should see "Email added to White List"
    And I should see "email@example.com"

  Scenario: User can add a domain to his personal White List


  Scenario: User can add an email to his personal White List


  Scenario: Admin can add a domain to his personal White List


  Scenario: Admin can add an email to his personal White List

  Scenario: User maliciously tries to add a domain or email to the OU White List

  Scenario: User can delete White List entries

    
    

