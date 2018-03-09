*** Settings ***

Resource  tests/HEDA.robot
Suite Setup  Set Login Url
Suite Teardown  Close Browser

*** Test Cases ***

Create Program Enrollment
    Open Test Browser
