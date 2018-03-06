*** Settings ***

Resource  tests/HEDA.robot
Suite Setup  Set Login Url
Suite Teardown  Close Browser

*** Test Cases ***

Create Course Connection
    Open Test Browser
    &{contact} =        Create Contact
    ${department_id} =  Create Department
    &{term} =           Create Term             ${department_id}
    &{course} =         Create Course           ${department_id}
    &{offering} =       Create Course Offering  &{course}[Id]  &{term}[Id]
    
    Create Course Connection   &{contact}[Id]  &{offering}[Name]

    Go To Record Home          &{contact}[Id]
    ${count} =                 Get Related List Count  Course Connections
    Should Be Equal            ${count}  ${1}
