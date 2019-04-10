*** Settings ***

Resource        robot/EDAP/resources/EDA.robot
Library         robot/EDAP/resources/EDA.py
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***


Verify EDA Tile

    Open App Launcher

    # Check for EDA Tile
    Wait Until Element Is visible           //div[@class='slds-app-launcher__tile-body']//a[contains(text(),'EDA')]

