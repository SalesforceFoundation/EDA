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
* synchronize changes to the communication preference and naming exclusion fields for a 
* deceased contact record.
*/
@isTest
private class CON_DoNotContact_TEST {

    public static String adminAccountRecordTypeId = UTIL_Describe_API.getAdminAccRecTypeID(); 
    public static String hhAccountRecordTypeId = UTIL_Describe_API.getHhAccRecTypeID(); 

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
    * @description Test method to verify that syncNamingExclusionsOnContact excludes the following naming conventions  
    * when a contact has been marked as deceased: Household Name, Household Formal Greeting, Household Informal Greeting
    */
    @isTest 
    private static void syncNamingExclusionsToPositive(){
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
            System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
            System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
            System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.');
        }
    }


    /**************************************************************************************************************************
    * @description Test method to verify that syncNamingExclusionsOnContact removes all household naming exclusions   
    * when a contact has been updated from previously being deceased.
    */
    @isTest 
    private static void syncNamingExclusionsToNegative(){
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
            System.assertEquals(true, String.isBlank(con.Naming_Exclusions__c), 'Naming Exclusions field should be blank.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that syncHHNamingExclusionsPicklistFromCheckboxes correctly generates a semi-colon 
    * delimited string listing all household naming exclusions when the corresponding household exclusion checkboxes are 
    * selected on the Contact.
    */
    @isTest 
    private static void syncHHNamingExclusionsFromCheckboxesAllPositive(){
        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);

        for (Contact con : testContactList){
            con.Exclude_from_Household_Name__c = true;
            con.Exclude_from_Household_Formal_Greeting__c = true;
            con.Exclude_from_Household_Informal_Greeting__c = true;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.syncHHNamingExclusionsPicklistFromCheckboxes(testContactList);
        Test.stopTest();

        for (Contact con : testContactList){
            System.assertEquals('Household__c.Name;Household__c.Formal_Greeting__c;Household__c.Informal_Greeting__c', 
                                 con.Naming_Exclusions__c,
                                'Naming exclusion string should include all household naming conventions');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that syncHHNamingExclusionsPicklistFromCheckboxes correctly generates a semi-colon 
    * delimited string listing only the household naming exclusions matching the household exclusion checkbox selections 
    * on the Contact.
    */
    @isTest 
    private static void syncHHNamingExclusionsFromCheckboxesPartialPositive(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);

        for (Contact con : testContactsList){
            con.Exclude_from_Household_Name__c = true;
            con.Exclude_from_Household_Formal_Greeting__c = false;
            con.Exclude_from_Household_Informal_Greeting__c = true;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.syncHHNamingExclusionsPicklistFromCheckboxes(testContactsList);
        Test.stopTest();

        for (Contact con : testContactsList){
            System.assertEquals('Household__c.Name;Household__c.Informal_Greeting__c', 
                                 con.Naming_Exclusions__c,
                                'Naming exclusion string should include household name and informal greeting');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that syncHHNamingExclusionsPicklistFromCheckboxes does not generate a string when none 
    * of the household exclusion checkboxes are selected on the Contact record.
    */
    @isTest 
    private static void syncHHNamingExclusionsFromCheckboxesNoneNegative(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);

        for (Contact con : testContactsList){
            con.Exclude_from_Household_Name__c = false;
            con.Exclude_from_Household_Formal_Greeting__c = false;
            con.Exclude_from_Household_Informal_Greeting__c = false;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.syncHHNamingExclusionsPicklistFromCheckboxes(testContactsList);
        Test.stopTest();

        for (Contact con : testContactsList){
            System.assertEquals(true, String.isBlank(con.Naming_Exclusions__c), 'Naming exclusion string should be blank');
        }
    }

    @isTest 
    private static void syncHHNamingExclusionsFromCheckboxesNull(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);

        for (Contact con : testContactsList){
            con.Exclude_from_Household_Name__c = null;
            con.Exclude_from_Household_Formal_Greeting__c = null;
            con.Exclude_from_Household_Informal_Greeting__c = null;
        }

        Test.startTest();
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.syncHHNamingExclusionsPicklistFromCheckboxes(testContactsList);
        Test.stopTest();

        for (Contact con : testContactsList){
            System.assertEquals(true, String.isBlank(con.Naming_Exclusions__c), 'Naming exclusion string should be blank');
        }
    }

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
                                                        HasOptedOutOfFax, 
                                                        Naming_Exclusions__c,
                                                        Account.Name 
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];

        for (Integer i = 0; i < contactsAfterInsertList.size(); i++){
            System.assertEquals(i + 'Contact_forTests' + i + ' Administrative Account', contactsAfterInsertList[i].Account.Name, 'Account name should match contact\'s last name.');
            System.assertEquals(true, contactsAfterInsertList[i].Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
            System.assertEquals(true, contactsAfterInsertList[i].Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(true, contactsAfterInsertList[i].Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(true, contactsAfterInsertList[i].Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
            System.assertEquals(true, contactsAfterInsertList[i].HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
            System.assertEquals(true, contactsAfterInsertList[i].HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
            System.assertEquals(true, contactsAfterInsertList[i].DoNotCall, 'Contact should be opted out of receiving phone calls.');
            System.assertEquals(true, contactsAfterInsertList[i].Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
            System.assertEquals(true, contactsAfterInsertList[i].Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
            System.assertEquals(true, contactsAfterInsertList[i].Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.');
        }
    }

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
                                                        HasOptedOutOfFax, 
                                                        Naming_Exclusions__c,
                                                        Account.Name 
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];

        for (Integer i = 0; i < contactsAfterInsertList.size(); i++){
            System.assertEquals(i + 'Contact_forTests' + i + ' Administrative Account', contactsAfterInsertList[i].Account.Name, 'Account name should match contact\'s last name.');
            System.assertEquals(false, contactsAfterInsertList[i].Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
            System.assertEquals(false, contactsAfterInsertList[i].Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
            System.assertEquals(false, contactsAfterInsertList[i].Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
            System.assertEquals(false, contactsAfterInsertList[i].Exclude_from_Household_Informal_Greeting__c, 'Contact should note be excluded from Household Informal Greeting.');
            System.assertEquals(false, contactsAfterInsertList[i].HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, contactsAfterInsertList[i].HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, contactsAfterInsertList[i].DoNotCall, 'Contact should note be opted out of receiving phone calls.');
            System.assertEquals(true, String.isBlank(contactsAfterInsertList[i].Naming_Exclusions__c), 'Naming Exclusions field should be blank.');
        }
    }

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
                                                        Naming_Exclusions__c,
                                                        Account.Name 
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];

        for (Integer i = 0; i < contactsAfterInsertList.size(); i++){
            System.assertEquals(i + 'Contact_forTests' + i + ' Administrative Account', contactsAfterInsertList[i].Account.Name, 'Account name should match contact\'s last name.');
            System.assertEquals(false, contactsAfterInsertList[i].Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
            System.assertEquals(false, contactsAfterInsertList[i].Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
            System.assertEquals(false, contactsAfterInsertList[i].Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
            System.assertEquals(false, contactsAfterInsertList[i].Exclude_from_Household_Informal_Greeting__c, 'Contact should note be excluded from Household Informal Greeting.');
            System.assertEquals(false, contactsAfterInsertList[i].HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, contactsAfterInsertList[i].HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, contactsAfterInsertList[i].DoNotCall, 'Contact should note be opted out of receiving phone calls.');
            System.assertEquals(true, String.isBlank(contactsAfterInsertList[i].Naming_Exclusions__c), 'Naming Exclusions field should be blank.');
        }
    }

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

        for (Integer i = 0; i < contactsAfterInsertList.size(); i++){
            System.assertEquals(true, contactsAfterInsertList[i].HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
            System.assertEquals(true, contactsAfterInsertList[i].HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
            System.assertEquals(true, contactsAfterInsertList[i].DoNotCall, 'Contact should be opted out of receiving phone calls.');
        }
    }

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

        for (Integer i = 0; i < contactsAfterInsertList.size(); i++){
            System.assertEquals(false, contactsAfterInsertList[i].HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, contactsAfterInsertList[i].HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, contactsAfterInsertList[i].DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }

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

        for (Integer i = 0; i < contactsAfterInsertList.size(); i++){
            System.assertEquals(false, contactsAfterInsertList[i].HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
            System.assertEquals(false, contactsAfterInsertList[i].HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
            System.assertEquals(false, contactsAfterInsertList[i].DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        }
    }

/*********************************** */
@isTest 
private static void processBeforeUpdatePositive(){
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
        System.assertEquals(true, con.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
        System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
        System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
        System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
        System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
        System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
        System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
        System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.');
    }
}

@isTest 
private static void processBeforeInsertUpdateNegative(){
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
        System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
        System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
        System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
        System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
        System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
        System.assertEquals(false, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        System.assertEquals(false, con.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
        System.assertEquals(false, con.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
        System.assertEquals(false, con.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.');
    }
}

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
        System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
        System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
        System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
        System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
        System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
        System.assertEquals(false, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        System.assertEquals(false, con.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
        System.assertEquals(false, con.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
        System.assertEquals(false, con.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.');
    }
}

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
        System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
        System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
        System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
        System.assertEquals(true, String.isBlank(con.Naming_Exclusions__c), 'Naming Exclusions field should be blank.');
    }
}

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
        System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
        System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
        System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
        System.assertEquals(true, String.isBlank(con.Naming_Exclusions__c), 'Naming Exclusions field should be blank.');
    }
}

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
        System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
        System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
        System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
        System.assertEquals(true, String.isBlank(con.Naming_Exclusions__c), 'Naming Exclusions field should be blank.');
    }
}

@isTest 
private static void checkIsBeforeInsertPositive(){
    TDTM_Runnable.Action testAction = TDTM_Runnable.Action.BeforeInsert;

    CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
    System.assertEquals(true, conDoNotContactTDTM.isBeforeInsert(testAction));
}

@isTest 
private static void checkIsBeforeInsertNegative(){
    TDTM_Runnable.Action testAction = TDTM_Runnable.Action.AfterInsert;

    CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
    System.assertEquals(false, conDoNotContactTDTM.isBeforeInsert(testAction));
}

@isTest 
private static void checkIsBeforeUpdatePositive(){
    TDTM_Runnable.Action testAction = TDTM_Runnable.Action.BeforeUpdate;

    CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
    System.assertEquals(true, conDoNotContactTDTM.isBeforeUpdate(testAction));
}

@isTest 
private static void checkIsBeforeUpdateNegative(){
    TDTM_Runnable.Action testAction = TDTM_Runnable.Action.AfterUpdate;

    CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
    System.assertEquals(false, conDoNotContactTDTM.isBeforeUpdate(testAction));
}

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
        System.assertEquals(true, con.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
        System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
        System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
        System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
        System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
        System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
        System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
        System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.');
    }

}

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
        System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
        System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
        System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
        System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
        System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
        System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
        System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        System.assertEquals(true, String.isBlank(con.Naming_Exclusions__c), 'Naming Exclusions field should be blank.');
    }

}

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
        System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
        System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
        System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
        System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
        System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        System.assertEquals(true, String.isBlank(con.Naming_Exclusions__c), 'Naming Exclusions field should be blank.');
    }

}

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
        System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
        System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
        System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
        System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
        System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
        System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        System.assertEquals(true, String.isBlank(con.Naming_Exclusions__c), 'Naming Exclusions field should be blank.');
    }
}

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
        System.assertEquals(true, con.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
        System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
        System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
        System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
        System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
        System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
        System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
        System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.');
    }

}

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
        System.assertEquals(false, con.Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
        System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
        System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
        System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
        System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
        System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
        System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        System.assertEquals(true, String.isBlank(con.Naming_Exclusions__c), 'Naming Exclusions field should be blank.');
    }

}

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
        System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
        System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
        System.assertEquals(true, con.HasOptedOutOfEmail, 'Contact should be opted out of receiving emails.');
        System.assertEquals(true, con.HasOptedOutOfFax, 'Contact should be opted out of receiving faxes.');
        System.assertEquals(true, con.DoNotCall, 'Contact should be opted out of receiving phone calls.');
        System.assertEquals(true, String.isBlank(con.Naming_Exclusions__c), 'Naming Exclusions field should be blank.');
    }

}

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
        System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
        System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
        System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
        System.assertEquals(false, con.HasOptedOutOfEmail, 'Contact should not be opted out of receiving emails.');
        System.assertEquals(false, con.HasOptedOutOfFax, 'Contact should not be opted out of receiving faxes.');
        System.assertEquals(false, con.DoNotCall, 'Contact should not be opted out of receiving phone calls.');
        System.assertEquals(true, String.isBlank(con.Naming_Exclusions__c), 'Naming Exclusions field should be blank.');
    }
}



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
                                                        HasOptedOutOfFax, 
                                                        Naming_Exclusions__c
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];
        
        for (Contact con : contactsAfterInsertList){
            System.assertEquals(true, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(true, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(true, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
            System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
            System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
            System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.'); 
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
                                                    HasOptedOutOfFax, 
                                                    Naming_Exclusions__c
                                             FROM CONTACT 
                                             WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterInsertList){
            System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
            System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
            System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
            System.assertEquals(null, con.Naming_Exclusions__c, 'Naming Exclusions field should be cleared.');
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
                                                        HasOptedOutOfFax, 
                                                        Naming_Exclusions__c
                                                FROM CONTACT 
                                                WHERE Id IN :testContactsList];

        for (Contact con : contactsAfterUpdateList){
            System.assertEquals(false, con.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
            System.assertEquals(false, con.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
            System.assertEquals(false, con.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
            System.assertEquals(null, con.Naming_Exclusions__c, 'Naming Exclusion field should be cleared.');    
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
                                                        HasOptedOutOfFax, 
                                                        Naming_Exclusions__c
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
                                                       Exclude_from_Household_Informal_Greeting__c,
                                                       Naming_Exclusions__c 
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
            System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
            System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
            System.assertEquals(true, con.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Contact should be excluded from Household Informal Greeting.');
        }
    }
}