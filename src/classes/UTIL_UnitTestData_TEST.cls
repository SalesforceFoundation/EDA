/*
    Copyright (c) 2011, Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2011 (1.x)
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description Provides automated generation of unit test data for tests throughout the org 
*/
@isTest
public class UTIL_UnitTestData_TEST {

    public static List<SObject> sObjectsToUpdate;

    /*********************************************************************************************************
    * @description Provides a simple TDTM implementation that does nothing unless the static List of 
    * sObjectsToUpdate is not null.
    * The main purpose of this test TDTM class is to test re-entrancy scenarios that might result from a custom
    * TDTM class. For example, the AFFL_AccRecordType_TEST class uses this class as an AfterInsert and AfterUpdate
    * Contact TDTM trigger that updates the account record that initially fired the AFFL_AccRecordType_TDTM logic.
    **********************************************************************************************************/
    public class Test_TDTM extends TDTM_Runnable {

        /*******************************************************************************************************
        * @description Does nothing unless the static List of sObjectsToUpdate is not null.
        * @param listNew the list of SObjects from trigger new.
        * @param listOld the list of SObjects from trigger old.
        * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
        * @param objResult the describe for the SObject.
        * @return dmlWrapper
        ********************************************************************************************************/
        public override TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, 
                                                    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
            UTIL_Debug.debug('****Entered the Test_TDTM Trigger');
            if (sObjectsToUpdate != null) {
                UTIL_Debug.debug('****Updating objects: ' + sObjectsToUpdate);
                update sObjectsToUpdate;
            }
            return new TDTM_Runnable.DmlWrapper();
        }
    }
    
    public static Contact getContact() {
    	Contact contact =  new Contact(FirstName = 'Test', LastName = 'Testerson' + Datetime.now().getTime(), 
    	                   WorkEmail__c = 'fakeemail@salesforce.org', Preferred_Email__c = 'Work', 
    	                   WorkPhone__c = '206-777-8888', PreferredPhone__c = 'Work',OtherCity = 'Seattle');
    	Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.DuplicateRuleHeader.AllowSave = true;
        contact.setOptions(dmo);
        return contact;
    }
    
    public static List<Contact> getMultipleTestContacts(Integer n) {
        List<contact> ContactsToAdd = new List<contact>();
        for(Integer i=0; i<n; i++) {
            Contact newCon = new Contact(FirstName = i + 'Test' + i, LastName = i + 'Contact_forTests' + i, WorkEmail__c = 'fakeemail' + i + '@salesforce.org', 
                             Preferred_Email__c = 'Work', WorkPhone__c = i + '06-777-888' + i, PreferredPhone__c = 'Work', OtherCity = 'Seattle');
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.DuplicateRuleHeader.AllowSave = true;
            newCon.setOptions(dmo);
            ContactsToAdd.add(newCon);
        }
        return ContactsToAdd;
    }

    public static List<Account> getMultipleTestAccounts(Integer n, ID recTypeId) {
        List<Account> AcctsToAdd = new List<Account>();
        for(Integer i=0; i<n; i++) {
            Account acc = new Account(Name = i + 'Yet Another Org ' + i, RecordTypeId = recTypeId, Website = i + 'salesforce.org');
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.DuplicateRuleHeader.AllowSave = true;
            acc.setOptions(dmo);
            AcctsToAdd.add(acc);
        }
        return AcctsToAdd;
    }

    public static User createNewUserForTests(String strUsername) {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u;	
        // to work around mixed DML errors during tests, you must create user account in its own transaction. got this
        // hack from the web.
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {        
	        u = new User(alias = 'jsmith', email='jsmith@acme.com', emailencodingkey='UTF-8', lastname='Smith', 
	            languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
	            username=strUsername);
	        insert u;
        }
        return u;
    }
    
    /*********************************************************************************************************
    * @description Initializes (but not inserts) N new Address objects.
    * @param addrCount the number of Address objects to create
    * @return The list of Address__c objects
    **********************************************************************************************************/
    public static List<Address__c> getMultipleTestAddresses(Integer addrCount) {
        List<Address__c> addrs = new List<Address__c>();
        for(Integer i = 0; i < addrCount; i++) {
            Address__c addr = new Address__c();
            addr.Address_Type__c = 'Home';
            addr.MailingStreet__c = 'Street' + i;
            addr.MailingCity__c = 'City' + i;
            addr.MailingState__c = 'Washington';
            addr.MailingPostalCode__c = 'Zip' + i;
            addr.MailingCountry__c = 'United States';
            addr.Geolocation__Latitude__s = 47.6097;
            addr.Geolocation__Longitude__s = -122.3331;
            addrs.add(addr);            
        }
        return addrs;
    }
    
    /*********************************************************************************************************
    * @description Sets up common test data for Account Addresses tests.
    * @param accCount Number of Accounts to create.
    * @param recTypeID The record type to use when creating Accounts.
    * @return The instance of AccsWithAddrs inner class with lists of Accounts and Address__c objects
    **********************************************************************************************************/    
    public static AccsWithAddrs createTestAccsAddrs(Integer accCount, String recTypeID) { 
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        
        AccsWithAddrs accsAddrs = new AccsWithAddrs();
        //instantiate accounts
        accsAddrs.accs = getMultipleTestAccounts(accCount, recTypeID);
        insert accsAddrs.accs;      
        
        //instantiate addresses
        accsAddrs.addrs = getMultipleTestAddresses(accCount);
        
        //link addresses with accounts and make them default
        for(Integer i = 0; i < accCount; i++) {
            accsAddrs.addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            accsAddrs.addrs[i].Default_Address__c = true;
        }
        //insert addresses
        insert accsAddrs.addrs;
        
        //link accounts with addresses and copy address info to accounts
        for(Integer i = 0; i < accCount; i++) {
            accsAddrs.accs[i].Current_Address__c = accsAddrs.addrs[i].Id;
            accsAddrs.accs[i].BillingStreet = accsAddrs.addrs[i].MailingStreet__c;
            accsAddrs.accs[i].BillingCity = accsAddrs.addrs[i].MailingCity__c;
            accsAddrs.accs[i].BillingState = accsAddrs.addrs[i].MailingState__c;
            accsAddrs.accs[i].BillingPostalCode = accsAddrs.addrs[i].MailingPostalCode__c;
            accsAddrs.accs[i].BillingCountry = accsAddrs.addrs[i].MailingCountry__c;
            accsAddrs.accs[i].BillingLatitude = accsAddrs.addrs[i].Geolocation__Latitude__s;
            accsAddrs.accs[i].BillingLongitude = accsAddrs.addrs[i].Geolocation__Longitude__s;
        }
        update  accsAddrs.accs;

        //clear our triggers recursion prevention since we are starting a new test
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
        return accsAddrs;
    }
    
    /*********************************************************************************************************
    * @description Groups a list of Accounts and a list of Addresses so they can be returned from a method together.
    **********************************************************************************************************/ 
    public class AccsWithAddrs {
        public List<Account> accs { public get; public set; }
        public List<Address__c> addrs { public get; public set; }
    }
    
    /*********************************************************************************************************
    * @description Sets up common test data for Contact Addresses tests.
    * @param contactCount Number of Contacts to create.
    * @return The instance of ContactsWithAddrs inner class with lists of Contacts and Address__c objects
    **********************************************************************************************************/  
    public static ContactsWithAddrs createTestContactsAddrs(Integer contactCount) {
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        
        ContactsWithAddrs contactsAddrs = new ContactsWithAddrs();        
        //instantiate contacts
        contactsAddrs.contacts = getMultipleTestContacts(contactCount);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.DuplicateRuleHeader.AllowSave = true;
        Database.insert(contactsAddrs.contacts, dmo);
        
        //instantiate addresses
        contactsAddrs.addrs = getMultipleTestAddresses(contactCount);
        
        //link addresses with contacts and make them default
        for(Integer i = 0; i < contactCount; i++) {
            contactsAddrs.addrs[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            contactsAddrs.addrs[i].Default_Address__c = true;
        }
        //insert addresses
        insert contactsAddrs.addrs;
        
       //link contacts with addresses and copy address info to contacts
        for(Integer i = 0; i < contactCount; i++) {
            contactsAddrs.contacts[i].Current_Address__c = contactsAddrs.addrs[i].Id;
            contactsAddrs.contacts[i].MailingStreet = contactsAddrs.addrs[i].MailingStreet__c;
            contactsAddrs.contacts[i].MailingCity = contactsAddrs.addrs[i].MailingCity__c;
            contactsAddrs.contacts[i].MailingState = contactsAddrs.addrs[i].MailingState__c;
            contactsAddrs.contacts[i].MailingPostalCode = contactsAddrs.addrs[i].MailingPostalCode__c;
            contactsAddrs.contacts[i].MailingCountry = contactsAddrs.addrs[i].MailingCountry__c;
            contactsAddrs.contacts[i].MailingLatitude = contactsAddrs.addrs[i].Geolocation__Latitude__s;
            contactsAddrs.contacts[i].MailingLongitude = contactsAddrs.addrs[i].Geolocation__Longitude__s;
        }
        update contactsAddrs.contacts;
        
        //clear our triggers recursion prevention since we are starting a new test
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
        return contactsAddrs;
    }
    
    /*********************************************************************************************************
    * @description Groups a list of Contacts and a list of Addresses so they can be returned from a method together.
    **********************************************************************************************************/ 
    public class ContactsWithAddrs {
        public List<Contact> contacts { public get; public set; }
        public List<Address__c> addrs { public get; public set; }
    }
    
    /*********************************************************************************************************
    * @description Sets up common test data for the Address tests.
    *    - this will create & insert N household Accounts, each with M contacts
    *    - also will create a Default Addresses for each HH Account
    *    - will also setup the default Account Processor to be HH Accounts
    * @param accCount the number of Household Accounts to create
    * @param contactCount the number of Contacts to create per Household
    * @return The instance of ContactsAccsWithAddrs inner class with lists of Contacts, Accounts, and Address__c objects
    **********************************************************************************************************/
    public static ContactsAccsWithAddrs createTestConsAccsAddrs(Integer accCount, Integer contactCount, String recTypeID) {
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        
        ContactsAccsWithAddrs consAccsAddrs = new ContactsAccsWithAddrs();
        consAccsAddrs.contacts = getMultipleTestContacts(accCount * contactCount);
        consAccsAddrs.accs = getMultipleTestAccounts(accCount, recTypeID);
        insert consAccsAddrs.accs;
        
        // link contacts with accounts
        for(Integer i = 0; i < accCount; i++) {
            for(Integer j = 0; j < contactCount; j++) {
                consAccsAddrs.contacts[ (i * contactCount) + j].AccountId = consAccsAddrs.accs[i].Id;
            }
        }
        insert consAccsAddrs.contacts; 
        
        /* With accCount = 2, contactCount = 2
            i = 0, j = 0 => contact0 parent is account0
            i = 0, j = 1 => contact1 parent is account0
            i = 1, j = 0 => contact2 parent is account1
            i = 1, j = 1 => contact3 parent is account1
        */       
        
        //instantiate addresses
        consAccsAddrs.addrs = getMultipleTestAddresses(accCount);
        
        //link addresses with accounts and make them default
        for(Integer i = 0; i < accCount; i++) {
            consAccsAddrs.addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            consAccsAddrs.addrs[i].Default_Address__c = true;
        }
        insert consAccsAddrs.addrs;
        
        //link accounts with addresses and copy address info to accounts
        for(Integer i = 0; i < accCount; i++) {
            consAccsAddrs.accs[i].Current_Address__c = consAccsAddrs.addrs[i].ID;
            consAccsAddrs.accs[i].BillingStreet = consAccsAddrs.addrs[i].MailingStreet__c;
            consAccsAddrs.accs[i].BillingCity = consAccsAddrs.addrs[i].MailingCity__c;
            consAccsAddrs.accs[i].BillingState = consAccsAddrs.addrs[i].MailingState__c;
            consAccsAddrs.accs[i].BillingPostalCode = consAccsAddrs.addrs[i].MailingPostalCode__c;
            consAccsAddrs.accs[i].BillingCountry = consAccsAddrs.addrs[i].MailingCountry__c;
            consAccsAddrs.accs[i].BillingLatitude = consAccsAddrs.addrs[i].Geolocation__Latitude__s;
            consAccsAddrs.accs[i].BillingLongitude = consAccsAddrs.addrs[i].Geolocation__Longitude__s;
        }
        update  consAccsAddrs.accs;
        
        // link contacts with addresses and copy address info to contacts
        for(Integer i = 0; i < accCount; i++) {
            Account parentAcc = consAccsAddrs.accs[i];
            Address__c addr = consAccsAddrs.addrs[i];
            for(Integer j = 0; j < contactCount; j++) {
                consAccsAddrs.contacts[ (i * contactCount) + j].Current_Address__c = parentAcc.Current_Address__c;
                consAccsAddrs.contacts[ (i * contactCount) + j].MailingStreet = addr.MailingStreet__c;
	            consAccsAddrs.contacts[ (i * contactCount) + j].MailingCity = addr.MailingCity__c;
	            consAccsAddrs.contacts[ (i * contactCount) + j].MailingState = addr.MailingState__c;
	            consAccsAddrs.contacts[ (i * contactCount) + j].MailingPostalCode = addr.MailingPostalCode__c;
	            consAccsAddrs.contacts[ (i * contactCount) + j].MailingCountry = addr.MailingCountry__c;
	            consAccsAddrs.contacts[ (i * contactCount) + j].MailingLatitude = addr.Geolocation__Latitude__s;
                consAccsAddrs.contacts[ (i * contactCount) + j].MailingLongitude = addr.Geolocation__Longitude__s;
            }
        }
        update consAccsAddrs.contacts;
        
        // clear our triggers recursion prevention since we are starting a new test
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
        return consAccsAddrs;
    }
    
    /*********************************************************************************************************
    * @description Groups a list of Accounts, a list of Contacts, and a list of Addresses so they can be returned 
    * from a method together.
    **********************************************************************************************************/ 
    // TODO - possible tech debt: can we get rid of the other two public inner classes and just use this one?
    public class ContactsAccsWithAddrs {
        public List<Account> accs { public get; public set; }
        public List<Contact> contacts { public get; public set; }
        public List<Address__c> addrs { public get; public set; }
    }

    /*********************************************************************************************************
    * @description Create an error record for the current system time.
    **********************************************************************************************************/
    public static Error__c getError() {
        Error__c error = new Error__c(Datetime__c = System.now());
        return error;
    }

    /*********************************************************************************************************
    * @description Create a list of error records for the current system time.
    **********************************************************************************************************/
    public static List<Error__c> getListOfErrors(Integer n) {
        List<Error__c> errors = new List<Error__c>();
        for(Integer i=0; i<n; i++) {
            errors.add(getError());
        }
        return errors;
    }
  
    /*********************************************************************************************************
    * @description Get a single Program Plan
    **********************************************************************************************************/
    public static Program_Plan__c getProgramPlan(){
        Program_Plan__c programPlan = new Program_Plan__c();
        programPlan.Name = 'Test Program Plan ' + Datetime.now().getTime();
        return programPlan;
    }

    /*********************************************************************************************************
    * @description Get a list of Program Plans
    * @param n the number of Program Plans to create
    **********************************************************************************************************/
    public static List<Program_Plan__c> getMultipleTestProgramPlans(Integer n) {
        List<Program_Plan__c> programPlans = new List<Program_Plan__c>();
        for(Integer i=0; i<n; i++) {
            programPlans.add(getProgramPlan());
        }
        return programPlans;
    } 

    /*********************************************************************************************************
    * @description Get a single Plan Requirement
    **********************************************************************************************************/
    public static Plan_Requirement__c getPlanRequirement(){
        Plan_Requirement__c planRequirement = new Plan_Requirement__c();
        planRequirement.Name = 'Test Plan Requirement ' + Datetime.now().getTime();
        return planRequirement;
    }

    /*********************************************************************************************************
    * @description Get a list of Plan Requirements
    * @param n the number of Plan Requirements to create
    **********************************************************************************************************/
    public static List<Plan_Requirement__c> getMultipleTestPlanRequirements(Integer n) {
        List<Plan_Requirement__c> planRequirements = new List<Plan_Requirement__c>();
        for(Integer i=0; i<n; i++) {
            planRequirements.add(getPlanRequirement());
        }
        return planRequirements;
    }

    /*********************************************************************************************************
    * @description Get a single Program Enrollment
    **********************************************************************************************************/
    public static Program_Enrollment__c getProgramEnrollment(Id accId){
        Program_Enrollment__c programEnrollment = new Program_Enrollment__c();
        programEnrollment.Account__c = accId;
        return programEnrollment;
    }

    /*********************************************************************************************************
    * @description Get a list of Program Enrollments
    * @param n the number of Program Enrollments to create
    **********************************************************************************************************/
    public static List<Program_Enrollment__c> getMultipleTestProgramEnrollments(Integer n, Id accId) {
        List<Program_Enrollment__c> programEnrollments = new List<Program_Enrollment__c>();
        for(Integer i=0; i<n; i++) {
            programEnrollments.add(getProgramEnrollment(accId));
        }
        return programEnrollments;
    }

    /*******************************************************************************************************
    * @description Inserts a new Language record for testing. 
    * @param name The name of the Language record.
    * @return The inserted Language record.
    ********************************************************************************************************/
    public static Language__c createLanguage(String name) {
        Language__c languageToInsert = new Language__c(Name = name);
        insert languageToInsert;
        return languageToInsert;
    }

    /*******************************************************************************************************
    * @description Inserts a new Contact Language record for testing. 
    * @param languageId The Language associated to the Contact Language record.
    * @param contactId The Contact associated to the Contact Language record.
    * @param isPrimaryLanguage Signifies whether or not the Contact Language should be marked as the Primary Language.
    * @return The inserted Contact Language record.
    ********************************************************************************************************/
    public static Contact_Language__c createContactLanguage(Id languageId, Id contactId, Boolean isPrimaryLanguage) {
        Contact_Language__c contactLanguageToInsert = 
            new Contact_Language__c(Language__c = languageId, Contact__c = contactId, Primary_Language__c = isPrimaryLanguage);
        insert contactLanguageToInsert;
        return contactLanguageToInsert;
    }

    /*********************************************************************************************************
    * @description Inserts a new Course Offering record for testing.
    * @param courseId The Course to which the Course Offering will be associated. If blank, a new Course record
    * will be inserted.
    * @param termId The Term to which the Course Offering will be associated. If blank, a new Term record will be
    * inserted.
    * @return The inserted Course Offering record.
    **********************************************************************************************************/
    public static Course_Offering__c createCourseOffering(Id courseId, Id termId) {
        Account acct;
        if (courseId == null || termId == null) {
            acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getAcademicAccRecTypeID())[0];
            insert acct;
        }
        
        if (courseId == null) {
            Course__c course = new Course__c(Name = 'ECON 101', Account__c = acct.Id);
            insert course;
            courseId = course.Id;
        }

        if (termId == null) {
            Term__c term = new Term__c(Name = '2019-2020 School Year', Account__c = acct.Id);
            insert term;
            termId = term.Id;
        }

        Course_Offering__c courseOffering = new Course_Offering__c(Name = 'ECON-101-19-01', Course__c = courseId, Term__c = termId);
        insert courseOffering;

        return courseOffering;
    }

    /*********************************************************************************************************
    * @description Inserts a new Time Block record for testing.
    * @param startTime The Start Time for the Time Block.
    * @param endTime The End Time for the Time Block.
    * @return The inserted Time Block record.
    **********************************************************************************************************/
    public static Time_Block__c createTimeBlock(Time startTime, Time endTime) {
        Time_Block__c timeBlock = new Time_Block__c(Start_Time__c = startTime, End_Time__c = endTime);
        insert timeBlock;

        return timeBlock;
    }
    
    /*********************************************************************************************************
    * @description Gets a Course Connection for testing.
    * @return The Course Connection record.
    **********************************************************************************************************/
    public static Course_Enrollment__c getCourseConnection() {
        Course_Enrollment__c courseConnection = new Course_Enrollment__c();
        return courseConnection;
    }

    /*********************************************************************************************************
    * @description Gets a Course Connection for testing.
    * @param contactId The Contact of the Course Connection.
    * @param courseOfferingId The Course Offering of the Course Connection.
    * @return The Course Connection record.
    **********************************************************************************************************/
    public static Course_Enrollment__c getCourseConnection(Id contactId, Id courseOfferingId) {
        Course_Enrollment__c courseConnection = new Course_Enrollment__c(
            Contact__c = contactId, 
            Course_Offering__c = courseOfferingId
        );
        return courseConnection;
    }
    
    /*********************************************************************************************************
    * @description Gets a Attendance Event for testing.
    * @return The Attendance Event record.
    **********************************************************************************************************/
    public static Attendance_Event__c getAttendanceEvent() {
        Attendance_Event__c attd = new Attendance_Event__c();
        return attd;
    }

    /*********************************************************************************************************
    * @description Gets a Facility for testing.
    * @return The Facility record.
    **********************************************************************************************************/
    public static Facility__c getFacility() {
        Facility__c facility = new Facility__c(Name = 'Test Facility ' + Datetime.now().getTime());
        return facility;
    }
}