*** Settings ***

Resource        robot/HEDAP/resources/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***


Validate Edit Mode For Courses - Edit Mode, Settings
    Go To Heda Settings
    Wait for Locator	            heda_settings.courses
    Click on Element                heda_settings.courses
    
    Click Button                    Edit

    #For purposes of checking edit mode, we will go into edit mode, but will not execute the 'run copy' button

    Click Button                    Save 

*** Keywords ***

