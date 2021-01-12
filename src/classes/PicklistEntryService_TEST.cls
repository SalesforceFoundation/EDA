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
* @group-content ../../ApexDocContent/
* @description Test class for PicklistEntryService class
*/
@isTest
private class PicklistEntryService_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * PicklistEntryService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            PicklistEntryService picklistEntryServiceInstance = PicklistEntryService.getInstance();
        Test.stopTest();

        System.assertEquals(PicklistEntryService.instance, picklistEntryServiceInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, picklistEntryServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * PicklistEntryService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            PicklistEntryService picklistEntryServiceInstance1 = PicklistEntryService.getInstance();
            PicklistEntryService picklistEntryServiceInstance2 = PicklistEntryService.getInstance();
        Test.stopTest();

        System.assertEquals(PicklistEntryService.instance, picklistEntryServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(picklistEntryServiceInstance1, picklistEntryServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, picklistEntryServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /***********************************************************************************************************************************
    * @description Test method to verify that the locatePicklistEntryMapper method returns instance of PicklistEntryMapper
    ***********************************************************************************************************************************/
    @isTest
    private static void locatePicklistEntryMapper() {

        Test.startTest();
            PicklistEntryMapper pcklstEntryMapper = PicklistEntryService.getInstance().locatePicklistEntryMapper();
        Test.stopTest();

        System.assertEquals(PicklistEntryMapper.getInstance(), pcklstEntryMapper, 'Should return the instance of PicklistEntryMapper');

    }

    /***********************************************************************************************************************************
    * @description Test method to verify that the getModelsByNameForSObjectField method returns instance of PicklistEntry Models
    ***********************************************************************************************************************************/
    @isTest
    private static void getModelsByNameForSObjectField() {

        PicklistEntryMapper.instance = new STUB_PicklistEntryMapper();

        Test.startTest();
            Map<String, PicklistEntryModel> picklistEntryModelsByPicklistEntryName = 
                PicklistEntryService.getInstance().getModelsByNameForSObjectField(Account.getSObjectType(), Account.Type.getDescribe().getSObjectField());
        Test.stopTest();

        System.assertEquals(1, picklistEntryModelsByPicklistEntryName.size(), 'Retieved map should contain models for all the picklist entries');
        System.assertEquals('Prospect', picklistEntryModelsByPicklistEntryName.get('Prospect').name, 'Map should retrieve the name of the picklist entry');
        System.assertEquals('Prospect', picklistEntryModelsByPicklistEntryName.get('Prospect').label, 'Map should retrieve the label of the picklist entry');
        System.assertEquals(true, picklistEntryModelsByPicklistEntryName.get('Prospect').isActive, 'Map should retrieve active status of the picklist entry');

    }

    /***********************************************************************************************************************************
    ****************************************************** STUBS ***********************************************************************
    ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from PicklistEntryMapper to return a map of picklistEntryModelsByPicklistEntryName
    **************************************************************************************************************************************/ 
    private class STUB_PicklistEntryMapper extends PicklistEntryMapper {

        public override Map<String, PicklistEntryModel> getModelsByNameForSObjectField(SObjectType sObjectTypeName, SObjectField sObjectFieldName) {

            Map<String, PicklistEntryModel> picklistEntryModelsByPicklistEntryName= new Map<String, PicklistEntryModel>();

            PicklistEntryModel pcklstEntryModel = new PicklistEntryModel('Prospect', 'Prospect', true);
            picklistEntryModelsByPicklistEntryName.put('Prospect', pcklstEntryModel);

            return picklistEntryModelsByPicklistEntryName;
        }
    }
}