/*
    Copyright (c) 2015, Salesforce.org
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
* @group Program Enrollment
* @group-content ../../ApexDocContent/ProgramEnrollments.htm
* @description Tests specific to Progran Enrollment. 
*/
@isTest
public with sharing class PREN_Affiliation_TEST {

    /*********************************************************************************************************
    * @description Verifies that an Affiliation is automatically created when a Program Enrollment record is 
    * manually created from a Contact.
    */
    @isTest
    public static void createAfflFromProgramEnrollment() {
    	
    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
    	
    	ID orgRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
    	
    	//Craete account of Business Organization record type
    	Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
    	insert acc;
    	
    	//Create Program Enrollment
    	Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID);
    	Test.startTest();
    	insert enrollment;
    	Test.stopTest();
    	
    	//An Affiliation should have been automatically created fron the Program Enrollment
    	List<Affiliation__c> affls = [select Contact__c, Account__c from Affiliation__c where Account__r.ID = :acc.ID];
    	System.assertEquals(1, affls.size());
    	
    	//The Program Enrollment record should be related to the Affiliation just created
    	enrollment = [select Affiliation__r.ID from Program_Enrollment__c where ID = :enrollment.ID];
    	System.assertEquals(affls[0].ID, enrollment.Affiliation__r.ID);
    }
    
    /*********************************************************************************************************
    * @description Deleting a Program Enrollment deletes the related Affiliation when Affl_ProgEnroll_Del__c setting
    * is set to true.
    */
    @isTest
    public static void deletePEnrollDelAfflYes() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Del__c = true));
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        ID orgRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
        
        //Craete account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID);
        insert enrollment;
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [select Contact__c, Account__c from Affiliation__c where Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        
        //The Program Enrollment record should be related to the Affiliation just created
        enrollment = [select Affiliation__r.ID from Program_Enrollment__c where ID = :enrollment.ID];
        System.assertEquals(affls[0].ID, enrollment.Affiliation__r.ID);
        ID enrollmentAfflID = enrollment.Affiliation__r.ID; //Storing it to use it in next query
        
        //Delete Program Enrollment
        Test.startTest();
        delete enrollment;
        Test.stopTest();
        
        //Related Affiliation should have been automatically deleted
        affls = [select ID from Affiliation__c where ID = :enrollmentAfflID];
        System.assertEquals(0, affls.size());
    }
    
    /*********************************************************************************************************
    * @description Deleting a Program Enrollment doesn't delet the related Affiliation when Affl_ProgEnroll_Del__c setting
    * is set to false. It just changes the status to what is defined in Affl_ProgEnroll_Del_Status__c.
    */
    @isTest
    public static void deletePEnrollDelAfflNo() {
        String afflStatus = 'Former';
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Del__c = false, 
        Affl_ProgEnroll_Del_Status__c = afflStatus));
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        ID orgRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
        
        //Craete account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID);
        insert enrollment;
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [select Contact__c, Account__c from Affiliation__c where Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        
        //The Program Enrollment record should be related to the Affiliation just created
        enrollment = [select Affiliation__r.ID from Program_Enrollment__c where ID = :enrollment.ID];
        System.assertEquals(affls[0].ID, enrollment.Affiliation__r.ID);
        
        ID enrollmentAfflID = enrollment.Affiliation__r.ID; //Storing it to use it in next query
        
        //Delete Program Enrollment
        Test.startTest();
        delete enrollment;
        Test.stopTest();
        
        //Related Affiliation status should have been automatically updated
        affls = [select Status__c from Affiliation__c where ID = :enrollmentAfflID];
        System.assertEquals(1, affls.size());
        System.assertEquals(afflStatus, affls[0].Status__c);
    }
}