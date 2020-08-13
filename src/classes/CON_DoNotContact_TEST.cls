/*
    Copyright (c) 2014, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
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
* @date 2015
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Tests to validate the functionality of the CON_DoNotContact_TDTM class to
* synchronize Household naming exclusions and communication preferences with changes to the Deceased
* and Do Not Contact fields for the Contact object.
*/
@isTest
private class CON_DoNotContact_TEST {
    /**************************************************************************************************************************
    ****************************************************** FUNCTIONAL TESTS ***************************************************
    **************************************************************************************************************************/

    /**************************************************************************************************************************
    * @description Test method to verify that contacts inserted with "Deceased" = true are excluded from 
    * from Household naming functionality and have the following fields automatically marked as true: 
    * Do Not Contact, Email Opt Out, Do Not Call, Do Not Fax
    */
    @isTest 
    private static void insertContactDeceasedIsTrue(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Deceased__c = true;
        }

        Test.startTest();
        insert testContactsList;
        Test.stopTest();

        List<Contact> contactsAfterInsertList = [SELECT Do_Not_Contact__c, 
                                                        Exclude_from_Household_Name__c, 
                                                        Exclude_from_Household_Formal_Greeting__c,
                                                        Exclude_from_Household_Informal_Greeting__c, 
                                                        HasOptedOutOfEmail, 
                                                        DoNotCall, 
                                                        HasOptedOutOfFax
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];
        
        for (Contact con : contactsAfterInsertList){
            System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
            System.assertEquals(true, con.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that contacts inserted with "Deceased" = false are not excluded from 
    * from Household naming functionality and have the following fields automatically marked as false: 
    * Do Not Contact, Email Opt Out, Do Not Call, Do Not Fax
    */
    @isTest 
    private static void insertContactDeceasedIsFalse(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Deceased__c = false;
        }

        Test.startTest();
        insert testContactsList;
        Test.stopTest();

        List<Contact> contactsAfterInsertList = [SELECT Do_Not_Contact__c, 
                                                    Exclude_from_Household_Name__c, 
                                                    Exclude_from_Household_Formal_Greeting__c,
                                                    Exclude_from_Household_Informal_Greeting__c, 
                                                    HasOptedOutOfEmail, 
                                                    DoNotCall, 
                                                    HasOptedOutOfFax
                                             FROM CONTACT 
                                             WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterInsertList){
            System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
            System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that contacts updated from being deceased to not deceased are not excluded from 
    * from Household naming functionality and have the following fields automatically marked as false: 
    * Do Not Contact, Email Opt Out, Do Not Call, Do Not Fax
    */
    @isTest
    private static void updateContactDeceasedToFalse() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Deceased__c = true;
        }

        insert testContactsList;

        for (Contact con : testContactsList){
            con.Deceased__c = false; 
        }

        Test.startTest();
        update testContactsList;
        Test.stopTest();

        List<Contact> contactsAfterUpdateList = [SELECT Do_Not_Contact__c, 
                                                        Exclude_from_Household_Name__c, 
                                                        Exclude_from_Household_Formal_Greeting__c,
                                                        Exclude_from_Household_Informal_Greeting__c, 
                                                        HasOptedOutOfEmail, 
                                                        DoNotCall, 
                                                        HasOptedOutOfFax
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterUpdateList){
            System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
            System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
            System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
            System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of email.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of phone calls.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of fax.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that contacts updated as deceased are excluded from Household naming functionality
    * and have the following fields automatically marked as true: Do Not Contact, Email Opt Out, Do Not Call, Do Not Fax
    */
    @isTest
    private static void updateContactDeceasedToTrue() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Deceased__c = false;
        }

        insert testContactsList;

        for (Contact con : testContactsList){
            con.Deceased__c = true; 
        }

        Test.startTest();
        update testContactsList;
        Test.stopTest();

        List<Contact> contactsAfterUpdateList = [SELECT Do_Not_Contact__c, 
                                                        Exclude_from_Household_Name__c, 
                                                        Exclude_from_Household_Formal_Greeting__c,
                                                        Exclude_from_Household_Informal_Greeting__c, 
                                                        HasOptedOutOfEmail, 
                                                        DoNotCall, 
                                                        HasOptedOutOfFax
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterUpdateList){
            System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
            System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');    
            System.assertEquals(true, con.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of email.');
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of phone calls.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of fax.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that contacts inserted with "Do Not Contact" selected have the following communication
    * fields automatically updated to true: Email Opt Out, Do Not Call, Do Not Fax
    */
    @isTest
    private static void insertDoNotContactIsTrue() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Do_Not_Contact__c = true;
        }

        Test.startTest();
        insert testContactsList;
        Test.stopTest();

        List<Contact> contactsAfterInsertList = [SELECT DoNotCall, 
                                                        HasOptedOutOfEmail, 
                                                        HasOptedOutOfFax 
                                                FROM Contact 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterInsertList){
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of phone calls.');
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of email.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of fax.');    
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that contacts inserted with "Do Not Contact" selected have the following communication
    * fields automatically updated to true: Email Opt Out, Do Not Call, Do Not Fax
    */
    @isTest
    private static void insertDoNotContactIsFalse() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Do_Not_Contact__c = false;
        }

        Test.startTest();
        insert testContactsList;
        Test.stopTest();

        List<Contact> contactsAfterInsertList = [SELECT DoNotCall, 
                                                        HasOptedOutOfEmail, 
                                                        HasOptedOutOfFax 
                                                FROM Contact 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterInsertList){
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of phone calls.');
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of email.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of fax.');    
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that contacts updated with "Do Not Contact" = true have the following fields 
    * automatically marked as true: Do Not Contact, Email Opt Out, Do Not Call, Do Not Fax
    */   
    @isTest
    private static void updateDoNotContactTotrue() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Do_Not_Contact__c = false;
        }

        insert testContactsList;

        for (Contact con : testContactsList){
            con.Do_Not_Contact__c = true;
        }

        Test.startTest();
        update testContactsList;
        Test.stopTest();

        List<Contact> contactsAfterUpdateList = [SELECT DoNotCall, 
                                                        HasOptedOutOfEmail, 
                                                        HasOptedOutOfFax 
                                                FROM Contact 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterUpdateList){
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of phone calls.');
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should  be opted out of email.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of fax.');    
        }
    }

    /****************************************************************************************************************************
    * @description Test method to verify that contacts updated with "Do Not Contact" = False
    * have the following fields automatically marked as false: Do Not Contact, Email Opt Out, Do Not Call, Do Not Fax
    */  
    @isTest
    private static void updateDoNotContactToFalse() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Do_Not_Contact__c = true;
        }

        insert testContactsList;

        for (Contact con : testContactsList){
            con.Do_Not_Contact__c = false;
        }

        Test.startTest();
        update testContactsList;
        Test.stopTest();

        List<Contact> contactsAfterUpdateList = [SELECT DoNotCall, 
                                                        HasOptedOutOfEmail, 
                                                        HasOptedOutOfFax 
                                                FROM Contact 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterUpdateList){
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of phone calls.');
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not  be opted out of email.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of fax.');    
        }
    }

