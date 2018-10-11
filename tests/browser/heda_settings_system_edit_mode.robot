*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Go To Heda Settings
    Go To Heda Settings
    Select Frame			//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'System')]
    Wait Until Element Is visible	//a[contains(text(),'System')]

Validate Edit Mode For HEDA Settings, SYSTEM
    
    Go To Heda Settings
    Select Frame                    //iframe[contains(@id, "vfFrameId")]

    Click Link				        //a[contains(text(),'System')]
    Wait Until Element Is visible	//a[contains(text(),'System')]

    #Go into Edit mode now
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@class='slds-button-group']//span[contains(text(), 'Save')] 

*** Keywords ***


