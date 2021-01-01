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
* @description Test class for HealthCheckDefinitionService
*/
@isTest
private class HealthCheckDefinitionService_TEST {
    
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * HealthCheckDefinitionService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
            HealthCheckDefinitionService healthCheckDefinitionServiceInstance = HealthCheckDefinitionService.getInstance();
        Test.stopTest();

        System.assertEquals(HealthCheckDefinitionService.instance, healthCheckDefinitionServiceInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, healthCheckDefinitionServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * HealthCheckDefinitionService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
            HealthCheckDefinitionService healthCheckDefinitionServiceInstance1 = HealthCheckDefinitionService.getInstance();
            HealthCheckDefinitionService healthCheckDefinitionServiceInstance2 = HealthCheckDefinitionService.getInstance();
        Test.stopTest();

        System.assertEquals(HealthCheckDefinitionService.instance, healthCheckDefinitionServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(healthCheckDefinitionServiceInstance1, healthCheckDefinitionServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, healthCheckDefinitionServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckDefinitionModels method in Health Check Service class
    * returns a list of Health Check Definition models
    ***************************************************************************************************************************/
    @isTest
    private static void getHealthCheckDefinitionModelsExistingFromService() {
        HealthCheckDefinitionMapper.instance = new STUB_HealthCheckDefinitionMapper();
        Test.startTest();
            List<HealthCheckDefinitionModel> healthCheckDefinitionModels = HealthCheckDefinitionService.getInstance().getHealthCheckDefinitionModels();
        Test.stopTest();

        System.assertEquals(3, healthCheckDefinitionModels.size());
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the locateHealthCheckDefinitionMapper method 
    * returns an instance of HealthCheckDefinitionMapper
    ***************************************************************************************************************************/
    @isTest
    private static void locateHealthCheckDefinitionMapperTest() {
        Test.startTest();
            HealthCheckDefinitionMapper healthCheckDefinitionMapperInstance = HealthCheckDefinitionMapper.getInstance();
        Test.stopTest();

        System.assertEquals(HealthCheckDefinitionMapper.instance, healthCheckDefinitionMapperInstance);
    }

    /**************************************************************************************************************************
    ****************************************************** STUB CLASS *********************************************************
    **************************************************************************************************************************/

    /*************************************************************************************************************
    * @description Stub class to simulate the response from HealthCheckDefinitionMapper to return a list of HealthCheckDefinitionModel
    */
    private class STUB_HealthCheckDefinitionMapper extends HealthCheckDefinitionMapper {
        public override List<HealthCheckDefinitionModel> getHealthCheckDefinitionModels() {
            List<HealthCheckDefinitionModel> stubHealthCheckDefinitionModelList = new List<HealthCheckDefinitionModel>();
            stubHealthCheckDefinitionModelList.add(new HealthCheckDefinitionModel('All Success',
                                                                        'EDAHealthCheckGroupAPIService',
                                                                        'hed'));
            stubHealthCheckDefinitionModelList.add(new HealthCheckDefinitionModel('All Failure',
                                                                        'EDAHealthCheckGroupAPIService',
                                                                        'hed'));
            stubHealthCheckDefinitionModelList.add(new HealthCheckDefinitionModel('Mixed',
                                                                        'EDAHealthCheckGroupAPIService',
                                                                        'hed'));
            return stubHealthCheckDefinitionModelList;         
        }
    }
}
