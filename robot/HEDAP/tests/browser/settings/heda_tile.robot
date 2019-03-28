*** Settings ***

Resource        robot/HEDAP/resources/HEDA.robot
Library         robot/HEDAP/resources/HEDA.py
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***


Verify HEDA Tile

    Open App Launcher

    # Check for HEDA Tile
    Wait Until Element Is visible           //div[@class='slds-app-launcher__tile-body']//a[contains(text(),'HEDA')]

