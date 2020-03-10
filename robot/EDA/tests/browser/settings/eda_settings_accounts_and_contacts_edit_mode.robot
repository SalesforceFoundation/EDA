*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Keywords ***
Test Checkboxes
    [Arguments]                     ${account_label}
    Wait for Locator                account_types.account_checkbox    ${account_label}
    Click on element                account_types.account_checkbox    ${account_label}

*** Test Cases ***

Validate Edit Mode For Accounts and Contacts Settings
    [tags]                          unstable
    Go To Eda Settings
    Wait for Locator            	tabs.accountsandcontacts
    Click on Element                tabs.accountsandcontacts
    # Click on Tab                  Accounts and Contacts
    # in this method, add page logic
         # Click on checkbox or unclick checkbox - pass action into method
             # validate if box is checked, if checked, catch error and move on,
             # if unchecked, check, move on
         # continue for each element on page

    Wait for Locator                account_types.edit
    Click on Element                account_types.edit

    Wait for Locator                account_types.administrative
    Click on Element                account_types.administrative

Click Checkboxes
    Test Checkboxes                 Academic Program
    Test Checkboxes                 Administrative
    Test Checkboxes                 Business Organization
    Test Checkboxes                 Educational Institution
    Test Checkboxes                 Household Account
    Test Checkboxes                 Sports Organization
    Test Checkboxes                 University Department
    
    Click on Element                account_types.save
    Close toast message

Unclick Checkboxes
    Wait for Locator                account_types.edit
    Click on Element                account_types.edit

    Wait for Locator                account_types.administrative
    Click on Element                account_types.administrative

    Test Checkboxes                 Academic Program
    Test Checkboxes                 Administrative
    Test Checkboxes                 Business Organization
    Test Checkboxes                 Educational Institution
    Test Checkboxes                 Household Account
    Test Checkboxes                 Sports Organization
    Test Checkboxes                 University Department

    Wait for Locator                account_types.save
    Click on Element                account_types.save


