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
* @group Health Check
* @group-content ../../ApexDocContent/Tests.htm
* @description Test class for AffiliationMappingsModel class.
*/
@isTest
public with sharing class AffiliationMappingsModel_TEST {
    
    /*****************************************************************************
    * @description Test to verify constructor with six arguments instantiates a 
    * model with the appropriate data.
    *****************************************************************************/
    @isTest 
    private static void affiliationMappingsModelValid(){
        Test.startTest();
        AffiliationMappingsModel afflMappingMod = new AffiliationMappingsModel(
            'TestAfflMappingModel',
            'HH_Account',
            'Test Primary Affl Field',
            true,
            'Test Status',
            'Test Role'
        );
        Test.stopTest();

        String expectedRTString = (String)Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId();

        System.assertEquals('TestAfflMappingModel', afflMappingMod.name, 'Name should be set.');
        System.assertEquals(expectedRTString, afflMappingMod.accountRecordTypeId, 'Record Type Id for HH_Account should be set.');
        System.assertEquals('Test Primary Affl Field', afflMappingMod.primaryAffiliationField, 'Primary Affiliation Field should be set.');
        System.assertEquals(true, afflMappingMod.autoProgramEnrollment, 'Auto Enrollment should be true');
        System.assertEquals('Test Status', afflMappingMod.autoProgramEnrollmentStatus, 'Auto Enrollment Status should be set.');
        System.assertEquals('Test Role', afflMappingMod.autoProgramEnrollmentRole, 'Auto Enrollment Role should be set.');
    }

    /*****************************************************************************
    * @description Test to verify constructor with six arguments instantiates a 
    * model with the appropriate data when an invalid record type developer name is specified.
    *****************************************************************************/
    @isTest 
    private static void affiliationMappingsModelNullRecordTypeId(){
        Test.startTest();
        AffiliationMappingsModel afflMappingMod = new AffiliationMappingsModel(
            'TestAfflMappingModel',
            'Not a Valid Record Type Dev Name',
            'Test Primary Affl Field',
            true,
            'Test Status',
            'Test Role'
        );
        Test.stopTest();

        System.assertEquals('TestAfflMappingModel', afflMappingMod.name, 'Name should be set.');
        System.assertEquals('Not a Valid Record Type Dev Name', afflMappingMod.accountRecordTypeId, 'Record Type Id should be \'Not a Valid Record Type Dev Name\'.');
        System.assertEquals('Test Primary Affl Field', afflMappingMod.primaryAffiliationField, 'Primary Affiliation Field should be set.');
        System.assertEquals(true, afflMappingMod.autoProgramEnrollment, 'Auto Enrollment should be true');
        System.assertEquals('Test Status', afflMappingMod.autoProgramEnrollmentStatus, 'Auto Enrollment Status should be set.');
        System.assertEquals('Test Role', afflMappingMod.autoProgramEnrollmentRole, 'Auto Enrollment Role should be set.');
    }
}
