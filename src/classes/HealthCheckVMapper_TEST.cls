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
* @description Test class for HealthCheckVMapper class
*/

@isTest 
public class HealthCheckVMapper_TEST {

    /**************************************************************************************************************************
    ***************************************************** UNIT TESTS **********************************************************
    **************************************************************************************************************************/
    
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * HealthCheckVMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            HealthCheckVMapper healthCheckVMapperInstance = HealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(HealthCheckVMapper.instance, healthCheckVMapperInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, healthCheckVMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * HealthCheckVMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            HealthCheckVMapper HealthCheckVMapperInstance1 = HealthCheckVMapper.getInstance();
            HealthCheckVMapper HealthCheckVMapperInstance2 = HealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(HealthCheckVMapper.instance, HealthCheckVMapperInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(HealthCheckVMapperInstance1, HealthCheckVMapperInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, HealthCheckVMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /****************************************************************************************************************************
    * @description Test method to verify that the locateFeatureParameterService method returns instance of FeatureParameterService.
    ****************************************************************************************************************************/
    @isTest
    private static void locateFeatureParameterServiceValid() {
        Test.startTest();
            FeatureParameterService featureParamService = HealthCheckVMapper.getInstance().locateFeatureParameterService();
        Test.stopTest();

        System.assertEquals(FeatureParameterService.getInstance(), featureParamService, 'Should return the instance of FeatureParameterService.');
    }    

    /****************************************************************************************************************************
    * @description Test method to verify that the locateHealthCheckDefinitionService method returns instance of HealthCheckDefinitionService.
    ****************************************************************************************************************************/
    @isTest
    private static void locateHealthCheckDefinitionServiceValid() {
        Test.startTest();
        HealthCheckDefinitionService healthCheckDefService = HealthCheckVMapper.getInstance().locateHealthCheckDefinitionService();
        Test.stopTest();

        System.assertEquals(HealthCheckDefinitionService.getInstance(), healthCheckDefService, 'Should return the instance of HealthCheckDefinitionService.');
    }

    /****************************************************************************************************************************
    * @description Test to verify that getHealthCheckViewModel method returns a Health Check View Model.
    ****************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckViewModelValid(){

        FeatureParameterMapper.instance = new STUB_FeatureParameterDateModel();
        HealthCheckDefinitionService.instance = new STUB_HealthCheckDefinitionService();

        Test.startTest();
        HealthCheckVModel healthCheckVModel = HealthCheckVMapper.getInstance().getHealthCheckViewModel();
        Test.stopTest();

        System.assertEquals(Date.today().addDays(-3).format(), healthCheckVModel.lastRunDate, 'Last run date should be 3 days before current date.');
        System.assertEquals(10, healthCheckVModel.numberOfHealthChecks, 'Number of healt checks to run should equal 10.');
        System.assertEquals(10, healthCheckVModel.healthCheckDefinitionList.size(), 'There should be 10 health check definition view models.');
     
        for (Integer i = 0; i < healthCheckVModel.healthCheckDefinitionList.size(); i++){
            System.assertEquals('Test Health Check ' + i, healthCheckVModel.healthCheckDefinitionList[i].name, 'Name of health check view model should be \'Test Health Check ' + i + '\'');
            System.assertEquals('Test Classname', healthCheckVModel.healthCheckDefinitionList[i].className, 'Classname of health check should be \'Test Classname\'');
            System.assertEquals('TEST', healthCheckVModel.healthCheckDefinitionList[i].namespace, 'Classname of health check should be \'TEST\'');
        }  
    }

    /****************************************************************************************************************************
    * @description Test to verify that getHealthCheckViewModel throws AuraHandledException
    ****************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckViewModelException(){

        FeatureParameterMapper.instance = new STUB_FeatureParameterMapperError();
        HealthCheckDefinitionService.instance = new STUB_HealthCheckDefinitionService();

        try {
            Test.startTest();
                HealthCheckVModel healthCheckVModel = HealthCheckVMapper.getInstance().getHealthCheckViewModel();
            Test.stopTest();
            System.assert(false, 'Should throw an exception');
        } catch (AuraHandledException ex) {
            System.assertEquals('System.AuraHandledException', ex.getTypeName(), 'AuraHandledException should be thrown when exception occurs.');
        } 
    }


    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from FeatureParameterMapper to return a new instance of a FeatureParameterDateModel
    **************************************************************************************************************************************/ 
    private class STUB_FeatureParameterDateModel extends FeatureParameterMapper {
        @TestVisible 
        public override FeatureParameterModel getFeatureParameterModel(String featureParameter){            
            FeatureParameterDateModel featureParamDateMdl = new FeatureParameterDateModel('Test Feature Param', Date.today().addDays(-3));
            return featureParamDateMdl;
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from HealthCheckDefinitionService to return a list of HealthCheckDefinitionVModels
    **************************************************************************************************************************************/ 
    private class STUB_HealthCheckDefinitionService extends HealthCheckDefinitionService {
        @TestVisible
        public override List<HealthCheckDefinitionModel> getHealthCheckDefinitionModels(){
            List<HealthCheckDefinitionModel> healthCheckDefModelsList = new List<HealthCheckDefinitionModel>();

            for (Integer i = 0; i < 10; i++){
                HealthCheckDefinitionModel healthCheckDefModel = new HealthCheckDefinitionModel('Test Health Check ' + i, 'Test Classname', 'TEST');
                healthCheckDefModelsList.add(healthCheckDefModel);
            }

            return healthCheckDefModelsList;
        }
    }
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the exception for FeatureParameterMapper
    **************************************************************************************************************************************/ 
    private class STUB_FeatureParameterMapperError extends FeatureParameterMapper {
        
        @TestVisible
        public override FeatureParameterModel getFeatureParameterModel(String featureParameter){
            TelemetryParameterName telemetryParameterName = FeatureParameterMapper.TelemetryParameterByString.get(featureParameter);
            throw new FeatureParameterMapperException('Feature Parameter ' + String.valueOf(telemetryParameterName) + ' is not defined.');
        }
    }
}