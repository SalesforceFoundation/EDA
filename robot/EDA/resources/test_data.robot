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
    Create test user  Andy     Wright     9989 Blossom Hill Rd   Sacramento   CA     USA
    Create test user  Sam      Sharp      11 King Street         Clearfield   MI     USA
    Create test user  William  Young      674 Dunne Street       Roy          MA     USA
    Create test user  Matthew  Taylor     711 First Avenue       Boston       NY     USA
    Create test user  Douglas  Smith      15219 Sierra Madre     Alpine       AZ     USA
    Create test user  Joseph   Mazzocco   544 Pebblewood Ct      San Jose     CA     USA
    Create test user  Sally    Moore      800 Spring Grove Rd    Hollister    KS     USA
    Create test user  Betsy    Miller     945 Fort Dutson Ln     Deerfield    AK     USA
