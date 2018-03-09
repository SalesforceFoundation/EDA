*** Settings ***

Resource  cumulusci/robotframework/Salesforce.robot

*** Keywords ***

API Create Contact
    ${first_name} =  Generate Random String
    ${last_name} =   Generate Random String
    ${contact_id} =  Salesforce Insert  Contact
    ...                  FirstName=${first_name}
    ...                  LastName=${last_name}
    &{contact} =     Salesforce Get  Contact  ${contact_id}
    [return]         &{contact}

API Create Term
    [Arguments]       ${account_id}
    ${term_name} =    Generate Random String
    ${term_id} =      Salesforce Insert  Term__c
    ...                   Name=${term_name} 
    ...                   Account__c=${account_id} 
    &{term} =         Salesforce Get  Term__c  ${term_id}
    [return]          &{term}

API Create Course
    [Arguments]       ${account_id}
    ${course_name} =  Generate Random String
    ${course_id} =    Salesforce Insert  Course__c
    ...                   Name=${course_name} 
    ...                   Account__c=${account_id} 
    &{course} =       Salesforce Get  Course__c  ${course_id}
    [return]          &{course}

API Create Course Offering
    [Arguments]       ${course_id}  ${term_id}
    ${offering_id} =  Salesforce Insert  Course_Offering__c
    ...                   Course__c=${course_id} 
    ...                   Term__c=${term_id} 
    &{offering} =     Salesforce Get  Course_Offering__c  ${offering_id}
    [return]          &{offering}

API Create Course Enrollment
    [Arguments]       ${contact_id}  ${offering_id}
    ${rt_id} =        Get Record Type Id  Course_Enrollment__c  Student
    ${enrollment_id} =  Salesforce Insert  Course_Enrollment__c
    ...                   Contact__c=${contact_id} 
    ...                   Course_Offering__c=${offering_id} 
    ...                   RecordTypeId=${rt_id} 
    &{enrollment} =   Salesforce Get  Course_Enrollment__c  ${enrollment_id}
    [return]          &{enrollment}

API Create Department
    [Arguments]       ${record_type}=University_Department
    ${dept_name} =    Generate Random String
    ${rt_id} =        Get Record Type Id  Account  University_Department
    ${dept_id} =      Salesforce Insert  Account
    ...                   Name=${dept_name} 
    ...                   RecordTypeId=${rt_id} 
    &{department} =   Salesforce Get  Account  ${dept_id}
    [return]          &{department}

API Create Program
    [Arguments]       ${record_type}=Academic_Program
    ${prog_name} =    Generate Random String
    ${rt_id} =        Get Record Type Id  Account  Academic_Program
    ${prog_id} =      Salesforce Insert  Account
    ...                   Name=${prog_name}
    ...                   RecordTypeId=${rt_id}
    &{program} =      Salesforce Get  Account  ${prog_id}
    [return]          &{program}

Create Contact
    Go To Object Home         Contact
    Sleep                     5
    Click Object Button       New
    ${first_name} =           Generate Random String
    ${last_name} =            Generate Random String
    Populate Form
    ...                       First Name=${first_name}
    ...                       Last Name=${last_name}
    Click Modal Button        Save    
    Wait Until Modal Is Closed
    ${contact_id} =           Get Current Record Id
    Store Session Record      Contact  ${contact_id}
    [return]                  ${contact_id}

Create Course Enrollment
    [Arguments]                ${contact_id}  ${offering_name}
    Go To Record Home          ${contact_id}
    Click Related List Button  Course Connections  New
    Select Record Type         Student
    Populate Lookup Field      Course Offering ID  ${offering_name}
    Click Modal Button         Save
    Wait Until Modal Is Closed
    @{records} =               Salesforce Query  Course_Enrollment__c
    ...                            Contact__c=${contact_id}
    ...                            Course_Offering__r.Name=${offering_name}
    &{enrollment} =            Get From List  ${records}  0
    Store Session Record       Course_Enrollment__c  &{enrollment}[Id]

Create Department
    ${department_name} =  Generate Random String
    Go To Object Home     Account
    Click Object Button   New
    Select Record Type    University Department
    Populate Form         Account Name=${department_name}
    Click Modal Button    Save
    Wait Until Modal Is Closed
    ${department_id} =    Get Current Record Id
    Store Session Record  Account  ${department_id}
    [return]              ${department_id}

Create Program
    ${program_name} =     Generate Random String
    Go To Object Home     Account
    Click Object Button   New
    Select Record Type    Academic Program
    Populate Form         Account Name =${program_name}
    Click Modal Button    Save
    Wait Until Modal is Closed
    ${program_id} =       Get Current Record Id
    Store Session Record  Account  ${program_id}
    [return]              ${program_id}
