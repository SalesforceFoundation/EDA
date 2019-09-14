*** Settings ***

Resource        cumulusci/robotframework/Salesforce.robot
Library         robot/EDA/resources/EDA.py
Library         DateTime

*** Variables ***
${PRINT_PACKAGE}        true

*** Keywords ***
Open Test Browser And Print Package Details
    [Documentation]         Opens the test browser and runs a keyword that prints package details from setup
    Open Test Browser
    Run Keyword If          '${PRINT_PACKAGE.lower()}' == 'true'     Capture SAL and EDA package details


Capture SAL and EDA package details
    [Documentation]         Captures the package details from SAL setup page and prints it to console
    Set Global Variable                 ${PRINT_PACKAGE}            false
    Wait Until Loading Is Complete
    Go To Setup Home
    Wait For New Window                 Home | Salesforce
    Select Window                       Home | Salesforce
    Wait Until Loading Is Complete
    Populate Placeholder                Quick Find          Installed Packages
    Wait Until Loading Is Complete
#    Select Frame With Value             Installed Packages ~ Salesforce -
#    Print Package Details
#    Unselect Frame

Capture Screenshot and Close Browser If Tests Passed
    [Documentation]         Captures screenshot if a test fails and closes the browser if all tests pass else leaves the browser open
    Run Keyword If Any Tests Failed     Capture Page Screenshot
    Run Keyword If All Tests Passed     Close Browser
    Run Keyword If All Tests Passed     Delete Session Records

Capture Screenshot and Delete Records and Close Browser
    [Documentation]         Captures screenshot if a test fails, deletes session records and closes the browser
    Run Keyword If Any Tests Failed      Capture Page Screenshot
    Close Browser
    Delete Session Records


API Create Term
    [Arguments]       ${account_id}  &{fields}
    ${term_name} =    Generate Random String
    ${term_id} =      Salesforce Insert  Term__c
    ...                   Name=${term_name}
    ...                   Account__c=${account_id}
    ...                   &{fields}
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

Populate Create And Return Contact with Address
    [Arguments]      ${first_name}      ${last_name}      ${mailing_street}      ${mailing_city}      ${mailing_zip}      ${mailing_state}      ${mailing_country}
    Go To Object Home         Contact
    Click Object Button       New
    Populate Form
    ...                       First Name=${first_name}
    ...                       Last Name=${last_name}
    Click Dropdown            Primary Address Type
    Click Link                link=Work
    Populate Address          Mailing Street            ${mailing_street}
    Populate Address          Mailing City              ${mailing_city}
    Populate Address          Mailing Zip/Postal Code   ${mailing_zip}
    Populate Address          Mailing State/Province    ${mailing_state}
    Populate Address          Mailing Country           ${mailing_country}
    Click Modal Button        Save
    Wait Until Modal Is Closed

    ${contact_id} =           Get Current Record Id
    Store Session Record      Contact  ${contact_id}
    [return]                  ${contact_id}

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

API create program plan
    [Documentation]         Creating a Program Plan through API call
    [Arguments]             ${program_plan_name}    &{fields}

    ${ns} =                 Get EDA namespace prefix
    ${prog_plan_id} =       Salesforce Insert       ${ns}Program_Plan__c
    ...                         Name=${program_plan_name}
    ...                         &{fields}
    &{program_plan} =       Salesforce Get          ${ns}Program_Plan__c   ${prog_plan_id}
    [return]                &{program_plan}

API create plan requirement
    [Documentation]         Creating a Plan Requirement through API call
    [Arguments]             ${plan_req_name}        ${program_plan_id}      &{fields}

    ${ns} =                 Get EDA namespace prefix
    ${prog_req_id} =        Salesforce Insert       ${ns}Plan_Requirement__c
    ...                         Name=${plan_req_name}
    ...                         ${ns}Program_Plan__c=${program_plan_id}
    ...                         &{fields}
    &{plan_requirement} =   Salesforce Get          ${ns}Plan_Requirement__c   ${prog_req_id}
    [return]                &{plan_requirement}

API Get ID
    [Documentation]         Returns the ID of a record identified by the given field_name and field_value input for a specific object
    [Arguments]             ${obj_name}             ${field_name}               ${field_value}
    @{records} =            Salesforce Query        ${obj_name}
    ...                         select=Id
    ...                         ${field_name}=${field_value}
    &{Id} =                 Get From List           ${records}      0
    [return]                &{Id}[Id]

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
    Populate Form         Account Name=${program_name}
    Click Modal Button    Save
    Wait Until Modal is Closed
    ${program_id} =       Get Current Record Id
    Store Session Record  Account  ${program_id}
    [return]              ${program_id}

