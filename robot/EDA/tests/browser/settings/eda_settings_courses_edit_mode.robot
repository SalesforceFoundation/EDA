*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/CoursesSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Validate Edit Mode For Courses - Edit Mode, Settings
    Go to EDA settings tab          Courses
    
    Click Button                    Edit

    #For purposes of checking edit mode, we will go into edit mode, but will not execute the 'run copy' button

    Click Button                    Save