@payments
Feature: Payments
  In order to have payments on my website
  As an administrator
  I want to manage payments

  Background:
    Given I am a logged in refinery user
    And I have no payments

  @payments-list @list
  Scenario: Payments List
   Given I have payments titled UniqueTitleOne, UniqueTitleTwo
   When I go to the list of payments
   Then I should see "UniqueTitleOne"
   And I should see "UniqueTitleTwo"

  @payments-valid @valid
  Scenario: Create Valid Payment
    When I go to the list of payments
    And I follow "Add New Payment"
    And I fill in "Status" with "This is a test of the first string field"
    And I press "Save"
    Then I should see "'This is a test of the first string field' was successfully added."
    And I should have 1 payment

  @payments-invalid @invalid
  Scenario: Create Invalid Payment (without status)
    When I go to the list of payments
    And I follow "Add New Payment"
    And I press "Save"
    Then I should see "Status can't be blank"
    And I should have 0 payments

  @payments-edit @edit
  Scenario: Edit Existing Payment
    Given I have payments titled "A status"
    When I go to the list of payments
    And I follow "Edit this payment" within ".actions"
    Then I fill in "Status" with "A different status"
    And I press "Save"
    Then I should see "'A different status' was successfully updated."
    And I should be on the list of payments
    And I should not see "A status"

  @payments-duplicate @duplicate
  Scenario: Create Duplicate Payment
    Given I only have payments titled UniqueTitleOne, UniqueTitleTwo
    When I go to the list of payments
    And I follow "Add New Payment"
    And I fill in "Status" with "UniqueTitleTwo"
    And I press "Save"
    Then I should see "There were problems"
    And I should have 2 payments

  @payments-delete @delete
  Scenario: Delete Payment
    Given I only have payments titled UniqueTitleOne
    When I go to the list of payments
    And I follow "Remove this payment forever"
    Then I should see "'UniqueTitleOne' was successfully removed."
    And I should have 0 payments
 