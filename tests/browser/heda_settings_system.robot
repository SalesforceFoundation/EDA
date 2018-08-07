*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Go To Heda Home
    Go To Heda Home
    Select Frame			//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'System')]
    Wait Until Element Is visible	//a[contains(text(),'System')]
    

Go To Accounts and Contacts
    Go To Heda Home
    Select Frame  	      		//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'Accounts and Contacts')]
    Wait Until Element Is visible 	//a[contains(text(),'Accounts and Contacts')]

Go To Course Connections
    Go To Heda Home
    Select Frame  			//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'Course Connections')]
    Wait Until Element Is visible 	//a[contains(text(),'Course Connections')]

# Need to repair this locator, so commenting out for now
#Go To Course Connections Backfill
#    Go To Heda Home
#    Select Frame			//iframe[contains(@id, "vfFrameId")]
#    Click Link                          //a[contains(text(), 'Backfill')]
#    Wait Until Element Is visible       //a[contains(text(), 'Backfill')]  

Go To Courses
    Go To Heda Home
    Select Frame        		//iframe[contains(@id, "vfFrameId")]
    Click Link          		//a[contains(text(),'Courses')]
    Wait Until Element Is visible 	//a[contains(text(),'Courses')]

Go To Relationships
    Go To Heda Home
    Select Frame         		//iframe[contains(@id, "vfFrameId")]
    Click Link          		//a[contains(text(),'Relationships')]
    Wait Until Element Is visible 	//a[contains(text(),'Relationships')]

Go To Affiliations
    Go To Heda Home
    Select Frame        		    //iframe[contains(@id, "vfFrameId")]
    Click Link          		    //a[contains(text(),'Affiliations')]
    Wait Until Element Is visible 	//a[contains(text(),'Affiliations')]


*** Keywords ***


Get Random Contact Info
    ${first_name} =  Generate Random String
    ${last_name} =  Generate Random String
    Set Test Variable  ${first_name}  ${first_name}
    Set Test Variable  ${last_name}  ${last_name}


