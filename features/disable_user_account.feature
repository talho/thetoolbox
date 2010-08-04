#Feature: Disable/Enable user account
#  An admin user
#  Should be able to
#  Disable/Enable a user account
#
#  Background:
#    Given I am logged in as "admin_tester/Password1"
#    And I close ".cacti_cred_container" modal box
#    When I go to the dashboard
#    And I close ".cacti_cred_container" modal box
#
#  Scenario: Admin disables and enables user account successfully
#    And I will confirm on next step
#    And I follow "Disable"
#    Then I should see "User Disabled"
#    When I go to the dashboard
#    And I will confirm on next step
#    And I follow "Enable"
#    Then I should see "User Enabled"
