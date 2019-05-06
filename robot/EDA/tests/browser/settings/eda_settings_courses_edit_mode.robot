*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***


Validate Edit Mode For Courses - Edit Mode, Settings
    Go To Eda Settings
    Wait for Locator	            eda_settings.courses
    Click on Element                eda_settings.courses
    
    Click Button                    Edit

    #For purposes of checking edit mode, we will go into edit mode, but will not execute the 'run copy' button

    Click Button                    Save 

*** Keywords ***

