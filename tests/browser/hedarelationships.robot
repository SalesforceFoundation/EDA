*** Settings ***

Resource        cumulusci/robotframework/Heda.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser


*** Keywords ***



Go To Heda Home
    Go To Heda Home


Go To Heda Relationships
    Go To Heda Relationships

Go To Heda Reciprocal Settings
    Go To Heda Reciprocal Settings
    Click Affiliations Button  Settings  Affiliations
