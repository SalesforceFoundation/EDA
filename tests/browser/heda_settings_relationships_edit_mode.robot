*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Validate Edit Mode For Relationships, Settings
    [tags]    unstable
    Go To Heda Settings
    Wait Until Element Is visible	//a[contains(text(),'Relationships')]
    Click Link				//a[contains(text(),'Relationships')]

    # Go into Edit mode 
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@class='slds-button-group']//span[contains(text(), 'Save')]

    Select From List By Label       //select[contains(@class,'reciprocal-method')]   Value Inversion
    Select From List By Label       //select[contains(@class,'reciprocal-method')]   List Setting

    # Reciprocal Settings tab
    Click Element                   //a[contains(@class,'rel-recip-settings-menulink')]
    Click Element                   //input[contains(@class,'rec-settg-active')]/parent::label

    # Autocreation tab
    Click Element                   //a[contains(@class,'rel-autoc-settings-menulink')]
*** Keywords ***



