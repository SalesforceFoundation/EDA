*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Validate Edit Mode For Accounts and Contacts, Settings
    [tags]                          unstable
    Go To Eda Settings
    Wait for Locator            	tabs.accountsandcontacts
    Click on Element                tabs.accountsandcontacts

    Click on Element                account_types.edit

    # Select Multi-Address Account Types
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
    Close toast message

    Click on Element                account_types.edit

    # Uncheck everything
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
    Close toast message

    #test save and edit again
    Click on Element                account_types.edit

    # Select Multi-Address Account Types
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

    # Now restore everything back to what it was before the test
    Click on Element                account_types.edit

    # Uncheck everything
    Wait for Locator                account_types.academic
    Click on Element                account_types.academic
    Click on Element                account_types.administrativecheckbox
    Click on Element                account_types.business
    Click on Element                account_types.educational
    Click on Element                account_types.household
    Click on Element                account_types.sports
    Click on Element                account_types.university

    Click on Element                account_types.save
