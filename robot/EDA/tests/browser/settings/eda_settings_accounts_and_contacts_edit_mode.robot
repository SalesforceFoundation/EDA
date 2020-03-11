*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Keywords ***
Test Checkbox
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
    [Setup]  Run keywords
    ...  Go to EDA Settings
    ...  AND  Click on element  tabs.accountsandcontacts
    ...  AND  Click on element  account_types.edit

    Test Checkbox                   Academic Program
    Test Checkbox                   Administrative
    Test Checkbox                   Business Organization
    Test Checkbox                   Educational Institution
    Test Checkbox                   Household Account
    Test Checkbox                   Sports Organization
    Test Checkbox                   University Department

    Click on Element                account_types.save
    Close toast message

Unclick Checkboxes
    Wait for Locator                account_types.edit
    Click on Element                account_types.edit

    Wait for Locator                account_types.administrative
    Click on Element                account_types.administrative

    Test Checkbox                   Academic Program
    Test Checkbox                   Administrative
    Test Checkbox                   Business Organization
    Test Checkbox                   Educational Institution
    Test Checkbox                   Household Account
    Test Checkbox                   Sports Organization
    Test Checkbox                   University Department

    Wait for Locator                account_types.save
    Click on Element                account_types.save
