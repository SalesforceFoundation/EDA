*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Validate Edit Mode For Accounts and Contacts, Settings
    [tags]  unstable
    Go To Heda Settings
    Select Frame			//iframe[contains(@id, "vfFrameId")]
    Wait Until Element Is visible	//a[contains(text(),'Accounts and Contacts')]
    Click Element                 //a[contains(text(),'Accounts and Contacts')]

    #Go into Edit mode 
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@class='slds-button-group']//span[contains(text(), 'Save')] 

    # Select Multi-Address Account Types
    Click Element                   //span[contains(text(),'Administrative')]/parent::*

    Wait Until Element Is visible   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Academic Program')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Academic Program')]

    Wait Until Element Is visible   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Administrative')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Administrative')]

    Wait Until Element Is visible   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Business Organization')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Business Organization')]

    Wait Until Element Is visible   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Educational Institution')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Educational Institution')]

    Wait Until Element Is visible   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Household Account')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Household Account')]

    Wait Until Element Is visible   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Sports Organization')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'Sports Organization')]

    Wait Until Element Is visible   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'University Department')]
    Click Element                   //div[contains(@class,'slds-form-element__control')]//span[contains(text(),'University Department')]


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


*** Keywords ***

