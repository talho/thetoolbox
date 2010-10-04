Feature: Manage Distribution List
  An Admin User
  Will be able to
  Create and Manage Distribution List

  Background: Logged in and closed cacti
    Given I am logged in as "admin_tester/Password1"
    And I am on the dashboard
    And I close "#cacti_cred_container" modal box

  Scenario: User Creates A New Distribution List
    Given "Test List" does not exist
    When I follow "Create Distribution List"
    And I fill in "Distribution list name" with "Test List" within ".create_distribution_list"
    And I press "Submit" within "#create_distribution_list"
    Then I should see "Distribution Group created successfully."
    And I clean up
    | name      | exchangetype  |
    | Test List | group         |

  Scenario: Admin adds users to distribution list
    Given I have a distribution list named "Test List"
    And "testuser" should not be a user
    And "Test List" has no members
    And "Test User" is a user with alias "testuser"
    When I go to the dashboard page   
    When I have found the user with alias "testuser" within "#application"
    And I follow "Add to Distribution List" within "#testuser.delete"
    When I have found the distribution group with display name "Test List"
    And I select "Test List" within "#distribution_list"
    And I follow "Add Contact"
    Then I should see "Test User" within "#distribution_list .Test_List"
    And "Test User" should be a member of "Test List"
    And I clean up
    | name      | exchangetype  |
    | Test List | group         |
    | testuser  | user          |

  Scenario: Admin adds new contact to distribution list
    Given I have a distribution list named "Test List"
    And "Test List" has no members
    When I follow "Manage Distribution List"
    When I have found the distribution group with display name "Test List"
    And I select "Test List" within "#distribution_list"
    And I follow "Add Contact"
    And I fill in "Contact Name" with "Contact Tester"
    And I fill in "Contact Address" with "contact@testme.com"
    And I press "Submit" within "#add_to_group_form_container"
    Then I should see "Contact Tester" within "#distribution_list .Test_List"
    And "Contact Tester" should be a member of "Test List"
    And I clean up
    | name           | exchangetype |
    | Test List      | group        |
    | ContactTester  | contact      |

  Scenario: Admin enters invalid email into new contact form
    Given I have a distribution list named "Test List"
    And "Test List" has no members
    When I follow "Manage Distribution List"
    When I have found the distribution group with display name "Test List"
    And I select "Test List" within "#distribution_list"
    And I follow "Add Contact"
    And I fill in "Contact Name" with "Contact Tester"
    And I fill in "Contact Address" with "contact@testme"
    And I override alert
    And I press "Submit" within "#add_to_group_form_container"
    Then I should see "Please provide a valid email address" within the alert box
    Then I should not see "Contact Tester" within "#distribution_list .Test_List"
    And "Contact Tester" should not be a member of "Test List"
    And I clean up
    | name           | exchangetype |
    | Test List      | group        |
    | ContactTester  | contact      |

  Scenario: Admin enters invalid input into new contact form
    Given I have a distribution list named "Test List"
    And "Test List" has no members
    When I follow "Manage Distribution List"
    When I have found the distribution group with display name "Test List"
    And I select "Test List" within "#distribution_list"
    And I follow "Add Contact"
    And I fill in "Contact Name" with ""
    And I fill in "Contact Address" with ""
    And I override alert
    And I press "Submit" within "#add_to_group_form_container"
    Then I should see "Please correct the following items and try again" within the alert box
    And I clean up
    | name           | exchangetype |
    | Test List      | group        |

  Scenario: Admin adds duplicate contact to distribution list
    Given I have a distribution list named "Test List"
    And "Test Contact" is a contact and a member of "Test List"
    When I follow "Manage Distribution List"
    When I have found the distribution group with display name "Test List"
    And I select "Test List" within "#distribution_list"
    And I follow "Add Contact"
    And I fill in "Contact Name" with "Test Contact"
    And I fill in "Contact Address" with "fake_email@testme.com"
    And I override alert
    And I press "Submit" within "#add_to_group_form_container"
    Then I should see "A contact with name Test Contact with a different email was found on the server" within the alert box
    And I should see "Test Contact" within "#distribution_list .Test_List"
    And I clean up
    | name           | exchangetype |
    | Test List      | group        |
    | TestContact    | contact      |

  Scenario: Admin removes user or contact from distribution list
    Given I have a distribution list named "Test List"
    And "Test Contact" is a contact and a member of "Test List"
    When I follow "Manage Distribution List"
    When I have found the distribution group with display name "Test List"
    And I select "Test List" within "#distribution_list"
    And I follow "Delete" within "#ucn_del_TestContact"
    And I press "Delete"
    Then I should not see "Test Contact" within "#distribution_list .Test_List"
    And "Test Contact" should not be a member of "Test List"
    And I clean up
    | name        | exchangetype |
    | Test List   | group        |
    | TestContact | contact      |