Feature: White List Settings
  As an admin/user
  I should be able to view and change White List Settings for the OU and users
  To allow certain external email users to bypass the spam filters

  Scenario: Admin can add a domain to the OU White List
    Given I am logged in as "admin_tester/Password1"
    When I go to the dashboard
    And I follow "White List Settings"
    And I should not see "example.com"
    And I select "Domain" from "Scope"
    And I fill in "Domain" with "example.com"
    And I check "White List for entire domain"
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
    And I check "White List for entire domain"
    And I press "Add Email"
    Then I should see "Email added to White List"
    And I should see "Domain White List Entry: email@example.com"

  Scenario: User can add a domain to his personal White List
    Given I am logged in as "test/Password1"
    When I go to the dashboard
    And I follow "White List Settings"
    And I should not see "example.com"
    And I select "Domain" from "Scope"
    And I fill in "Domain" with "example.com"
    And I press "Add Domain"
    Then I should see "Domain added to White List"
    And I should see "Personal White List Entry: example.com"
    

  Scenario: User can add an email to his personal White List
    Given I am logged in as "test/Password1"
    When I go to the dashboard
    And I follow "White List Settings"
    And I should not see "user@example.com"
    And I select "Email" from "Scope"
    And I fill in "Email" with "user@example.com"
    And I press "Add Email"
    Then I should see "Email added to White List"
    And I should see "Personal White List Entry: user@example.com"

  Scenario: Admin can add a domain to his personal White List
    Given I am logged in as "admin_tester/Password1"
    When I go to the dashboard
    And I follow "White List Settings"
    And I should not see "example.com"
    And I select "Domain" from "Scope"
    And I fill in "Domain" with "example.com"
    And I press "Add Domain"
    Then I should see "Domain added to White List"
    And I should see "Personal White List Entry: example.com"

  Scenario: Admin can add an email to his personal White List
    Given I am logged in as "admin_tester/Password1"
    When I go to the dashboard
    And I follow "White List Settings"
    And I should not see "user@example.com"    
    And I select "Email" from "Scope"
    And I fill in "Email" with "user@example.com"
    And I press "Add Email"
    Then I should see "Email added to White List"
    And I should see "Personal White List Entry: user@example.com"

  Scenario: User can delete White List entries
    Given I am logged in as "admin_tester/Password1"
    When I go to the dashboard
    And I follow "White List Settings"
    And I should not see "email@example.com"
    And I select "Email" from "Scope"
    And I fill in "Email" with "email@example.com"
    And I check "White List for entire domain"
    And I press "Add Email"
    Then I should see "Email added to White List"
    And I should see "Domain White List Entry: email@example.com"
    And I follow "Delete"
    Then I should see "Entry Deleted"
    And I should not see "email@example.com"
    
    

