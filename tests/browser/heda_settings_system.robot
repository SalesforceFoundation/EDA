*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Go To Heda Settings
    [tags] unstable
    Select Frame			//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'System')]
    Wait Until Element Is visible	//a[contains(text(),'System')]
    

Go To Accounts and Contacts
    [tags] unstable
    Select Frame  	      		//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'Accounts and Contacts')]
    Wait Until Element Is visible 	//a[contains(text(),'Accounts and Contacts')]

Go To Course Connections
    [tags] unstable
    Select Frame  			//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'Course Connections')]
    Wait Until Element Is visible 	//a[contains(text(),'Course Connections')]


Go To Courses
    [tags] unstable
    Select Frame        		//iframe[contains(@id, "vfFrameId")]
    Click Link          		//a[contains(text(),'Courses')]
    Wait Until Element Is visible 	//a[contains(text(),'Courses')]

Go To Relationships
    [tags] unstable
    Select Frame         		//iframe[contains(@id, "vfFrameId")]
    Click Link          		//a[contains(text(),'Relationships')]
    Wait Until Element Is visible 	//a[contains(text(),'Relationships')]

Go To Affiliations
    [tags] unstable
    Select Frame        		    //iframe[contains(@id, "vfFrameId")]
    Click Link          		    //a[contains(text(),'Affiliations')]
    Wait Until Element Is visible 	//a[contains(text(),'Affiliations')]


*** Keywords ***
