*** Settings ***
  
Resource        cumulusci/robotframework/Salesforce.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Keywords ***


Create Contact
    ${first_name} =  Generate Random String
    ${last_name} =  Generate Random String
    ${contact_id} =  Salesforce Insert  Contact  FirstName=${first_name}  LastName=${last_name}
    &{contact} =  Salesforce Get  Contact  ${contact_id}
    [return]  &{contact}


*** Test Cases ***

Go To Heda Home
    Go To Heda Home
    #Wait Until Element Is visible     //header[@id='oneHeader']/div[3]/one-appnav/div/one-app-nav-bar/nav/ul/li[10]/a/span  timeout=10
    Click Element       //a[contains(text(),'System')]
    #Wait Until Element Is visible	//*[@id="afflTab"]/a
    #Click Element	//*[@id="afflTab"]/a
    #Wait Until Element Is visible	//a[contains(text(),'Settings')]
    #Click Element	//a[contains(text(),'Settings')]
    #Wait Until Element Is visible	//a[contains(text(),'Settings')]	

