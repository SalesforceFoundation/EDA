*** Settings ***

Resource        robot/HEDAP/resources/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Validate Edit Mode For Accounts and Contacts, Settings
    [tags]  unstable
    Go To Heda Settings
    Wait for Locator            	tabs.accountsandcontacts
    Click on Element                tabs.accountsandcontacts
    
    #Go into Edit mode 
    Click Button                    Edit

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


    # Uncheck everything
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Academic Program')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Administrative')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Business Organization')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Educational Institution')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Household Account')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Sports Organization')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'University Department')]

    #Save the changes
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Save')]




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
    
    Click Button                    Save


    # Now restore everything back to what it was before the test
    Click Button                    Edit

    # Uncheck everything
    Wait for Locator                account_types.academic
    Click on Element                account_types.academic
    Click on Element                account_types.administrativecheckbox
    Click on Element                account_types.business
    Click on Element                account_types.educational
    Click on Element                account_types.household
    Click on Element                account_types.sports
    Click on Element                account_types.university

    #Save the changes
    Click Button                    Save

*** Keywords ***

