*** Settings ***
Documentation   Validate Education Cloud Settings home page
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/EducationCloudSettingsPageObject.py
...             robot/EDA/resources/ReleaseManagementPageObject.py

Suite Setup     Initialize test data
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify education cloud settings app is displayed
    [Documentation]         Validates 'Education Cloud Settings" app is displayed under app tile.
    [tags]                  rbt:high        W-9549044
    Open test browser 
    Open app launcher
    Verify item exists       Education Cloud Settings

Verify products tools and resources tiles are displayed
    [Documentation]         Validates the products, tools and resources tiles are displayed.
    [tags]                  rbt:high        W-9549044
    Open test browser 
    Go to education cloud settings home
    Current page should be                  Home        Education Cloud Settings
    Verify app tiles displayed
    ...                                     Products=Education Data Architecture
    ...                                     Tools=Settings Health Check
    ...                                     Resources=Trailhead
    ...                                     Resources=Trailblazer Community
    ...                                     Resources=YouTube

Verify release management page is displayed when user clicks on go to release management button
    [Documentation]         Validates 'Release Management' page is displayed after clicking on the Go to Release Management
    [tags]                  rbt:high        W-10059978
    Open test browser 
    Go to education cloud settings home
    Current page should be                  Home        Education Cloud Settings
    Click app in edc home                   Go to Release Management
    Current page should be                  Home        Release Management

Verify user without class access renders release management page with toast error
    [Documentation]         Validates 'Release Management' page with access error is displayed after clicking on the Go to Release Management
    [tags]                  rbt:high        W-10059980
    #give user partial permission to access Release Management page, but not see the release gates
    Run task        add_permission_set_perms
    ...             api_names=Internal_Only_for_Testing
    ...             class_accesses=${{ [{"apexClass": "${ns}EducationCloudSettingsController", "enabled": True}] }}

    Open test browser        useralias=noaccess
    Go to education cloud settings home
    Current page should be                  Home        Education Cloud Settings
    Click app in edc home                   Go to Release Management
    Current page should be                  Home        Release Management
    Verify error is displayed           You do not have access to the Apex class named 'ReleaseGateController'.

    #remove permission added for test
    Run task        add_permission_set_perms
    ...             api_names=Internal_Only_for_Testing
    ...             class_accesses=${{ [{"apexClass": "${ns}EducationCloudSettingsController", "enabled": False}] }}


*** Keywords ***
Initialize test data
    [Documentation]         
    ${ns} =     Get EDA namespace prefix