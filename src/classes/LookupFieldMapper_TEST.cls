/*
    Copyright (c) 2021, Salesforce.org
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
* @date 2021
* @group 
* @group-content ../../ApexDocContent/Tests.htm
* @description Test class for LookupFieldMapper class.
*/
@isTest
public with sharing class LookupFieldMapper_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * LookupFieldMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            LookupFieldMapper LookupFieldMapperInstance = LookupFieldMapper.getInstance();
        Test.stopTest();

        System.assertEquals(LookupFieldMapper.instance, LookupFieldMapperInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, LookupFieldMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * LookupFieldMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            LookupFieldMapper LookupFieldMapperInstance1 = LookupFieldMapper.getInstance();
            LookupFieldMapper LookupFieldMapperInstance2 = LookupFieldMapper.getInstance();
        Test.stopTest();

        System.assertEquals(LookupFieldMapper.instance, LookupFieldMapperInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(LookupFieldMapperInstance1, LookupFieldMapperInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, LookupFieldMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test to verify getModelByNameMapForSObjectTypeValid() returns a map with valid lookup field mappings
    * when a specified SObject contains fields that lookup to a specified SObject type.
    **************************************************************************************************************************/
    @isTest 
    private static void getModelByNameMapForSObjectTypeValid(){
        Test.startTest();
        Map<String, LookupFieldModel> lookupFieldModelByNameResult = 
            LookupFieldMapper.getInstance().getModelByNameMapForSObjectType(Contact.SObjectType, Account.SObjectType);
        Test.stopTest();

        System.assertEquals(false, lookupFieldModelByNameResult.isEmpty(), 'Contact object should have fields that lookup to Account.');
        System.assertEquals(true, lookupFieldModelByNameResult.containsKey(UTIL_Namespace.strTokenNSPrefix('Primary_Household__c')), 'Contact object should have field model for \'Primary Household\' field name.');
    }

    /**************************************************************************************************************************
    * @description Test to verify getModelByNameMapForSObjectTypeValid() returns an empty map when a specified SObject 
    * does not contain fields that lookup to a specified SObject type.
    **************************************************************************************************************************/
    @isTest 
    private static void getModelByNameMapForSObjectTypeEmpty(){
        Test.startTest();
        Map<String, LookupFieldModel> lookupFieldModelByNameResult = 
            LookupFieldMapper.getInstance().getModelByNameMapForSObjectType(Trigger_Handler__c.SObjectType, Error__c.SObjectType);
        Test.stopTest();

        System.assertEquals(true, lookupFieldModelByNameResult.isEmpty(), 'Trigger Handler object should have no fields that lookup to Error.');
    }    
}