API Create Contact
    ${first_name} =  Generate Random String
    ${last_name} =   Generate Random String
    ${contact_id} =  Salesforce Insert  Contact
    ...                  FirstName=${first_name}
    ...                  LastName=${last_name}
    &{contact} =     Salesforce Get  Contact  ${contact_id}
    [return]         &{contact}
  
Create Contact
    ${first_name} =           Generate Random String
    ${last_name} =            Generate Random String
    Go To Object Home         Contact
    Click Object Button       New
    Populate Form
    ...                       First Name=${first_name}
    ...                       Last Name=${last_name}
    Click Modal Button        Save    
    Wait Until Modal Is Closed
    ${contact_id} =           Get Current Record Id
    Store Session Record      Contact  ${contact_id}
    [return]                  ${contact_id}
    



API Create Advising Or Walkin Appointment
    [Documentation]
    ...                     Creates an advising or walkin appointment through API. Returns dictionary representing the created advising appointment
    ...
    ...                     Required parameters are:
    ...
    ...                     |   location        |   value of Location field. Current existing values: 'In person' and 'By phone'    |
    ...                     |   advising_type   |   value of Topic field. Ex: 'Academic'    |
    ...                     |   advising_topic  |   value of Subtopic field. Ex: 'Degree Planning', 'Grade Concerns'    |
    ...                     |   StartDate       |   Start time of the appointment. Format should be YYYY-MM-DD HH:MI:SS |
    ...                     |   EndDate         |   End time of the appointment. Format should be YYYY-MM-DD HH:MI:SS   |
    ...                     |                   |   Any additional field-value pairs can be passed too  |

    [Arguments]             ${location}   ${advising_type}   ${advising_topic}    ${StartDate}    ${EndDate}    &{fields}

    ${ns} =                 Get SAL namespace prefix
    ${description} =        Generate Random String
    ${end_date} =           Convert Time To UTC Timezone    ${EndDate}
    ${name} =               Set Variable    ${advising_type} - ${advising_topic}
    ${organizer_id} =       API Get Id      User        Name        DevAdmin User
    ${start_date} =         Convert Time To UTC Timezone    ${StartDate}

    ${advisee_record} =     API Get Id      Case        Subject     Andy Young Advisee Record
    ${attendee_id} =        API Get Id      User        Name        Andy Young

    ${adv_appt_id} =        Salesforce Insert   ${ns}Appointment__c
    ...                         ${ns}Description__c=${description}
    ...                         ${ns}EndDateTime__c=${end_date}
    ...                         ${ns}Location__c=${location}
    ...                         Name=${name}
    ...                         OwnerId=${organizer_id}
    ...                         ${ns}StartDateTime__c=${start_date}
    ...                         ${ns}Subtopic__c=${advising_topic}
    ...                         ${ns}Topic__c=${advising_type}
    ...                         &{fields}
    &{adv_appt} =           Salesforce Get      ${ns}Appointment__c   ${adv_appt_id}

    ${adv_attendee_id} =    Salesforce Insert   ${ns}AppointmentAttendee__c
    ...                         ${ns}AdviseeRecord__c=${advisee_record}
    ...                         ${ns}Appointment__c=&{adv_appt}[Id]
    ...                         ${ns}Attendee__c=${attendee_id}
    ...                         ${ns}Role__c=Attendee

    ${adv_organizer_id} =   Salesforce Insert   ${ns}AppointmentAttendee__c
    ...                         ${ns}Appointment__c=&{adv_appt}[Id]
    ...                         ${ns}Attendee__c=${organizer_id}
    ...                         ${ns}Role__c=Organizer

    [return]                &{adv_appt}



Create Contact with Email
    ${first_name} =           Generate Random String
    ${last_name} =            Generate Random String
    Go To Object Home         Contact
    Click Object Button       New
    Populate Form
    ...                       First Name=${first_name}
    ...                       Last Name=${last_name}
    ...                       Work Email= dshattuck@salesforce.com
    Click Modal Button        Save    
    Wait Until Modal Is Closed
    ${contact_id} =           Get Current Record Id
    Store Session Record      Contact  ${contact_id}
    [return]                  ${contact_id}

