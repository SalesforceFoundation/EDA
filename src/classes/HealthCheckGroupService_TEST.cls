/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group
* @group-content ../../ApexDocContent/Tests.htm
* @description Test class for HealthCheckGroupService class.
*/
@isTest 
public with sharing class HealthCheckGroupService_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * HealthCheckGroupService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
            HealthCheckGroupService HealthCheckGroupServiceInstance = HealthCheckGroupService.getInstance();
        Test.stopTest();

        System.assertEquals(HealthCheckGroupService.instance, HealthCheckGroupServiceInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, HealthCheckGroupServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * HealthCheckGroupService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
            HealthCheckGroupService HealthCheckGroupServiceInstance1 = HealthCheckGroupService.getInstance();
            HealthCheckGroupService HealthCheckGroupServiceInstance2 = HealthCheckGroupService.getInstance();
        Test.stopTest();

        System.assertEquals(HealthCheckGroupService.instance, HealthCheckGroupServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(HealthCheckGroupServiceInstance1, HealthCheckGroupServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, HealthCheckGroupServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckGroup method returns a HealthCheckGroup view model when provided
    * with valid HealthCheckDefinitionModel data.
    ***************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckGroupValidReciprocal(){
        ReciprocalRelHealthCheckVMapper.instance = new STUB_ReciprocalRelHealthCheckVMapper();
        HealthCheckGroupService.instance = new STUB_HealthCheckGroupServiceEDAHealthCheckAPI();
        HealthCheckGroupService healthCheckGroupService =
            HealthCheckGroupService.getInstance();

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                healthCheckGroupService.getHealthCheckGroup(
                    'reciprocalrelationship',
                    'EDAHealthCheckGroupAPIService',
                    'hed'
                );
        Test.stopTest();

        System.assertEquals('Mocked', healthCheckGroupVModel.label, 'Label for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
        System.assertEquals('Pass', healthCheckGroupVModel.status, 'Status for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
        System.assertEquals(2, healthCheckGroupVModel.passedChecks, 'Passed Checks for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
        System.assertEquals(2, healthCheckGroupVModel.totalChecks, 'Total Checks for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
        System.assertEquals(true, healthCheckGroupVModel.expandedRowsList.isEmpty(), 'Expanded rows list for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
        System.assertEquals(2, healthCheckGroupVModel.healthCheckItemList.size(), 'Health Check items list for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckGroup method returns a HealthCheckGroup view model when provided
    * with valid HealthCheckDefinitionModel data.
    ***************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckGroupValidCourseConn(){

        CourseConSettingHealthCheckVMapper.instance = new STUB_CourseConSettingHealthCheckVMapper();
        HealthCheckGroupService.instance = new STUB_HealthCheckGroupServiceEDAHealthCheckAPI();

        Test.startTest();
            HealthCheckGroupVModel hlthChkGroupVMod = 
                HealthCheckGroupService.getInstance(
                ).getHealthCheckGroup(
                    'courseconnectionsettings', 
                    'EDAHealthCheckGroupAPIService',
                    'hed'
                );
        Test.stopTest();
            System.assertEquals('Mocked', hlthChkGroupVMod.label, 'Label for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals('Pass', hlthChkGroupVMod.status, 'Status for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals(2, hlthChkGroupVMod.passedChecks, 'Passed Checks for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals(2, hlthChkGroupVMod.totalChecks, 'Total Checks for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals(true, hlthChkGroupVMod.expandedRowsList.isEmpty(), 'Expanded rows list for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals(2, hlthChkGroupVMod.healthCheckItemList.size(), 'Health Check items list for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckGroup method returns a HealthCheckGroup view model when provided
    * with valid HealthCheckDefinitionModel data.
    ***************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckGroupValidAccountModel(){

        AccountModelHealthCheckVMapper.instance = new STUB_AccountModelHealthCheckVMapper();
        HealthCheckGroupService.instance = new STUB_HealthCheckGroupServiceEDAHealthCheckAPI();

        Test.startTest();
            HealthCheckGroupVModel hlthChkGroupVMod = 
                HealthCheckGroupService.getInstance(
                ).getHealthCheckGroup(
                    'accountmodel', 
                    'EDAHealthCheckGroupAPIService',
                    'hed'
                );
        Test.stopTest();
            System.assertEquals('Mocked', hlthChkGroupVMod.label, 'Label for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals('Pass', hlthChkGroupVMod.status, 'Status for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals(2, hlthChkGroupVMod.passedChecks, 'Passed Checks for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals(2, hlthChkGroupVMod.totalChecks, 'Total Checks for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals(true, hlthChkGroupVMod.expandedRowsList.isEmpty(), 'Expanded rows list for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals(2, hlthChkGroupVMod.healthCheckItemList.size(), 'Health Check items list for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckGroup method returns a HealthCheckGroup view model when provided
    * with valid HealthCheckDefinitionModel data.
    ***************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckGroupValidAffiliationMappings(){

        AffiliationMappingsHealthCheckVMapper.instance = new STUB_AffiliationMappingsHealthCheckVMapper();
        HealthCheckGroupService.instance = new STUB_HealthCheckGroupServiceEDAHealthCheckAPI();

        Test.startTest();
            HealthCheckGroupVModel hlthChkGroupVMod = 
                HealthCheckGroupService.getInstance(
                ).getHealthCheckGroup(
                    'affiliationmappings', 
                    'EDAHealthCheckGroupAPIService',
                    'hed'
                );
        Test.stopTest();
            System.assertEquals('Mocked', hlthChkGroupVMod.label, 'Label for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals('Pass', hlthChkGroupVMod.status, 'Status for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals(2, hlthChkGroupVMod.passedChecks, 'Passed Checks for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals(2, hlthChkGroupVMod.totalChecks, 'Total Checks for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals(true, hlthChkGroupVMod.expandedRowsList.isEmpty(), 'Expanded rows list for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
            System.assertEquals(2, hlthChkGroupVMod.healthCheckItemList.size(), 'Health Check items list for returned HC Group view model should match valud in EDAHealthCheckGroupAPIService.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckGroup method returns a null HealthCheckGroup view model when 
    * provided with invalid HealthCheckDefinitionModel data.
    ***************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckGroupInValid(){
        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel =
            HealthCheckGroupService.getInstance(
            ).getHealthCheckGroup(
                'Non-existent Health Check Group',
                'EDAHealthCheckGroupAPIService',
                'hed'
            );
        Test.stopTest();

        System.assertEquals(true, healthCheckGroupVModel == null, 'Health Check Group view model should be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the locateHealthCheckGroupAPIService method returns a valid instance of 
    * HealthCheckGroupAPIServiceInterface when a valid classname and namespace corresponding to a Serivce that implements the 
    * interface is provided.
    ***************************************************************************************************************************/
    @isTest 
    private static void locateHealthCheckGroupAPIServiceValid(){
        Test.startTest();
        HealthCheckGroupAPIServiceInterface healthCheckGroupAPIServiceInterface = 
            HealthCheckGroupService.getInstance().locateHealthCheckGroupAPIService('EDAHealthCheckGroupAPIService', 'hed');
        Test.stopTest();

        System.assertEquals(EDAHealthCheckGroupAPIService.getInstance(), healthCheckGroupAPIServiceInterface.getInstance(), 
                'HealthCheckGroupAPIServiceInterface should be instance of EDAHealthCheckGroupAPIService.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the locateHealthCheckGroupAPIService method throws a NullPointerException  
    * when an invalid classname an an invalid namespace is provided.
    ***************************************************************************************************************************/
    @isTest 
    private static void locateHealthCheckGroupAPIServiceInValidClassName(){
        try{
            Test.startTest();
            HealthCheckGroupAPIServiceInterface healthCheckGroupAPIServiceInterface = 
            HealthCheckGroupService.getInstance().locateHealthCheckGroupAPIService('Not a Valid Service Name', 'abc');
            Test.stopTest();
        } catch (System.NullPointerException e){
            System.assertEquals(true, String.isNotBlank(e.getMessage()), 'Invalid className should throw NullPointerException.');
        } catch (HealthCheckGroupService.HealthCheckNotFoundException hcNotFoundEx){
            System.assertEquals(true, String.isNotBlank(hcNotFoundEx.getMessage()), 'NullPointerException should throw HealthCheckNotFoundException.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the locateHealthCheckGroupAPIService method throws a TypeException  
    * when a valid classname to a class that does not extend the HealthCheckGroupAPIServiceInterface and blank namespace is provided.
    ***************************************************************************************************************************/
    @isTest 
    private static void locateHealthCheckGroupAPIServiceValidClassNameNotImplementingInterface(){
        try{
            Test.startTest();
            HealthCheckGroupAPIServiceInterface healthCheckGroupAPIServiceInterface = 
            HealthCheckGroupService.getInstance().locateHealthCheckGroupAPIService('HealthCheckVMapper', '');
            Test.stopTest();
        } catch (System.TypeException e){
            System.assertEquals(true, String.isNotBlank(e.getMessage()), 'Invalid className should throw TypeException.');
        } catch (HealthCheckGroupService.HealthCheckNotFoundException hcNotFoundEx){
            System.assertEquals(true, String.isNotBlank(hcNotFoundEx.getMessage()), 'TypeException should throw HealthCheckNotFoundException.');
        }
    }

    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from HealthCheckGroupService to return instance of EDAHealthCheckGroupAPIService.
    **************************************************************************************************************************************/ 
    private class STUB_HealthCheckGroupServiceEDAHealthCheckAPI extends HealthCheckGroupService {
        @TestVisible 
        private override HealthCheckGroupAPIServiceInterface locateHealthCheckGroupAPIService(
            String className,
            String namespace
        ){ 
            return EDAHealthCheckGroupAPIService.getInstance(); 
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * EDAHealthCheckGroupAPIService to control for a static response
    ***************************************************************************/
    private class STUB_ReciprocalRelHealthCheckVMapper extends ReciprocalRelHealthCheckVMapper {

        public override HealthCheckGroupVModel getHealthCheckGroup(){
            List<HealthCheckItemVModel> healthCheckItemsList = new List<HealthCheckItemVModel>();
            List<String> rowKeysList = new List<String>();
    
            HealthCheckItemVModel healthCheckItemModel1 = 
                new HealthCheckItemVModel(
                    '01', 
                    'Passed Setting 1', 
                    'Pass', 
                    Label.stgHealthCheckStatusPassed, 
                    'Mocked description 1', 
                    'Mocked recommended fix 1',
                    new List<HealthCheckItemVModel>()
                );
                                                                                
            HealthCheckItemVModel healthCheckItemModel2 = 
                new HealthCheckItemVModel(
                    '02',
                    'Passed Setting 2',
                    'Pass',
                    Label.stgHealthCheckStatusPassed,
                    'Mocked description 2',
                    'Mocked recommended fix 2',
                    new List<HealthCheckItemVModel>()
                );
            
            healthCheckItemsList.add(healthCheckItemModel1);
            healthCheckItemsList.add(healthCheckItemModel2);

            return new HealthCheckGroupVModel(
                'Mocked',
                'Pass',
                2,
                2,
                rowKeysList,
                healthCheckItemsList
            );
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * EDAHealthCheckGroupAPIService to control for a static response
    ***************************************************************************/
    private class STUB_CourseConSettingHealthCheckVMapper extends CourseConSettingHealthCheckVMapper {

        public override HealthCheckGroupVModel getHealthCheckGroup(){
            List<HealthCheckItemVModel> hlthChkItemsList = new List<HealthCheckItemVModel>();
            List<String> rowKeysList = new List<String>();

            HealthCheckItemVModel hlthChkItemMod1 = 
                new HealthCheckItemVModel(
                    '01', 
                    'Passed Setting 1', 
                    'Pass', 
                    Label.stgHealthCheckStatusPassed, 
                    'Mocked description 1', 
                    'Mocked recommended fix 1',
                    new List<HealthCheckItemVModel>()
                );

            HealthCheckItemVModel hlthChkItemMod2 = 
                new HealthCheckItemVModel(
                    '02',
                    'Passed Setting 2',
                    'Pass',
                    Label.stgHealthCheckStatusPassed,
                    'Mocked description 2',
                    'Mocked recommended fix 2',
                    new List<HealthCheckItemVModel>()
                );

            hlthChkItemsList.add(hlthChkItemMod1);
            hlthChkItemsList.add(hlthChkItemMod2);

            return new HealthCheckGroupVModel(
                'Mocked',
                'Pass',
                2,
                2,
                rowKeysList,
                hlthChkItemsList
            );
        }
    }
    
    /***************************************************************************
    * @description Stub class to simulate the response from
    * EDAHealthCheckGroupAPIService to control for a static response
    ***************************************************************************/
    private class STUB_AccountModelHealthCheckVMapper extends AccountModelHealthCheckVMapper {

        public override HealthCheckGroupVModel getHealthCheckGroup(){
            List<HealthCheckItemVModel> hlthChkItemsList = new List<HealthCheckItemVModel>();
            List<String> rowKeysList = new List<String>();

            HealthCheckItemVModel hlthChkItemMod1 = 
                new HealthCheckItemVModel(
                    '01', 
                    'Passed Setting 1', 
                    'Pass', 
                    Label.stgHealthCheckStatusPassed, 
                    'Mocked description 1', 
                    'Mocked recommended fix 1',
                    new List<HealthCheckItemVModel>()
                );

            HealthCheckItemVModel hlthChkItemMod2 = 
                new HealthCheckItemVModel(
                    '02',
                    'Passed Setting 2',
                    'Pass',
                    Label.stgHealthCheckStatusPassed,
                    'Mocked description 2',
                    'Mocked recommended fix 2',
                    new List<HealthCheckItemVModel>()
                );

            hlthChkItemsList.add(hlthChkItemMod1);
            hlthChkItemsList.add(hlthChkItemMod2);

            return new HealthCheckGroupVModel(
                'Mocked',
                'Pass',
                2,
                2,
                rowKeysList,
                hlthChkItemsList
            );
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * EDAHealthCheckGroupAPIService to control for a static response
    ***************************************************************************/
    private class STUB_AffiliationMappingsHealthCheckVMapper extends AffiliationMappingsHealthCheckVMapper {

        public override HealthCheckGroupVModel getHealthCheckGroup(){
            List<HealthCheckItemVModel> hlthChkItemsList = new List<HealthCheckItemVModel>();
            List<String> rowKeysList = new List<String>();

            HealthCheckItemVModel hlthChkItemMod1 = 
                new HealthCheckItemVModel(
                    '01', 
                    'Passed Setting 1', 
                    'Pass', 
                    Label.stgHealthCheckStatusPassed, 
                    'Mocked description 1', 
                    'Mocked recommended fix 1',
                    new List<HealthCheckItemVModel>()
                );

            HealthCheckItemVModel hlthChkItemMod2 = 
                new HealthCheckItemVModel(
                    '02',
                    'Passed Setting 2',
                    'Pass',
                    Label.stgHealthCheckStatusPassed,
                    'Mocked description 2',
                    'Mocked recommended fix 2',
                    new List<HealthCheckItemVModel>()
                );

            hlthChkItemsList.add(hlthChkItemMod1);
            hlthChkItemsList.add(hlthChkItemMod2);

            return new HealthCheckGroupVModel(
                'Mocked',
                'Pass',
                2,
                2,
                rowKeysList,
                hlthChkItemsList
            );
        }
    }
}