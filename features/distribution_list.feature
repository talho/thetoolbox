Feature: Manage Distribution List
  An Admin User
  Will be able to
  Create and Manage Distribution List

  Background: Logged in and closed cacti
    Given I am logged in as "admin_tester/Password1"
    And I am on the dashboard
    And I close ".cacti_cred_container" modal box

  Scenario: User Creates A New Distribution List
    Given "Test List" does not exist
    When I follow "Create Distribution List"
    And I fill in "Distribution list name" with "Test List"
    And I press "Submit" within "#create_distribution_list"
    Then I should see "Distribution Group created successfully."
    And I clean up
    | name      | exchangetype  |
    | Test List | group         |

  Scenario: Admin adds users to distribution list
    Given I have a distribution list named "Test List"
    And "Test List" has no members
    And "Test User" is a user with alias "testuser"
    When I have found the user with alias "testuser"
    And I follow "Add to Distribution List" within "#testuser.delete"
    And I select "Test List" within ".distribution_list_display"
    And I press "Add To Group"
    Then I should see "Test User" within ".distribution_list_user_display"
    And "Test User" should be a member of "Test List"
    And I clean up
    | name      | exchangetype  |
    | Test List | group         |
    | testuser  | user          |

  Scenario: Admin adds new contact to distribution list
    Given I have a distribution list named "Test List"
    And "Test List" has no members
    When I follow "Manage Distribution List"
    And I select "Test List" within ".distribution_list_display"
    And I press "Add To Group"
    And I fill in "Contact Name" with "Contact Tester"
    And I fill in "Contact Address" with "contact@testme.com"
    And I press "Submit" within "#add_to_group_form_container"
    Then I should see "Contact Tester" within ".distribution_list_user_display"
    And "Contact Tester" should be a member of "Test List"
    And I clean up
    | name           | exchangetype |
    | Test List      | group        |
    | ContactTester  | contact      |


  Scenario: Admin adds duplicate contact to distribution list
    Given I have a distribution list named "Test List"
    And "Test Contact" is a contact and a member of "Test List"
    When I follow "Manage Distribution List"
    And I select "Test List" within ".distribution_list_display"
    And I press "Add To Group"
    And I fill in "Contact Name" with "Test Contact"
    And I fill in "Contact Address" with "unique135134@testme.com"
    And I override alert
    And I press "Submit" within "#add_to_group_form_container"
    Then I should see "A contact with name Test Contact with a different email was found on the server\. Please provide a unique contact name\." within the alert box
    And I should see "Test Contact" within ".distribution_list_user_display"
    And "Test Contact" should be a member of "Test List"
    And I clean up
    | name           | exchangetype |
    | Test List      | group        |
    | ContactTester  | contact      |

  Scenario: Admin removes user or contact from distribution list
    Given I have a distribution list named "Test List"
    And "Test Contact" is a contact and a member of "Test List"
    When I follow "Manage Distribution List"
    And I select "Test List" within ".distribution_list_display"
    And I select member "Test Contact" for list "Test List" within ".distribution_list_user_display"
    And I press "Remove User"
    Then I should not see "Test Contact" within ".distribution_list_user_display"
    And "Test Contact" should not be a member of "Test List"
    And I clean up
    | name        | exchangetype |
    | Test List   | group        |
    | TestContact | contact      |