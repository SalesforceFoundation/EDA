*** Settings ***

Resource       cumulusci/robotframework/Salesforce.robot
Library        EDA.py

*** Keywords ***
Create Test User
    [Documentation]  This creates a test user via the salesforce API
    [Arguments]
    ...  ${first_name}  ${last_name}  ${mailing_street}  ${mailing_city}  ${mailing_state}  ${mailing_country}

    ${contact_id} =   Salesforce Insert  Contact
    ...                 FirstName=${first_name}
    ...                 LastName=${last_name}
    ...                 MailingStreet=${mailing_street}
    ...                 MailingCity=${mailing_city}
    ...                 MailingState=${mailing_state}
    ...                 MailingCountry=${mailing_country}


Initialize Test Data
    Open Test Browser
    Create Test User  Joe      Mazzocco   5345 Calero Ave        San Jose     CA     USA    
    Create Test User  Sandy    Thompson   534 Calero Ave         San Jose     CA     USA
    Create Test User  Andy     Wright     9989 Blossom Hill Rd   Sacramento   CA     USA
    Create Test User  Sam      Sharp      11 King Street         Clearfield   MI     USA
    Create Test User  William  Young      674 Dunne Street       Roy          MA     USA
    Create Test User  Matthew  Taylor     711 First Avenue       Boston       NY     USA
    Create Test User  Douglas  Smith      15219 Sierra Madre     Alpine       AZ     USA
    Create Test User  Joseph   Mazzocco   544 Pebblewood Ct      San Jose     CA     USA
    Create Test User  Sally    Moore      800 Spring Grove Rd    Hollister    KS     USA
    Create Test User  Betsy    Miller     945 Fort Dutson Ln     Deerfield    AK     USA
    Create Test User  Ronald   Crohime    77777 Duplome Drive    Mheghee      HI     USA
