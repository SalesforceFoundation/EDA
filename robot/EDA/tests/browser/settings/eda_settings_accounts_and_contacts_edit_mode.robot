*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

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

    # Check everything   
    FOR    ${account}     IN      @{account_types}
            Wait for Locator        ${account}
            Click on Element        ${account}
    END  

'''
    Wait for Locator                account_types.administrative
    Click on Element                account_types.administrative

    Wait for Locator                account_types.academic
    Click on Element                account_types.academic

    Wait for Locator                account_types.administrativecheckbox
    Click on Element                account_types.administrativecheckbox

    Wait for Locator                account_types.business
    Click on Element                account_types.business

    Wait for Locator                account_types.educational 
    Click on Element                account_types.educational

    Wait for Locator                account_types.household 
    Click on Element                account_types.household

    Wait for Locator                account_types.sports
    Click on Element                account_types.sports

    Wait for Locator                account_types.university 
    Click on Element                account_types.university 
'''
 
    # Click Button                  Save (in page object for this test)
    Click on Element                account_types.save
    # Close toast message (part of save and close)

        # Wait for Locator                account_types.edit
        # Click on Element                account_types.edit

    # Uncheck everything
    Wait for Locator                account_types.administrative
    Click on Element                account_types.administrative

    Wait for Locator                account_types.academic
    Click on Element                account_types.academic

    Wait for Locator                account_types.administrativecheckbox
    Click on Element                account_types.administrativecheckbox

    Wait for Locator                account_types.business
    Click on Element                account_types.business

    Wait for Locator                account_types.educational 
    Click on Element                account_types.educational

    Wait for Locator                account_types.household 
    Click on Element                account_types.household

    Wait for Locator                account_types.sports
    Click on Element                account_types.sports

    Wait for Locator                account_types.university 
    Click on Element                account_types.university 

    Click on Element                account_types.save
