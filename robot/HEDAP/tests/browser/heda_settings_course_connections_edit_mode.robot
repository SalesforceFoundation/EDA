*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***


Validate Edit Mode For Course Connections, Settings
    Go To Heda Settings
    Wait Until Element Is visible	//a[contains(text(),'Course Connections')]
    Click Link				//a[contains(text(),'Course Connections')]

    #Go into edit mode
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@class='slds-button-group']//span[contains(text(), 'Save')]

    #Verify that the checkbox is visible
    Element Should Be visible       //input[contains(@class,'slds-checkbox')]/parent::label
    Click Element                   //input[contains(@class,'slds-checkbox')]/parent::label

    Select From List By Label       //select[contains(@class,'student-course-connection-record-type-input-select')]   Student
    Select From List By Label       //select[contains(@class,'faculty-course-connection-record-type-input-select')]   Faculty

    # Save, maybe?
    # Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Save')]

*** Keywords ***
