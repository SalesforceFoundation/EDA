*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Library         robot/EDA/resources/EDA.py
Suite Setup     Open test browser and print package details
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***


Verify EDA Tile

    Open App Launcher

    # Check for EDA Tile
    Verify App Exists    EDA


