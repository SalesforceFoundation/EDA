/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group 
* @group-content ../../ApexDocContent/
* @description Test class for SRVC_ChildRelationshipNames class
*/
@isTest
private class SRVC_ChildRelationshipNames_TEST {
    
    @TestSetup
    private static void testSetup() {
    
        // Insert Account
        String acctName = 'Test Account 000';
        List<Account> acctList = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getAdminAccRecTypeID());
        acctList[0].Name = acctName;
        insert acctList[0];
        
    }
    
    // Test retrieval of child relationship names for Account
    @isTest
    private static void testChildRelationshipNamesService() {
    
        List<Account> accts = [SELECT Id FROM Account];
        Test.startTest();
            String sObjectName = accts[0].Id.getSObjectType().getDescribe().getName();
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
            List<String> allCHildRelationshipNames = SRVC_ChildRelationshipNames.findAllChildRelationshipNames(sObjectType);
        Test.stopTest();
        
        System.assert(allCHildRelationshipNames != NULL);
        System.assert(allCHildRelationshipNames.size() != 0);
        System.assert(allCHildRelationshipNames.contains('Contacts'));
    }    
}