    /**************************************************************************************************************************************
    * @description Test method to verify that deceased contacts updated with "Do Not Contact" = false will remain excluded from household
    * naming functionality, but will have the following communication preferences automatically updated to false:
    * Email Opt Out, Do Not Call, Do Not Fax
    */  
    @isTest
    private static void updateDoNotContactToFalseOnADeceasedContact() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Deceased__c = true;
        }

        insert testContactsList;

        for (Contact con : testContactsList){
            con.Do_Not_Contact__c = false;
        }

        Test.startTest();
        update testContactsList;
        Test.stopTest();

        List<Contact> contactAfterUpdateList = [SELECT DoNotCall, 
                                                       HasOptedOutOfEmail, 
                                                       HasOptedOutOfFax,
                                                       Do_Not_Contact__c, 
                                                       Exclude_from_Household_Name__c,
                                                       Exclude_from_Household_Formal_Greeting__c, 
                                                       Exclude_from_Household_Informal_Greeting__c
                                               FROM Contact 
                                               WHERE Id IN :testContactsList];

        for (Contact con : contactAfterUpdateList){
            System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of phone calls.');
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of Email.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of Fax.');
            System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        }
    }

    /**************************************************************************************************************************
    ****************************************************** UNIT TESTS *********************************************************
    **************************************************************************************************************************/

    /**************************************************************************************************************************
    * @description Test method to verify that syncDoNotContactFieldsOnContact synchronizes the following fields to true when 
    * "Do Not Contact" is selected: Email Opt Out, Do Not Call, Do Not Fax
    */
    @isTest
    private static void syncDoNotContactFieldsToPositive(){
        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);

        for (Contact con : testContactList){
            con.Do_Not_Contact__c = true;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.syncDoNotContactFieldsOnContacts(testContactList);
        Test.stopTest();

        for (Contact con : testContactList){
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of emails.');
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of phone calls.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that syncDoNotContactFieldsOnContact synchronizes the following fields to false when 
    * "Do Not Contact" is not selected: Email Opt Out, Do Not Call, Do Not Fax
    */
    @isTest
    private static void syncDoNotContactFieldsToNegative(){
        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);

        for (Contact con : testContactList){
            con.Do_Not_Contact__c = false;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.syncDoNotContactFieldsOnContacts(testContactList);
        Test.stopTest();

        for (Contact con : testContactList){
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of emails.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of phone calls.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that syncDoNotContactFieldsOnContact synchronizes the following fields to false when 
    * a null value is set for "Do Not Contact": Email Opt Out, Do Not Call, Do Not Fax
    */
    @isTest
    private static void syncDoNotContactFieldsNull(){
        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);

        for (Contact con : testContactList){
            con.Do_Not_Contact__c = null;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.syncDoNotContactFieldsOnContacts(testContactList);
        Test.stopTest();

        for (Contact con : testContactList){
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of emails.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of phone calls.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that syncNamingExclusionsOnContact excludes the following naming conventions  
    * when a contact has been marked as deceased: Household Name, Household Formal Greeting, Household Informal Greeting
    */
    @isTest 
    private static void syncNamingExclusionsPositive(){
        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);

        for (Contact con : testContactList){
            con.Deceased__c = true;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.syncNamingExclusionsOnContacts(testContactList);
        Test.stopTest();

        for (Contact con : testContactList){
            System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that syncNamingExclusionsOnContact removes all household naming exclusions   
    * when a contact is marked as being not deceased.
    */
    @isTest 
    private static void syncNamingExclusionsNegative(){
        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);

        for (Contact con : testContactList){
            con.Deceased__c = false;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.syncNamingExclusionsOnContacts(testContactList);
        Test.stopTest();

        for (Contact con : testContactList){
            System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
            System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
            System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that syncNamingExclusionsOnContact removes all household naming exclusions   
    * when a null value is passed for Deceased.
    */
    @isTest 
    private static void syncNamingExclusionsNull(){
        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);

        for (Contact con : testContactList){
            con.Deceased__c = null;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.syncNamingExclusionsOnContacts(testContactList);
        Test.stopTest();

        for (Contact con : testContactList){
            System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
            System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
            System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that processBeforeInsert excludes a deceased contact from all household naming
    * functionality and the following fields are set to true: Do Not Contact, Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void processBeforeInsertDeceasedPositive(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Deceased__c = true;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.processBeforeInsert(testContactsList);
        Test.stopTest();

        List<Contact> contactsAfterInsertList = [SELECT Do_Not_Contact__c, 
                                                        Exclude_from_Household_Name__c, 
                                                        Exclude_from_Household_Formal_Greeting__c,
                                                        Exclude_from_Household_Informal_Greeting__c, 
                                                        HasOptedOutOfEmail, 
                                                        DoNotCall, 
                                                        HasOptedOutOfFax
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterInsertList){
            System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
            System.assertEquals(true, con.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that processBeforeInsert does not exclude a living contact from any household naming
    * functionality and the following fields are set to false: Do Not Contact, Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void processBeforeInsertDeceasedNegative(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Deceased__c = false;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.processBeforeInsert(testContactsList);
        Test.stopTest();

        List<Contact> contactsAfterInsertList = [SELECT Do_Not_Contact__c, 
                                                        Exclude_from_Household_Name__c, 
                                                        Exclude_from_Household_Formal_Greeting__c,
                                                        Exclude_from_Household_Informal_Greeting__c, 
                                                        HasOptedOutOfEmail, 
                                                        DoNotCall, 
                                                        HasOptedOutOfFax
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterInsertList){
            System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
            System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
            System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should note be excluded from Household Informal Greeting.');
            System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should note be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that when Deceased is null, processBeforeInsert does not exclude a contact from any 
    * household naming functionality and the following fields are set to false: 
    * Do Not Contact, Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void processBeforeInsertDeceasedNull(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Deceased__c = null;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.processBeforeInsert(testContactsList);
        Test.stopTest();

        List<Contact> contactsAfterInsertList = [SELECT Do_Not_Contact__c, 
                                                        Exclude_from_Household_Name__c, 
                                                        Exclude_from_Household_Formal_Greeting__c,
                                                        Exclude_from_Household_Informal_Greeting__c, 
                                                        HasOptedOutOfEmail, 
                                                        DoNotCall, 
                                                        HasOptedOutOfFax,
                                                        Account.Name 
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterInsertList){
            System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
            System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
            System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should note be excluded from Household Informal Greeting.');
            System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that processBeforeInsert synchronizes the following fields to true when 
    * "Do Not Contact" is selected: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void processBeforeInsertDoNotContactPositive(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Do_Not_Contact__c = true;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.processBeforeInsert(testContactsList);
        Test.stopTest();

        List<Contact> contactsAfterInsertList = [SELECT Do_Not_Contact__c, 
                                                        HasOptedOutOfEmail, 
                                                        DoNotCall, 
                                                        HasOptedOutOfFax
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterInsertList){
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that processBeforeInsert synchronizes the following fields to false when 
    * "Do Not Contact" is not selected: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void processBeforeInsertDoNotContactNegative(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Do_Not_Contact__c = false;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.processBeforeInsert(testContactsList);
        Test.stopTest();

        List<Contact> contactsAfterInsertList = [SELECT Do_Not_Contact__c, 
                                                        HasOptedOutOfEmail, 
                                                        DoNotCall, 
                                                        HasOptedOutOfFax
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterInsertList){
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that processBeforeInsert synchronizes the following fields to false when 
    * "Do Not Contact" is null: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void processBeforeInsertDoNotContactNull(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Do_Not_Contact__c = null;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.processBeforeInsert(testContactsList);
        Test.stopTest();

        List<Contact> contactsAfterInsertList = [SELECT Do_Not_Contact__c, 
                                                        HasOptedOutOfEmail, 
                                                        DoNotCall, 
                                                        HasOptedOutOfFax
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterInsertList){
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that processBeforeUpdate excludes a deceased contact from household naming 
    * functionality and synchronizes the following fields to true: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void processBeforeUpdateDeceasedPositive(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        Map<Id, Contact> testContactsById = new Map<Id, Contact>();
        
        for (Contact con : testContactsList){
            String testId = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

            Contact oldCon = con.clone(false);
            oldCon.Id = testId;
            oldCon.Deceased__c = false;
            testContactsById.put(testId, oldCon);

            con.Id = testId;
            con.Deceased__c = true;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.processBeforeUpdate(testContactsList, testContactsById);
        Test.stopTest();

        for (Contact con : testContactsList){
            System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
            System.assertEquals(true, con.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that processBeforeUpdate does not exclude a living contact from household naming 
    * functionality and synchronizes the following fields to false: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void processBeforeInsertUpdateDeceasedNegative(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        Map<Id, Contact> testContactsById = new Map<Id, Contact>();
        
        for (Contact con : testContactsList){
            String testId = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

            Contact oldCon = con.clone(false);
            oldCon.Id = testId;
            oldCon.Deceased__c = true;
            testContactsById.put(testId, oldCon);

            con.Id = testId;
            con.Deceased__c = false;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.processBeforeUpdate(testContactsList, testContactsById);
        Test.stopTest();

        for (Contact con : testContactsList){
            System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
            System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
            System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
            System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that when Deceased is null, processBeforeUpdate does not exclude a contact from 
    * household naming functionality and synchronizes the following fields to false: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void processBeforeUpdateDeceasedNull(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        Map<Id, Contact> testContactsById = new Map<Id, Contact>();
        
        for (Contact con : testContactsList){
            String testId = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

            Contact oldCon = con.clone(false);
            oldCon.Id = testId;
            oldCon.Deceased__c = true;
            testContactsById.put(testId, oldCon);

            con.Id = testId;
            con.Deceased__c = null;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.processBeforeUpdate(testContactsList, testContactsById);
        Test.stopTest();

        for (Contact con : testContactsList){
            System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
            System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
            System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
            System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that when "Do Not Contact" is updated to checked, processBeforeUpdate synchronizes 
    * the following communication preference fields to true: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void processBeforeUpdateDoNotContactPositive(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        Map<Id, Contact> testContactsById = new Map<Id, Contact>();
        
        for (Contact con : testContactsList){
            String testId = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

            Contact oldCon = con.clone(false);
            oldCon.Id = testId;
            oldCon.Do_Not_Contact__c = false;
            testContactsById.put(testId, oldCon);

            con.Id = testId;
            con.Do_Not_Contact__c = true;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.processBeforeUpdate(testContactsList, testContactsById);
        Test.stopTest();

        for (Contact con : testContactsList){
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that when "Do Not Contact" is updated to unchecked, processBeforeUpdate synchronizes 
    * the following communication preference fields to false: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void processBeforeUpdateDoNotContactNegative(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        Map<Id, Contact> testContactsById = new Map<Id, Contact>();
        
        for (Contact con : testContactsList){
            String testId = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

            Contact oldCon = con.clone(false);
            oldCon.Id = testId;
            oldCon.Do_Not_Contact__c = true;
            testContactsById.put(testId, oldCon);

            con.Id = testId;
            con.Do_Not_Contact__c = false;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.processBeforeUpdate(testContactsList, testContactsById);
        Test.stopTest();

        for (Contact con : testContactsList){
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that when "Do Not Contact" is updated to null, processBeforeUpdate synchronizes 
    * the following communication preference fields to false: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void processBeforeUpdateDoNotContactNull(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        Map<Id, Contact> testContactsById = new Map<Id, Contact>();
        
        for (Contact con : testContactsList){
            String testId = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

            Contact oldCon = con.clone(false);
            oldCon.Id = testId;
            oldCon.Do_Not_Contact__c = true;
            testContactsById.put(testId, oldCon);

            con.Id = testId;
            con.Do_Not_Contact__c = null;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.processBeforeUpdate(testContactsList, testContactsById);
        Test.stopTest();

        for (Contact con : testContactsList){
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that isBeforeInsert returns true for a BeforeInsert trigger action.
    */
    @isTest 
    private static void checkIsBeforeInsertPositive(){
        TDTM_Runnable.Action testAction = TDTM_Runnable.Action.BeforeInsert;

        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        System.assertEquals(true, conDoNotContactTDTM.isBeforeInsert(testAction), 'Trigger Action is BeforeInsert');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that isBeforeInsert returns false when the trigger action is not BeforeInsert.
    */
    @isTest 
    private static void checkIsBeforeInsertNegative(){
        TDTM_Runnable.Action testAction = TDTM_Runnable.Action.AfterInsert;

        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        System.assertEquals(false, conDoNotContactTDTM.isBeforeInsert(testAction), 'Trigger Action is not BeforeInsert');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that isBeforeUpdate returns true for a BeforeUpdate trigger action.
    */
    @isTest 
    private static void checkIsBeforeUpdatePositive(){
        TDTM_Runnable.Action testAction = TDTM_Runnable.Action.BeforeUpdate;

        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        System.assertEquals(true, conDoNotContactTDTM.isBeforeUpdate(testAction), 'Trigger Action is BeforeUpdate');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that isBeforeUpdate returns false when the trigger action is not BeforeUpdate.
    */
    @isTest 
    private static void checkIsBeforeUpdateNegative(){
        TDTM_Runnable.Action testAction = TDTM_Runnable.Action.AfterUpdate;

        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        System.assertEquals(false, conDoNotContactTDTM.isBeforeUpdate(testAction), 'Trigger Action is not BeforeUpdate');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the run method excludes contact updated to deceased from household naming 
    * functionality and sets the following fields to true: Do Not Contact, Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void fireBeforeUpdateDeceasedPositive(){
        List<SObject> newList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        List<SObject> oldList = new List<SObject>();

        TDTM_Runnable.Action triggerAction = TDTM_Runnable.Action.BeforeInsert;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;
        
        for (SObject so : newList){
            SObject oldObj = so.clone(false);
            oldObj.put('Deceased__c', false);
            oldList.add(oldObj);

            so.put('Deceased__c', true);
        }

        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.run(newList, oldList, triggerAction, objResult);

        for (Contact con : (List<Contact>)newList){
            System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
            System.assertEquals(true, con.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the run method clears household naming exclusions for contacts updated from 
    * being deceased and sets the following fields to false: Do Not Contact, Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void fireBeforeUpdateDeceasedNegative(){
        List<SObject> newList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        List<SObject> oldList = new List<SObject>();

        TDTM_Runnable.Action triggerAction = TDTM_Runnable.Action.BeforeInsert;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;
        
        for (SObject so : newList){
            SObject oldObj = so.clone(false);
            oldObj.put('Deceased__c', true);
            oldList.add(oldObj);
            
            so.put('Deceased__c', false);
        }

        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.run(newList, oldList, triggerAction, objResult);

        for (Contact con : (List<Contact>)newList){
            System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
            System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
            System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
            System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the run method sets the following fields to true for contacts when the  
    * "Do Not Contact" field is updated to checked: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void fireBeforeUpdateDoNotContactPositive(){
        List<SObject> newList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        List<SObject> oldList = new List<SObject>();

        TDTM_Runnable.Action triggerAction = TDTM_Runnable.Action.BeforeInsert;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;
        
        for (SObject so : newList){
            SObject oldObj = so.clone(false);
            oldObj.put('Do_Not_Contact__c', false);
            oldList.add(oldObj);

            so.put('Do_Not_Contact__c', true);
        }

        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.run(newList, oldList, triggerAction, objResult);

        for (Contact con : (List<Contact>)newList){
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the run method sets the following fields to false for contacts when the  
    * "Do Not Contact" field is updated to unchecked: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void fireBeforeUpdateDoNotContactNegative(){
        List<SObject> newList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        List<SObject> oldList = new List<SObject>();

        TDTM_Runnable.Action triggerAction = TDTM_Runnable.Action.BeforeInsert;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;
        
        for (SObject so : newList){
            SObject oldObj = so.clone(false);
            oldObj.put('Do_Not_Contact__c', true);
            oldList.add(oldObj);
            
            so.put('Do_Not_Contact__c', false);
        }

        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.run(newList, oldList, triggerAction, objResult);

        for (Contact con : (List<Contact>)newList){
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the run method excludes inserted deceased contacts from household naming 
    * functionality and sets the following fields to true: Do Not Contact, Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void fireBeforeInsertDeceasedPositive(){
        List<SObject> newList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        List<SObject> oldList = null;

        TDTM_Runnable.Action triggerAction = TDTM_Runnable.Action.BeforeInsert;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;
        
        for (SObject so : newList){
            so.put('Deceased__c', true);
        }

        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.run(newList, oldList, triggerAction, objResult);

        for (Contact con : (List<Contact>)newList){
            System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
            System.assertEquals(true, con.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the run method does not exclude inserted living contacts from household naming 
    * functionality and sets the following fields to false: Do Not Contact, Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void fireBeforeInsertDeceasedNegative(){
        List<SObject> newList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        List<SObject> oldList = null;

        TDTM_Runnable.Action triggerAction = TDTM_Runnable.Action.BeforeInsert;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;
        
        for (SObject so : newList){
            so.put('Deceased__c', false);
        }

        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.run(newList, oldList, triggerAction, objResult);

        for (Contact con : (List<Contact>)newList){
            System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
            System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
            System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
            System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the run method synchronizes the following to fields to true when contacts are
    * inserted with "Do Not Contact" selected: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void fireBeforeInsertDoNotContactPositive(){
        List<SObject> newList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        List<SObject> oldList = null;

        TDTM_Runnable.Action triggerAction = TDTM_Runnable.Action.BeforeInsert;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;
        
        for (SObject so : newList){
            so.put('Do_Not_Contact__c', true);
        }

        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.run(newList, oldList, triggerAction, objResult);

        for (Contact con : (List<Contact>)newList){
            System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
            System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
            System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the run method synchronizes the following to fields to false when contacts are
    * inserted with "Do Not Contact" unchecked: Email Opt Out, Fax Opt Out, Do Not Call
    */
    @isTest 
    private static void fireBeforeInsertDoNotContactNegative(){
        List<SObject> newList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        List<SObject> oldList = null;

        TDTM_Runnable.Action triggerAction = TDTM_Runnable.Action.BeforeInsert;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;
        
        for (SObject so : newList){
            so.put('Do_Not_Contact__c', false);
        }

        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.run(newList, oldList, triggerAction, objResult);

        for (Contact con : (List<Contact>)newList){
            System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }
}