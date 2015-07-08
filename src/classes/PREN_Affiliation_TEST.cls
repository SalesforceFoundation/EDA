/*
    Copyright (c) 2015, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
* @author Salesforce.com Foundation
* @date 2013
* @group Address Management
* @description Tests specific to Progran Enrollment. 
*/
@isTest
public with sharing class PREN_Affiliation_TEST {

	/*********************************************************************************************************
    * @description if you only want to run one test in this class, fill in its name here.
    * if you want to run all tests, then use '*'
    */
    private static string strTestOnly = '*';
    
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
    	Test.startTest();
    	Program_Enrollment__c enrollment = new Program_Enrollment__c(Student__c = contact.ID, Program__c = acc.ID);
    	Test.stopTest();
    	
    	List<Affiliation__c> affls = [select Contact__c, Account__c from Affiliation__c];
    	System.assertEquals(1, affls.size());
    	
    	enrollment = [select Affiliation__c from Program_Enrollment__c where ID = :enrollment.ID];
    	System.assertEquals(affls[0].ID, enrollment.Affiliation__r.ID);
    }
}