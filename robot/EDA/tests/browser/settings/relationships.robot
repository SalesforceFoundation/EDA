*** Settings ***
Documentation   Validate relationships tab in EDA Settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/RelationshipsSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Run keywords
...             Go to EDA settings tab          Relationships      AND
...             Update reciprocal method value      Reciprocal Method=List Setting
...             Update checkbox value       Allow Auto-Created Duplicate Relations=false

*** Test Cases ***
Verify relationship settings can retain values on save
    [Documentation]         Checks the values of 'Reciprocal Method' and 'Allow auto-created
    ...                     duplicate relations' are retained after making an update to their values
    ...                     and click on save button
    [tags]                    unstable        W-7989099
    Verify dropdown value
    ...                         Reciprocal Method=List Setting
    Verify checkbox value
    ...                         Allow Auto-Created Duplicate Relations=false
    Click action button on EDA settings page        Edit
    Update reciprocal method value
    ...                         Reciprocal Method=Value Inversion
    Update checkbox value
    ...                         Allow Auto-Created Duplicate Relations=true
    Click action button on EDA settings page        Save
    Go to EDA settings tab      Relationships
    Verify dropdown value
    ...                         Reciprocal Method=Value Inversion
    Verify checkbox value
    ...                         Allow Auto-Created Duplicate Relations=true