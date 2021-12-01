*** Settings ***
Documentation   Check for EDA tile

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open test browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify EDA tile
    [Documentation]     Verifies if the EDA app is displayed in app launcher menu
    Open app launcher
    Verify app exists    Education Data Architecture