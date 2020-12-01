*** Settings ***
Documentation   Validates course connections backfill sub tab in EDA settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/CourseConnectionsSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Go to EDA settings tab          Course Connections

*** Test Cases ***
Verify backfill settings error message when course connections is unchecked
    [Documentation]         Checks enable course connection is disabled and then verifies the
    ...                     warning message banner is displayed in the backfill tab. Verifies the
    ...                     checkbox "I understand and am ready to run backfill" is not checked.
    ...                     Checks the button "Run Backfill" is not active.
    [tags]                  unstable        W-041785        rbt:high
    Update enable cc to default
    Verify enable course connections            false
    Select course connections subtab            Backfill
    Verify backfill warning                     true
    Verify backfill checkbox value              false
    Verify button status
    ...                                         Run Backfill=disabled

Verify backfill field functionality when course connections is enabled
    [Documentation]         Checks enable course connection is enabled and then verifies the
    ...                     backfill field functionality
    [tags]                  unstable        W-8448330        rbt:high
    Click action button on EDA settings page    Edit
    Set enable course connections
    Click action button on EDA settings page    Save
    Select course connections subtab            Backfill
    Select backfill checkbox
    Click backfill button
    Verify backfill toast message       The backfill was queued successfully.
    Reload Page
    Go to EDA settings tab          Course Connections
    Select course connections subtab            Backfill
    Verify backfill checkbox value              false




