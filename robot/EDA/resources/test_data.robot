*** Keywords ***
Create Test User
    [Documentation]  This creates a test user via the salesforce API
    [Arguments]
    ...  ${first}  ${last}  ${mailing_street}  ${mailing_city}  ${mailing_zip}
    ...  ${mailing_state}  ${mailing_country}

    ${contact_id} =   Salesforce Insert  Contact
    ...                 FirstName=${first_name}
    ...                 LastName=${last_name}
    ...                 Primary_Address_Type__c=Work
    ...                 MailingStreet=${mailing_street}
    ...                 MailingCity=${mailing_city}
    ...                 MailingState=${mailing_state}
    ...                 MailingCountry=${mailing_country}
    ...                 MailingZip=${mailing_zip}


Initialize Test Data
    #                 First    Last       Street                 City         Zip       State  Country
    #                 -------- ---------- ---------------------- ------------ --------- ------ -------
    Create Test User  Joe      Mazzocco   5345 Calero Ave        San Jose     95023     CA     USA    
    Create Test User  Sandy    Thompson   534 Calero Ave         San Jose     95023     CA     USA
    Create test user  Andy     Wright     9989 Blossom Hill Rd   Sacramento   95101     CA     USA
    Create test user  Sam      Sharp      11 King Street         Clearfield   84145     MI     USA
    Create test user  William  Young      674 Dunne Street       Roy          83932     MA     USA
    Create test user  Matthew  Taylor     711 First Avenue       Boston       93929     NY     USA
    Create test user  Douglas  Smith      15219 Sierra Madre     Alpine       84004     AZ     USA
    Create test user  Joseph   Mazzocco   544 Pebblewood Ct      San Jose     95022     CA     USA
    Create test user  Sally    Moore      800 Spring Grove Rd    Hollister    95004     KS     USA
    Create test user  Betsy    Miller     945 Fort Dutson Ln     Deerfield    82034     AK     USA

