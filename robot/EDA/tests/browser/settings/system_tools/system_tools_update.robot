*** Settings ***
Documentation   Validates all update jobs in system tools in EDA settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Go to education cloud settings

*** Test Cases ***
Validate update administrative account name system job
    [Documentation]         Verifies the update all administrative account names job is triggered by
    ...                     checking the toast message displayed to the user
    [tags]                                      W-9425207       rbt:high
    Select settings from navigation pane        System Tools
    Update system tools             Update      Update All Administrative Account Names=Update
    ...                                         Update All Household Account Names=Update
    ...                                         Preferred Email and Preferred Phone=Update
    ...                                         Legacy Ethnicity Data=Update
    ...                                         Legacy Course Enrollment Data=Update
    ...                                         Extended Course Descriptions=Update