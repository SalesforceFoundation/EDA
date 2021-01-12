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
* @description Test class for AffiliationMappingsHealthCheckVMapper class.
*/
@isTest 
public with sharing class AfflMappingsHealthCheckVMapper_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AffiliationMappingsHealthCheckVMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapperInstance = AffiliationMappingsHealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AffiliationMappingsHealthCheckVMapper.instance, AffiliationMappingsHealthCheckVMapperInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, AffiliationMappingsHealthCheckVMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AffiliationMappingsHealthCheckVMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapperInstance1 = AffiliationMappingsHealthCheckVMapper.getInstance();
            AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapperInstance2 = AffiliationMappingsHealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AffiliationMappingsHealthCheckVMapper.instance, AffiliationMappingsHealthCheckVMapperInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(AffiliationMappingsHealthCheckVMapperInstance1, AffiliationMappingsHealthCheckVMapperInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, AffiliationMappingsHealthCheckVMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test to verify locateRecordTypeService() returns an instance of the RecordTypeService class.
    **************************************************************************************************************************/ 
    @isTest
    private static void locateRecordTypeServiceValid(){
        Test.startTest();
        RecordTypeService recordTypeServiceInstance = AccountModelHealthCheckVMapper.getInstance().locateRecordTypeService();
        Test.stopTest();

        System.assertEquals(RecordTypeService.getInstance(), recordTypeServiceInstance, 'Should return instance of RecordTypeService class.');
        System.assertEquals(true, recordTypeServiceInstance != null, 'Instance of RecordTypeService class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test to verify locateAffiliationMappingsService() returns an instance of the AffiliationMappingsService class.
    **************************************************************************************************************************/ 
    @isTest
    private static void locateAffiliationMappingsServiceValid(){
        Test.startTest();
        AffiliationMappingsService AffiliationMappingsServiceInstance = AffiliationMappingsHealthCheckVMapper.getInstance().locateAffiliationMappingsService();
        Test.stopTest();

        System.assertEquals(AffiliationMappingsService.getInstance(), AffiliationMappingsServiceInstance, 'Should return instance of AffiliationMappingsService class.');
        System.assertEquals(true, AffiliationMappingsServiceInstance != null, 'Instance of AffiliationMappingsService class should not be null.');
    }

    @isTest 
    private static void getValidRecordTypeHealthCheckGroupVModelValid(){

    }

    @isTest 
    private static void getValidRecordTypeHealthCheckGroupVModelNullRT(){
        
    }

    @isTest 
    private static void getValidRecordTypeHealthCheckGroupVModelInactiveRT(){
        
    }

    @isTest 
    private static void getValidRecordTypeHealthCheckGroupVModelNonExistentRT(){
        
    }
}
