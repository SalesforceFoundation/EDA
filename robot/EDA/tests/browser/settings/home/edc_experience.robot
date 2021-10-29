*** Settings ***
Documentation   Validate Education Cloud Settings home page
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/EducationCloudSettingsPageObject.py
...             robot/EDA/resources/ReleaseManagementPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify education cloud settings app is displayed
    [Documentation]         Validates 'Education Cloud Settings" app is displayed under app tile.
    [tags]                  rbt:high        W-9549044
    Open app launcher
    Verify item exists       Education Cloud Settings

Verify products tools and resources tiles are displayed
    [Documentation]         Validates the products, tools and resources tiles are displayed.
    [tags]                  rbt:high        W-9549044
    Reload Page
    # Below sleep to avoid inconsisten failures with app launcher loading
    Sleep                           2
    Select App Launcher Tab         Education Cloud Settings
    Current page should be          Home        Education Cloud Settings
    Verify app tiles displayed
    ...                             Products=Education Data Architecture
    ...                             Tools=Settings Health Check
    ...                             Resources=Trailhead
    ...                             Resources=Trailblazer Community
    ...                             Resources=YouTube

Verify release management page is displayed when user clicks on go to release management button
    [Documentation]         Validates 'Release Management' page is displayed after clicking on the Go to Release Management
    [tags]                  rbt:high        W-10059978
    Go to education cloud settings home
    Current page should be          Home        Education Cloud Settings
    Click app in edc home           Go to Release Management
    Current page should be          Home        Release Management