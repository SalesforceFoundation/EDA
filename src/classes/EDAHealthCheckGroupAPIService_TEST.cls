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
* @description Test class for EDAHealthCheckGroupAPIService.
*/
@isTest 
private class EDAHealthCheckGroupAPIService_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * EDAHealthCheckGroupAPIService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        HealthCheckGroupAPIServiceInterface EDAHealthCheckGroupAPIServiceInstance = 
            EDAHealthCheckGroupAPIService.getInstance();
        Test.stopTest();

        System.assertEquals(EDAHealthCheckGroupAPIService.instance, EDAHealthCheckGroupAPIServiceInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, EDAHealthCheckGroupAPIServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * EDAHealthCheckGroupAPIService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        HealthCheckGroupAPIServiceInterface EDAHealthCheckGroupAPIServiceInstance1 = 
            EDAHealthCheckGroupAPIService.getInstance();
        HealthCheckGroupAPIServiceInterface EDAHealthCheckGroupAPIServiceInstance2 = 
            EDAHealthCheckGroupAPIService.getInstance();
        Test.stopTest();

        System.assertEquals(EDAHealthCheckGroupAPIService.instance, EDAHealthCheckGroupAPIServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(EDAHealthCheckGroupAPIServiceInstance1, EDAHealthCheckGroupAPIServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, EDAHealthCheckGroupAPIServiceInstance1 != null, 'Instance of service class should not be null.');
    }
    /***************************************************************************
    * @description Test method to verify that the getHealthCheckGroup method
    * returns a valid HealthCheckGroupVModel for Account Settings when
    * the name of accountmodel is provided (case insensitive).
    ***************************************************************************/
    @isTest 
    private static void getHealthCheckGroupAccountModelValid(){
        AccountModelHealthCheckVMapper.instance = new STUB_AccountModelHealthCheckVMapperValidModel();

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = EDAHealthCheckGroupAPIService.getInstance().getHealthCheckGroup('AccountModel');
        Test.stopTest();

        System.assertEquals('AccountModel', healthCheckGroupVModel.label, 'Label for HealthCheckGroupVModel should be \'AccountModel\'');
        System.assertEquals('Pass', healthCheckGroupVModel.status, 'Status for HealthCheckGroupVModel should be \'Pass\'');
        System.assertEquals(4, healthCheckGroupVModel.passedChecks, 'PassedChecks for HealthCheckGroupVModel should be 2.');
        System.assertEquals(4, healthCheckGroupVModel.totalChecks, 'TotalChecks for HealthCheckGroupVModel should be 4.');
        System.assertEquals(true, healthCheckGroupVModel.expandedRowsList.isEmpty(), 'ExpandedRowsList should be empty.');
        System.assertEquals(true, healthCheckGroupVModel.healthCheckItemList.isEmpty(), 'HealthCheckItemList should be empty.');
    }

    /***************************************************************************
    * @description Test method to verify that the getHealthCheckGroup method
    * returns a valid HealthCheckGroupVModel for Reciprocal Relationships when
    * the name of reciprocalrelationship is provided (case insensitive).
    ***************************************************************************/
    @isTest 
    private static void getHealthCheckGroupCouseConnValid(){
        CourseConSettingHealthCheckVMapper.instance = new STUB_CourseConSettingHealthCheckVMapperValidModel();
        Test.startTest();
            HealthCheckGroupVModel hlthChkGrpVMod = EDAHealthCheckGroupAPIService.getInstance().getHealthCheckGroup('courseconnectionsettings');
        Test.stopTest();

        System.assertEquals('Course Connections', hlthChkGrpVMod.label, 'Label for HealthCheckGroupVModel should be \'Course Connections\'');
        System.assertEquals('Pass', hlthChkGrpVMod.status, 'Status for HealthCheckGroupVModel should be \'Pass\'');
        System.assertEquals(3, hlthChkGrpVMod.passedChecks, 'PassedChecks for HealthCheckGroupVModel should be 3.');
        System.assertEquals(3, hlthChkGrpVMod.totalChecks, 'TotalChecks for HealthCheckGroupVModel should be 3.');
        System.assertEquals(true, hlthChkGrpVMod.expandedRowsList.isEmpty(), 'ExpandedRowsList should be empty.');
        System.assertEquals(true, hlthChkGrpVMod.healthCheckItemList.isEmpty(), 'HealthCheckItemList should be empty.');
    }

    /***************************************************************************
    * @description Test method to verify that the getHealthCheckGroup method
    * returns a valid HealthCheckGroupVModel for Reciprocal Relationships when
    * the name of reciprocalrelationship is provided (case insensitive).
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupReciprocalRelationshipValid(){
        ReciprocalRelHealthCheckVMapper.instance =
            new STUB_ReciprocalRelHealthCheckVMapper();

        HealthCheckGroupAPIServiceInterface eDAHealthCheckGroupAPIService
            = EDAHealthCheckGroupAPIService.getInstance();

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                eDAHealthCheckGroupAPIService.getHealthCheckGroup(
                    'reciprocalrelationship'
                );
        Test.stopTest();
        
        System.assertEquals(
            'Reciprocal Relationships',
            healthCheckGroupVModel.label,
            'Label for HealthCheckGroupVModel should be \'Reciprocal Relationships\''
        );
        System.assertEquals(
            'Pass',
            healthCheckGroupVModel.status,
            'Status for HealthCheckGroupVModel should be \'Pass\''
        );
        System.assertEquals(
            1,
            healthCheckGroupVModel.passedChecks,
            'PassedChecks for HealthCheckGroupVModel should be 1.'
        );
        System.assertEquals(
            1,
            healthCheckGroupVModel.totalChecks,
            'TotalChecks for HealthCheckGroupVModel should be 1.'
        );
        System.assertEquals(
            true,
            healthCheckGroupVModel.expandedRowsList.isEmpty(),
            'ExpandedRowsList should be empty.'
        );
        System.assertEquals(
            true,
            healthCheckGroupVModel.healthCheckItemList.isEmpty(),
            'HealthCheckItemList should be empty.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that the getHealthCheckGroup method
    * returns a valid HealthCheckGroupVModel for Affiliation Mappings when
    * the name AffiliationMappings is provided (case insensitive).
    ***************************************************************************/
    @isTest 
    private static void getHealthCheckGroupAffiliationMappingsValid() {
        AffiliationMappingsHealthCheckVMapper.instance =
            new STUB_AffiliationMappingsHealthCheckVMapper();

        HealthCheckGroupAPIServiceInterface eDAHealthCheckGroupAPIService
            = EDAHealthCheckGroupAPIService.getInstance();

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                eDAHealthCheckGroupAPIService.getHealthCheckGroup(
                    'AffiliationMappings'
                );
        Test.stopTest();

        EDAHealthCheckGroupAPIService_TEST.verifyHealthCheckGroupVModelAssertions(
            'Affiliation Mappings', 
            'Pass', 
            4, 
            4, 
            healthCheckGroupVModel
        );
    }

    /***************************************************************************
    * @description Test method to verify that the getHealthCheckGroup method
    * returns null when an invalid name for a HealthCheckDefinitionModel is
    * provided (case insensitive).
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupInValid(){
        HealthCheckGroupAPIServiceInterface eDAHealthCheckGroupAPIService
            = EDAHealthCheckGroupAPIService.getInstance();

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel =
            eDAHealthCheckGroupAPIService.getHealthCheckGroup(
                'Always Going To Be Null'
            );
        Test.stopTest();

       System.assertEquals(
           null,
           healthCheckGroupVModel,
           'Value returned should be null.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that a ReciprocalRelHealthCheckVMapper
    * is retrieved by the locator method.
    ***************************************************************************/
    @isTest 
    private static void locateReciprocalRelHealthCheckVMapper(){
        ReciprocalRelHealthCheckVMapper expectedReciprocalRelHealthCheckVMapper
            = ReciprocalRelHealthCheckVMapper.getInstance();

        EDAHealthCheckGroupAPIService eDAHealthCheckGroupAPIService =
            (EDAHealthCheckGroupAPIService)EDAHealthCheckGroupAPIService.getInstance();

        Test.startTest();
            ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper
                = eDAHealthCheckGroupAPIService.locateReciprocalRelHealthCheckVMapper();
        Test.stopTest();

        System.assertNotEquals(
            null,
            reciprocalRelHealthCheckVMapper,
            'Instance of mapper class should not be null.'
        );

        System.assertEquals(
            expectedReciprocalRelHealthCheckVMapper,
            reciprocalRelHealthCheckVMapper,
            'Instance of view model mapper class from service should match the singleton instance.'
        );
    }

    /**************************************************************************************************************************
    ************************************************* HELPER METHODS **********************************************************
    **************************************************************************************************************************/

    /***************************************************************************
    * @description Helper method to validate assertions for getHealthCheckGroup() results.
    ***************************************************************************/
    private static void verifyHealthCheckGroupVModelAssertions(
        String expectedHealthCheckGroupVModLabel,
        String expectedHealthCheckGroupVModStatus,
        Integer expectedHealthCheckGroupVModPassedCheckCount,
        Integer expectedHealthCheckGroupVModTotalCheckCount,
        HealthCheckGroupVModel actualHealthCheckGroupVModel
    ) {
        System.assertEquals(
            expectedHealthCheckGroupVModLabel,
            actualHealthCheckGroupVModel.label,
            'Label for HealthCheckGroupVModel should be \'' + expectedHealthCheckGroupVModLabel + '\''
        );
        System.assertEquals(
            expectedHealthCheckGroupVModStatus,
            actualHealthCheckGroupVModel.status,
            'Status for HealthCheckGroupVModel should be \'' + expectedHealthCheckGroupVModStatus + '\''
        );
        System.assertEquals(
            expectedHealthCheckGroupVModPassedCheckCount,
            actualHealthCheckGroupVModel.passedChecks,
            'PassedChecks for HealthCheckGroupVModel should be ' + expectedHealthCheckGroupVModPassedCheckCount + '.'
        );
        System.assertEquals(
            expectedHealthCheckGroupVModTotalCheckCount,
            actualHealthCheckGroupVModel.totalChecks,
            'TotalChecks for HealthCheckGroupVModel should be ' + expectedHealthCheckGroupVModTotalCheckCount + '.'
        );
        System.assertEquals(
            true,
            actualHealthCheckGroupVModel.expandedRowsList.isEmpty(),
            'ExpandedRowsList should be empty.'
        );
        System.assertEquals(
            true,
            actualHealthCheckGroupVModel.healthCheckItemList.isEmpty(),
            'HealthCheckItemList should be empty.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that a ReciprocalRelHealthCheckVMapper
    * is retrieved by the locator method.
    ***************************************************************************/
    @isTest 
    private static void locateReciprocalRelHealthCheckVMapperCourseConn(){
        CourseConSettingHealthCheckVMapper expectedCourseConHealthCheckVMapper = CourseConSettingHealthCheckVMapper.getInstance();

        EDAHealthCheckGroupAPIService eDAHealthCheckGroupAPIService = (EDAHealthCheckGroupAPIService)EDAHealthCheckGroupAPIService.getInstance();

        Test.startTest();
            CourseConSettingHealthCheckVMapper courseConHealthCheckVMapper = eDAHealthCheckGroupAPIService.locateCourseConSettingHealthCheckVMapper();
        Test.stopTest();

        System.assertNotEquals(null, courseConHealthCheckVMapper, 'Instance of mapper class should not be null.');

        System.assertEquals(expectedCourseConHealthCheckVMapper, courseConHealthCheckVMapper,'Instance of view model mapper class from service should match the singleton instance.');
    }
    
    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from CourseConSettingHealthCheckVMapper to return a valid HealthCheckGroupVModel.
    **************************************************************************************************************************************/ 
    private class STUB_CourseConSettingHealthCheckVMapperValidModel extends CourseConSettingHealthCheckVMapper {
        @TestVisible 
        public override HealthCheckGroupVModel getHealthCheckGroup(){
            return new HealthCheckGroupVModel('Course Connections',
                                             'Pass',
                                             3,
                                             3,
                                             new List<String>(),
                                             new List<HealthCheckItemVModel>());
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * ReciprocalRelHealthCheckVMapper to return a valid HealthCheckGroupVModel.
    ***************************************************************************/
    private class STUB_ReciprocalRelHealthCheckVMapper extends ReciprocalRelHealthCheckVMapper {
        public override HealthCheckGroupVModel getHealthCheckGroup(){
            return new HealthCheckGroupVModel(
                'Reciprocal Relationships',
                'Pass',
                1,
                1,
                new List<String>(),
                new List<HealthCheckItemVModel>()
            );
        }
    }
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from AccountModelHealthCheckVMapper to return a valid HealthCheckGroupVModel.
    **************************************************************************************************************************************/ 
    private class STUB_AccountModelHealthCheckVMapperValidModel extends AccountModelHealthCheckVMapper {
        @TestVisible 
        public override HealthCheckGroupVModel getHealthCheckGroup(){
            return new HealthCheckGroupVModel('AccountModel',
                                             'Pass',
                                             4,
                                             4,
                                             new List<String>(),
                                             new List<HealthCheckItemVModel>());
        }
    }
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from AffiliationMappingsHealthCheckVMapper to return a valid HealthCheckGroupVModel.
    **************************************************************************************************************************************/ 
    private class STUB_AffiliationMappingsHealthCheckVMapper extends AffiliationMappingsHealthCheckVMapper {
        @TestVisible 
        public override HealthCheckGroupVModel getHealthCheckGroup() {
            return new HealthCheckGroupVModel('Affiliation Mappings',
                                             'Pass',
                                             4,
                                             4,
                                             new List<String>(),
                                             new List<HealthCheckItemVModel>());
        }
    }
}
