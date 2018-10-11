*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Go To Heda Settings
    Go To Heda Settings
    Select Frame			//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'Accounts and Contacts')]
    Wait Until Element Is visible	//a[contains(text(),'Accounts and Contacts')]

Validate Edit Mode For Accounts and Contacts, Settings
    
    

    #Go into Edit mode 
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@class='slds-button-group']//span[contains(text(), 'Save')] 


    Wait Until Element Is visible   //div[@class='slds-tabs--default']//span[contains(text(),'Academic Program')]
    Click Element                   //div[@class='slds-tabs--default']//span[contains(text(),'Academic Program')]

    Wait Until Element Is visible   //div[@class='slds-tabs--default']//span[contains(text(),'Administrative')]
    Click Element                   //div[@class='slds-tabs--default']//span[contains(text(),'Administrative')]

    Wait Until Element Is visible   //div[@class='slds-tabs--default']//span[contains(text(),'Business Organization')]
    Click Element                   //div[@class='slds-tabs--default']//span[contains(text(),'Business Organization')]

    Wait Until Element Is visible   //div[@class='slds-tabs--default']//span[contains(text(),'Educational Institution')]
    Click Element                   //div[@class='slds-tabs--default']//span[contains(text(),'Educational Institution')]

    Wait Until Element Is visible   //div[@class='slds-tabs--default']//span[contains(text(),'Household Account')]
    Click Element                   //div[@class='slds-tabs--default']//span[contains(text(),'Household Account')]

    Wait Until Element Is visible   //div[@class='slds-tabs--default']//span[contains(text(),'Sports Organization')]
    Click Element                   //div[@class='slds-tabs--default']//span[contains(text(),'Sports Organization')]

    Wait Until Element Is visible   //div[@class='slds-tabs--default']//span[contains(text(),'University Department')]
    Click Element                   //div[@class='slds-tabs--default']//span[contains(text(),'University Department')]




    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Academic Program')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Administrative')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Business Organization')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Educational Institution')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Household Account')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Household Account')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Sports Organization')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'University Department')]


    #Save the changes
    #Select Checkbox                 //label[@class='slds-checkbox']//input[@type='checkbox']
    #Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Save')]


*** Keywords ***

