*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Enroll via API
    Open Test Browser
    &{contact} =        API Create Contact
    &{offering} =       Create Offering and Parent Records
    
    API Create Course Enrollment   &{contact}[Id]  &{offering}[Id]
    Validate Contact in UI         &{contact}[Id]


Enroll via UI
    Open Test Browser
    &{contact} =        API Create Contact
    &{offering} =       Create Offering and Parent Records
    
    Create Course Enrollment   &{contact}[Id]  &{offering}[Name]
    Validate Contact in UI         &{contact}[Id]

*** Keywords ***

Create Offering and Parent Records
    &{department} =     API Create Department
    &{term} =           API Create Term             &{department}[Id]
    &{course} =         API Create Course           &{department}[Id]
    &{offering} =       API Create Course Offering  &{course}[Id]  &{term}[Id]
    [return]  &{offering}
    

Validate Contact in UI
    [Arguments]         ${contact_id}
    Go To Record Home   ${contact_id}
    ${count} =          Get Related List Count  Course Connections
    Should Be Equal     ${count}  ${1}

