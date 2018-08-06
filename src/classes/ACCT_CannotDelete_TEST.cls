/*
    Copyright (c) 2016, Salesforce.org
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
* @date 2016
* @group Accounts
* @group-content ../../ApexDocContent/Accounts.htm
* @description Tests for ACCT_CannotDelete_TDTM.
*/
@isTest
public with sharing class ACCT_CannotDelete_TEST {

    @isTest
    public static void cannotDelete() {
        STG_InstallScript.insertMappings();

        Contact c = UTIL_UnitTestData_TEST.getContact();
        insert c;

        Account[] accs = UTIL_UnitTestData_TEST.getMultipleTestAccounts(5, UTIL_Describe_API.getBizAccRecTypeID());
        insert accs;

        Affiliation__c affl = new Affiliation__c(Contact__c = c.ID, Account__c = accs[0].ID);
        Program_Enrollment__c programEnroll = new Program_Enrollment__c(Contact__c = c.ID, Account__c = accs[1].ID);
        Course_Enrollment__c courseEnroll = new Course_Enrollment__c(Contact__c = c.ID, Account__c = accs[2].ID);
        Program_Plan__c programPlan = NEW Program_Plan__c(Account__c = accs[4].Id);
        insert new SObject[] {affl, programEnroll, courseEnroll, programPlan};
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(accs, false);
        Test.stopTest();
        
        UTIL_Debug.debug('****Delete results: ' + JSON.serializePretty(results));
        
        //Verify only acc4 was successfully deleted
        accs = [select ID from Account where ID in :accs];
        System.assertEquals(4, accs.size());
        
        System.assertEquals(false, results[0].success);
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
        System.assertEquals(false, results[1].success);
        System.assertEquals(Label.CannotDelete, results[1].errors[0].message);
        System.assertEquals(false, results[2].success);
        System.assertEquals(Label.CannotDelete, results[2].errors[0].message);
        System.assertEquals(true, results[3].success);
        System.assertEquals(false, results[4].success);
        System.assertEquals(Label.CannotDelete, results[4].errors[0].message);
    }
}