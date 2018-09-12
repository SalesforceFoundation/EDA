*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Go To Heda Home
    Go To Heda Home
    Select Frame			//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'Accounts and Contacts')]
    Wait Until Element Is visible	//a[contains(text(),'Accounts and Contacts')]
    #Capture Page Screenshot

Validate Edit Mode For Accounts and Contacts, Settings
    
    
    # Go To Heda Home
    # Select Frame                    //iframe[contains(@id, "vfFrameId")]
    # Click Element                   //div[@data-aura-rendered-by='106:0']//input[@type='radio']
    # Capture Page Screenshot

    #Go into Edit mode 
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@data-aura-rendered-by='28:0']
    #Capture Page Screenshot


    # Unselect Checkbox               //div[@class='slds-tabs--default']//span[contains(text(),'Academic Program')]
    # Unselect Checkbox               //div[@class='slds-tabs--default']//span[contains(text(),'Administrative')]
    # Unselect Checkbox               //div[@class='slds-tabs--default']//span[contains(text(),'Business Organization')]
    # Unselect Checkbox               //div[@class='slds-tabs--default']//span[contains(text(),'Educational Institution')]
    # Unselect Checkbox               //div[@class='slds-tabs--default']//span[contains(text(),'Household Account')]
    # Unselect Checkbox               //div[@class='slds-tabs--default']//span[contains(text(),'Sports Organization')]
    # Unselect Checkbox               //div[@class='slds-tabs--default']//span[contains(text(),'University Department')]


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

    #Capture Page Screenshot

    Sleep                           10


    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Academic Program')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Administrative')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Business Organization')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Educational Institution')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Household Account')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Household Account')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'Sports Organization')]
    Click Element                   //div[@class='slds-form-element__control']//span[contains(text(),'University Department')]
    #Capture Page Screenshot
    Sleep                           5


    #Save the changes
    Select Checkbox                 //label[@class='slds-checkbox']//input[@type='checkbox']
    #Capture Page Screenshot
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Save')]


*** Keywords ***


Get Random Contact Info
    ${first_name} =  Generate Random String
    ${last_name} =  Generate Random String
    Set Test Variable  ${first_name}  ${first_name}
    Set Test Variable  ${last_name}  ${last_name}


