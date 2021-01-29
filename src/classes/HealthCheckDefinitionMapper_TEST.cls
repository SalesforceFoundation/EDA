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
* @description Test class for HealthCheckDefinitionMapper
*/
@isTest
private class HealthCheckDefinitionMapper_TEST {
    
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * HealthCheckDefinitionMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        HealthCheckDefinitionMapper healthCheckDefinitionMapperInstance = HealthCheckDefinitionMapper.getInstance();
        Test.stopTest();

        System.assertEquals(HealthCheckDefinitionMapper.instance, healthCheckDefinitionMapperInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, healthCheckDefinitionMapperInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * HealthCheckDefinitionMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
            HealthCheckDefinitionMapper healthCheckDefinitionMapperInstance1 = HealthCheckDefinitionMapper.getInstance();
            HealthCheckDefinitionMapper healthCheckDefinitionMapperInstance2 = HealthCheckDefinitionMapper.getInstance();
        Test.stopTest();

        System.assertEquals(HealthCheckDefinitionMapper.instance, healthCheckDefinitionMapperInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(healthCheckDefinitionMapperInstance1, healthCheckDefinitionMapperInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, healthCheckDefinitionMapperInstance1 != null, 'Instance of service class should not be null.');
    }

    /******************************************************************************
    * @description Test method to verify that the getHealthCheckDefinitionModels
    * method in Health Check Mapper class
    ******************************************************************************/
    @isTest
    private static void getHealthCheckDefinitionModelsExistingFromMapper() {
        HealthCheckDefinitionMapper healthCheckDefinitionMapper = 
            HealthCheckDefinitionMapper.getInstance();

        List<HealthCheckDefinitionModel> expectedHealthCheckDefinitionModelList =
            new List<HealthCheckDefinitionModel>();

        expectedHealthCheckDefinitionModelList.add(new HealthCheckDefinitionModel(
            'AccountModel', 
            'EDAHealthCheckGroupAPIService', 
            'hed')
        );
        
        expectedHealthCheckDefinitionModelList.add(new HealthCheckDefinitionModel(
            'AffiliationMappings', 
            'EDAHealthCheckGroupAPIService', 
            'hed')
        );

        expectedHealthCheckDefinitionModelList.add(new HealthCheckDefinitionModel(
            'ReciprocalRelationship', 
            'EDAHealthCheckGroupAPIService', 
            'hed')
        );

        expectedHealthCheckDefinitionModelList.add(new HealthCheckDefinitionModel(
            'courseconnectionsettings', 
            'EDAHealthCheckGroupAPIService', 
            'hed')
        );

        Test.startTest();
            List<HealthCheckDefinitionModel> healthCheckDefinitionModelList =
                healthCheckDefinitionMapper.getHealthCheckDefinitionModels();
        Test.stopTest();

        System.assertEquals(
            expectedHealthCheckDefinitionModelList.size(),
            healthCheckDefinitionModelList.size(),
            'Health Check Definition Model List size should equal ' + expectedHealthCheckDefinitionModelList.size() + ', that of the expected list.'
        );

        for(Integer i = 0; i < expectedHealthCheckDefinitionModelList.size(); i++) {
            HealthCheckDefinitionModel expectedHealthCheckDefinitionModel = expectedHealthCheckDefinitionModelList[i];
            HealthCheckDefinitionModel healthCheckDefinitionModel = healthCheckDefinitionModelList[i];

            System.assertEquals(
                expectedHealthCheckDefinitionModel.name,
                healthCheckDefinitionModel.name,
                'Health Check Definition Model Name for list item ' + i + ' should equal \'' +
                    expectedHealthCheckDefinitionModel.name +
                    '\' the expected value from the list.'
            );

            System.assertEquals(
                expectedHealthCheckDefinitionModel.className,
                healthCheckDefinitionModel.className,
                'Health Check Definition Model Class Name for list item ' + i + ' should equal \'' +
                    expectedHealthCheckDefinitionModel.className +
                    '\' the expected value from the list.'
            );

            System.assertEquals(
                expectedHealthCheckDefinitionModel.namespace,
                healthCheckDefinitionModel.namespace,
                'Health Check Definition Model Namespace for list item ' + i + ' should equal \'' +
                    expectedHealthCheckDefinitionModel.namespace +
                    '\' the expected value from the list.'
            );
        }
    }
}