Create Contact with Address
    ${first_name} =           Generate Random String
    ${last_name} =            Generate Random String
    Go To Object Home         Contact
    Click Object Button       New
    Populate Form
    ...                       First Name=${first_name}
    ...                       Last Name=${last_name}
    Click Dropdown            Primary Address Type
    Click Link                link=Work
    Populate Address          Mailing Street            50 Fremont Street  
    Populate Address          Mailing City              San Francisco
    Populate Address          Mailing Zip/Postal Code   95320
    Populate Address          Mailing State/Province    CA
    Populate Address          Mailing Country           USA  
    Click Modal Button        Save    
    Wait Until Modal Is Closed
    
    ${contact_id} =           Get Current Record Id
    Store Session Record      Contact  ${contact_id}
    [return]                  ${contact_id}     

New Contact for HouseHold
    Click Related List Button  Contacts    New 
    Wait Until Modal Is Open
    ${first_name} =           Generate Random String
    ${last_name} =            Generate Random String
    Populate Form
    ...                       First Name=${first_name}
    ...                       Last Name=${last_name}
    Click Modal Button        Save    
    Wait Until Modal Is Closed
    Go To Object Home         Contact
    Click Link                link= ${first_name} ${last_name}
    ${contact_id} =           Get Current Record Id
    Store Session Record      Account  ${contact_id}
    [return]                  ${contact_id} 
        
Create Organization Foundation   
    ${account_name} =          Generate Random String
    Go To Object Home          Account
    Click Object Button        New
    Select Record Type         Organization
    Populate Form
    ...                        Account Name=${account_name}
    Click Modal Button         Save    
    Wait Until Modal Is Closed
    ${account_id} =            Get Current Record Id
    Store Session Record       Account  ${account_id}
    [return]                   ${account_id}
    
Create HouseHold    
    ${account_name} =         Generate Random String
    Go To Object Home         Account
    Click Object Button       New
    Select Record Type        Household Account
    Populate Form
    ...                       Account Name=${account_name}
    Click Modal Button        Save    
    Wait Until Modal Is Closed
    ${account_id} =           Get Current Record Id
    Store Session Record      Account  ${account_id}
    [return]                  ${account_id}

Create Primary Affiliation
    # Create Organization Account
    ${account_id} =             Create Organization Foundation
    &{account} =                Salesforce Get  Account  ${account_id}
    
    # Create Contact
    ${contact_id} =             Create Contact with Email
    &{contact} =                Salesforce Get  Contact  ${contact_id}
    Select Tab                  Details
    Scroll Page To Location     100    300
    Click Edit Button           Edit Primary Affiliation
    Populate Lookup Field       Primary Affiliation    &{account}[Name]
    Click Record Button         Save
    [Return]                    ${account_id}    ${contact_id}

Create Secondary Affiliation
    # Create Organization Account
    ${account_id} =             Create Organization Foundation
    &{account} =                Salesforce Get  Account  ${account_id}
    
    # Create Contact
    ${contact_id} =             Create Contact with Email
    &{contact} =                Salesforce Get  Contact  ${contact_id}
    Scroll Page To Location     50    400
    Click Related List Button   Organization Affiliations    New
    Populate Lookup Field       Organization    &{account}[Name]
    Click Modal Button          Save
    [Return]                    ${account_id}    ${contact_id}
    
Create Opportunities
    [Arguments]                 ${opp_name}    ${hh_name}
    Select Window
    Sleep                       2
    Populate Form
    ...                         Opportunity Name= ${opp_name}
    ...                         Amount=100
    Click Dropdown              Stage
    Click Link                  link=Closed Won
    Populate Lookup Field       Account Name    ${hh_name}
    Click Dropdown              Close Date
    Pick Date                   10
    Select Modal Checkbox       Do Not Automatically Create Payment
    Click Modal Button          Save

Choose Frame
    [Arguments]                 ${frame}
    Select Frame                //iframe[contains(@title,'${frame}')]
    
Select Frame with ID
    [Arguments]                 ${id}
    Select Frame                //iframe[contains(@id, '${id}')]
    
Select Frame With Title
    [Arguments]                 ${name}
    Select Frame                //iframe[@title= '${name}']
    
Scroll Page To Location
    [Arguments]                 ${x_location}    ${y_location}
    Execute JavaScript          window.scrollTo(${x_location},${y_location})

Go to EDA settings
    [Documentation]             Clicks on App Waffle and selects 'EDA Settings' tab
    Select app launcher tab     EDA Settings
    Select frame with title     accessibility title
