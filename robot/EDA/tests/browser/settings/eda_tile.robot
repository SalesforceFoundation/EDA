*** Settings ***
Documentation   Check for EDA tile

Resource        robot/EDA/resources/EDA.robot
Library         robot/EDA/resources/EDA.py
Suite Setup     Open test browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***
Verify EDA tile
    Open app launcher
    Verify app exists    EDA