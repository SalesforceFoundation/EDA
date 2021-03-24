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
 * @description Test class for SObjectFieldService class
 */
@isTest
private with sharing class SObjectFieldService_TEST {
    private static Integer loopCounter = 5;

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * SObjectFieldService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        SObjectFieldService sObjectFieldServiceInstance = SObjectFieldService.getInstance();
        Test.stopTest();

        System.assertEquals(
            SObjectFieldService.instance,
            sObjectFieldServiceInstance,
            'Instance of mapper class returned should match static instance variable.'
        );

        System.assertEquals(true, sObjectFieldServiceInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * SObjectFieldService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        SObjectFieldService sObjectFieldServiceInstance1 = SObjectFieldService.getInstance();
        SObjectFieldService sObjectFieldServiceInstance2 = SObjectFieldService.getInstance();
        Test.stopTest();

        System.assertEquals(
            SObjectFieldService.instance,
            sObjectFieldServiceInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );

        System.assertEquals(
            sObjectFieldServiceInstance1,
            sObjectFieldServiceInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );

        System.assertEquals(true, sObjectFieldServiceInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateSObjectFieldMapper method returns an instance of the SObjectFieldMapper class.
     ***************************************************************************************************************************/
    @isTest
    private static void locateSObjectFieldMapperValid() {
        SObjectFieldService sObjectFieldServiceInstance = SObjectFieldService.getInstance();

        Test.startTest();
        SObjectFieldMapper sObjectFieldMapperInstance = sObjectFieldServiceInstance.locateSObjectFieldMapper();
        Test.stopTest();

        System.assertEquals(
            SObjectFieldMapper.getInstance(),
            sObjectFieldMapperInstance,
            'Should return instance of SObjectFieldMapper class.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getModelsByTypeForSObject method returns a map containing all fields
     * of a specified type on an SObject when they exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getModelsByTypeForSObjectValid() {
        SObjectFieldMapper.instance = new STUB_SObjectFieldMapper();

        SObjectFieldService sObjectFieldServiceInstance = SObjectFieldService.getInstance();

        Test.startTest();
        Map<String, SObjectFieldModel> sObjectFieldModelsByFieldName = sObjectFieldServiceInstance.getModelsByTypeForSObject(
            Contact.SObjectType,
            'PHONE'
        );
        Test.stopTest();

        System.assertEquals(
            loopCounter,
            sObjectFieldModelsByFieldName.size(),
            'Should return ' +
            loopCounter +
            ' fields of type \'PHONE\' for Contact object.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getModelsByTypeForSObject method returns an empty map when an no fields
     * of a specified type exist for an SObject.
     ***************************************************************************************************************************/
    @isTest
    private static void getModelsByTypeForSObjectEmpty() {
        SObjectFieldMapper.instance = new STUB_SObjectFieldMapperEmpty();

        SObjectFieldService sObjectFieldServiceInstance = SObjectFieldService.getInstance();

        Test.startTest();
        Map<String, SObjectFieldModel> sObjectFieldModelsByFieldName = sObjectFieldServiceInstance.getModelsByTypeForSObject(
            Affiliation__c.SObjectType,
            'PHONE'
        );
        Test.stopTest();

        System.assertEquals(
            0,
            sObjectFieldModelsByFieldName.size(),
            'Should return zero fields of type \'PHONE\' for Affiliation object.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getModelsByTypeForSObject method returns an empty map when an invalid field
     * type is specified for an SObject.
     ***************************************************************************************************************************/
    @isTest
    private static void getModelsByTypeForSObjectInvalid() {
        SObjectFieldMapper.instance = new STUB_SObjectFieldMapperEmpty();

        SObjectFieldService sObjectFieldServiceInstance = SObjectFieldService.getInstance();

        Test.startTest();
        Map<String, SObjectFieldModel> sObjectFieldModelsByFieldName = sObjectFieldServiceInstance.getModelsByTypeForSObject(
            Contact.SObjectType,
            'TEST FIELD NAME'
        );
        Test.stopTest();

        System.assertEquals(
            0,
            sObjectFieldModelsByFieldName.size(),
            'Should return zero fields of type \'TEST FIELD NAME\' for Contact object.'
        );
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate a successful response from SObjectFieldMapper
     **************************************************************************************************************************************/
    private class STUB_SObjectFieldMapper extends SObjectFieldMapper {
        public override Map<String, SObjectFieldModel> getModelsByTypeForSObject(
            SObjectType sObjectType,
            String fieldType
        ) {
            Map<String, SObjectFieldModel> sObjectFieldModelsByFieldName = new Map<String, SObjectFieldModel>();

            for (Integer i = 0; i < loopCounter; i++) {
                sObjectFieldModelsByFieldName.put(
                    'FieldName' + i,
                    new SObjectFieldModel('FieldLabel' + i, 'FieldName' + i)
                );
            }

            return sObjectFieldModelsByFieldName;
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate an empty response from SObjectFieldMapper
     **************************************************************************************************************************************/
    private class STUB_SObjectFieldMapperEmpty extends SObjectFieldMapper {
        public override Map<String, SObjectFieldModel> getModelsByTypeForSObject(
            SObjectType sObjectType,
            String fieldType
        ) {
            return new Map<String, SObjectFieldModel>();
        }
    }
}
