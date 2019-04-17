*** Settings ***

Resource        robot/HEDAP/resources/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

    
Let Us Populate Create And Return Contact with Address
    ${contact_id} =  API Populate Create And Return Contact with Address    Joe      Mazzocco   5345 Calero Ave             San Jose     95023     CA     USA    
    &{contact} =  Salesforce Get    Contact             ${contact_id}
    Header Field Value              Account Name        &{contact}[LastName] Administrative Account
    Select Tab    Details 
    Page Should Contain    5345 Calero Ave  
    Go To Object Home         Contact
    Verify Record    &{contact}[FirstName] &{contact}[LastName]

Create Contact Sandy Thompson
    ${contact_id} =  API Populate Create And Return Contact with Address    Sandy       Thompson   534 Calero Ave             San Jose     95023     CA     USA    
    &{contact} =  Salesforce Get    Contact             ${contact_id}
    Header Field Value              Account Name        &{contact}[LastName] Administrative Account
    Select Tab                      Details 
    Page Should Contain             534 Calero Ave  
    Go To Object Home               Contact
    Verify Record                   &{contact}[FirstName] &{contact}[LastName]

Create Contact Andy Wright
    ${contact_id} =  API Populate Create And Return Contact with Address    Andy        Wright     9989 Blossom Hill Rd       Sacramento   95101     CA     USA
    &{contact} =  Salesforce Get    Contact             ${contact_id}
    Header Field Value              Account Name        &{contact}[LastName] Administrative Account
    Select Tab                      Details 
    Page Should Contain             9989 Blossom Hill Rd  
    Go To Object Home               Contact
    Verify Record                   &{contact}[FirstName] &{contact}[LastName]

Create Contact Sam Sharp
    ${contact_id} =  API Populate Create And Return Contact with Address    Sam         Sharp      11 King Street             Clearfield   84145     MI     USA
    &{contact} =  Salesforce Get    Contact             ${contact_id}
    Header Field Value              Account Name        &{contact}[LastName] Administrative Account
    Select Tab                      Details 
    Page Should Contain             11 King Street  
    Go To Object Home               Contact
    Verify Record                   &{contact}[FirstName] &{contact}[LastName]

Create Contact William Young
    ${contact_id} =  API Populate Create And Return Contact with Address    William     Young      674 Dunne Street           Roy          83932     MA     USA
    &{contact} =  Salesforce Get    Contact             ${contact_id}
    Header Field Value              Account Name        &{contact}[LastName] Administrative Account
    Select Tab                      Details 
    Page Should Contain             674 Dunne Street
    Go To Object Home               Contact
    Verify Record                   &{contact}[FirstName] &{contact}[LastName]

Create Contact Matthew Taylor
    ${contact_id} =  API Populate Create And Return Contact with Address    Matthew     Taylor     711 First Avenue           Boston       93929     NY     USA
    &{contact} =  Salesforce Get    Contact             ${contact_id}
    Header Field Value              Account Name        &{contact}[LastName] Administrative Account
    Select Tab                      Details 
    Page Should Contain             711 First Avenue
    Go To Object Home               Contact
    Verify Record                   &{contact}[FirstName] &{contact}[LastName]

Create Contact Douglas Smith
    ${contact_id} =  API Populate Create And Return Contact with Address    Douglas     Smith      15219 Sierra Madre         Alpine       84004     AZ     USA 
    &{contact} =  Salesforce Get    Contact             ${contact_id}
    Header Field Value              Account Name        &{contact}[LastName] Administrative Account
    Select Tab                      Details 
    Page Should Contain             15219 Sierra Madre
    Go To Object Home               Contact
    Verify Record                   &{contact}[FirstName] &{contact}[LastName]

Create Contact Joseph Mazzocco
    ${contact_id} =  API Populate Create And Return Contact with Address    Joseph      Mazzocco   544 Pebblewood Ct          San Jose     95022     CA     USA
    &{contact} =  Salesforce Get    Contact             ${contact_id}
    Header Field Value              Account Name        &{contact}[LastName] Administrative Account
    Select Tab                      Details 
    Page Should Contain             544 Pebblewood Ct
    Go To Object Home               Contact
    Verify Record                   &{contact}[FirstName] &{contact}[LastName]

Create Contact Sally Moore
    ${contact_id} =  API Populate Create And Return Contact with Address    Sally       Moore      800 Spring Grove Rd        Hollister    95004     KS     USA
    &{contact} =  Salesforce Get    Contact             ${contact_id}
    Header Field Value              Account Name        &{contact}[LastName] Administrative Account
    Select Tab                      Details 
    Page Should Contain             800 Spring Grove Rd
    Go To Object Home               Contact
    Verify Record                   &{contact}[FirstName] &{contact}[LastName]

Create Contact Betsy Miller
    ${contact_id} =  API Populate Create And Return Contact with Address    Betsy       Miller     945 Fort Dutson Ln         Deerfield    82034     AK     USA
    &{contact} =  Salesforce Get    Contact             ${contact_id}
    Header Field Value              Account Name        &{contact}[LastName] Administrative Account
    Select Tab                      Details 
    Page Should Contain             945 Fort Dutson Ln
    Go To Object Home               Contact
    Verify Record                   &{contact}[FirstName] &{contact}[LastName]

