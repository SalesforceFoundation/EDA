*** Settings ***
Documentation   Validate Education Cloud Settings home page
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/EducationCloudSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify education cloud settings app is displayed
    [Documentation]         Validates 'Education Cloud Settings" app is displayed under app tile.
    [tags]                  unstable        rbt:high        W-00000000
    Open app launcher
    Verify item exists       Education Cloud Settings

Verify products tools and resources tiles are displayed
    [Documentation]         Validates the products, tools and resources tiles are displayed.
    [tags]                  unstable        rbt:high        W-0000000
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