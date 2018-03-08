*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Enroll via UI
    Open Test Browser
    &{contact} =        API Create Contact
    &{department} =     API Create Department
    &{term} =           API Create Term             &{department}[Id]
    &{course} =         API Create Course           &{department}[Id]
    &{offering} =       API Create Course Offering  &{course}[Id]  &{term}[Id]
    
    Create Course Enrollment   &{contact}[Id]  &{offering}[Name]

    Go To Record Home          &{contact}[Id]
    ${count} =                 Get Related List Count  Course Connections
    Should Be Equal            ${count}  ${1}

Enroll via API
    Open Test Browser
    &{contact} =        API Create Contact
    &{department} =     API Create Department
    &{term} =           API Create Term             &{department}[Id]
    &{course} =         API Create Course           &{department}[Id]
    &{offering} =       API Create Course Offering  &{course}[Id]  &{term}[Id]
    
    API Create Course Enrollment   &{contact}[Id]  &{offering}[Name]

    Go To Record Home   &{contact}[Id]
    ${count} =          Get Related List Count  Course Connections
    Should Be Equal     ${count}  ${1}
