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
* @description Test class for HealthCheckController.
*/
@isTest
private class HealthCheckController_TEST {

    /****************************************************************************************************************************
    * @description Test method to verify that the locateHealthCheckMapper method returns instance of HealthCheckVMapper.
    ****************************************************************************************************************************/
    @isTest
    private static void locateHealthCheckMapperValid() {
        Test.startTest();
            HealthCheckVMapper healthChkVMapperInstance = HealthCheckController.locateHealthCheckMapper();
        Test.stopTest();

        System.assertEquals(HealthCheckVMapper.getInstance(), healthChkVMapperInstance, 'Should return the instance of HealthCheckVMapper.');
    } 

    /****************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckViewModel method returns a valid health check view model.
    ****************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckViewModelValid(){
        HealthCheckVMapper.instance = new STUB_HealthCheckVMapper();

        Test.startTest();
        HealthCheckVModel healthCheckVModel = HealthCheckController.getHealthCheckViewModel();
        Test.stopTest();

        System.assertEquals(Date.today().addDays(-1).format(), healthCheckVModel.lastRunDate, 'Last run date should be one day ago.');
        System.assertEquals(5, healthCheckVModel.numberOfHealthChecks, 'Should be 5 health checks to run.');
        System.assertEquals(5, healthCheckVModel.healthCheckDefinitionList.size(), 'Should be 5 health check definitions.');

        for (Integer i = 0; i < healthCheckVModel.healthCheckDefinitionList.size(); i++){
            System.assertEquals('Test Name ' + i, healthCheckVModel.healthCheckDefinitionList[i].name, 'Name of Health Check Definition view model should be \'Test Name ' + i + '\'');
            System.assertEquals('TestClass', healthCheckVModel.healthCheckDefinitionList[i].className, 'Classname of Health Check Definition view model should be \'TestClass\'');
            System.assertEquals('TEST', healthCheckVModel.healthCheckDefinitionList[i].namespace, 'Namespace of Health Check Definition view model should be \'TEST\'');
        }
    }

    /****************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckViewModel method throws an exception when expected.
    ****************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckViewModelException(){
        HealthCheckVMapper.instance = new STUB_ExceptionHealthCheckVMapper();

        try {
            Test.startTest();
                HealthCheckVModel healthCheckVModel = HealthCheckController.getHealthCheckViewModel();
            Test.stopTest();
        } catch (System.AuraHandledException ex){
            System.assertEquals('System.AuraHandledException', ex.getTypeName(), 'AuraHandledException should be thrown when exception occurs.');
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'AuraHandledException text should be associated with message when exception occurs.');
        }
    }

    /****************************************************************************************************************************
    * @description Test method to verify that the updateHealthCheckLastRunDate method returns today's date.
    ****************************************************************************************************************************/
    @isTest 
    private static void updateHealthCheckLastRunDate(){
        FeatureParameterService.instance = new STUB_FeatureParameterService();

        Test.startTest();
            String lastRunDate = HealthCheckController.updateHealthCheckLastRunDate();
        Test.stopTest();

        System.assertEquals(Date.today().format(), lastRunDate, 'Last Run date should be today\'s');
    }

    /****************************************************************************************************************************
    * @description Test method to verify that the updateHealthCheckLastRunDate method throws an exception when expected.
    ****************************************************************************************************************************/
    @isTest 
    private static void updateHealthCheckLastRunDateException(){
        FeatureParameterMapper.instance = new STUB_ExceptionFeatureParameterMapper();

        try {
            Test.startTest();
            String lastRunDate = HealthCheckController.updateHealthCheckLastRunDate();
            Test.stopTest();
        } catch (System.AuraHandledException ex){
            System.assertEquals('System.AuraHandledException', ex.getTypeName(), 'AuraHandledException should be thrown when exception occurs.');
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'AuraHandledException text should be associated with message when exception occurs.');
        }
    }

    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from HealthCheckVMapper to return a HealthCheckVModel
    **************************************************************************************************************************************/ 
    private class STUB_HealthCheckVMapper extends HealthCheckVMapper {
        @TestVisible 
        public override HealthCheckVModel getHealthCheckViewModel(){            
            List<HealthCheckDefinitionVModel> healthCheckDefinitionVModelsList = new List<HealthCheckDefinitionVModel>();

            for (Integer i = 0; i < 5; i++){
                HealthCheckDefinitionVModel hthChkDefVMod = new HealthCheckDefinitionVModel('Test Name ' + i, 'TestClass', 'TEST');
                healthCheckDefinitionVModelsList.add(hthChkDefVMod);
            }

            return new HealthCheckVModel(Date.today().addDays(-1).format(), healthCheckDefinitionVModelsList.size(), healthCheckDefinitionVModelsList);
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from HealthCheckVMapper to throw an exception
    **************************************************************************************************************************************/ 
    private class STUB_ExceptionHealthCheckVMapper extends HealthCheckVMapper {
        @TestVisible 
        public override HealthCheckVModel getHealthCheckViewModel(){            
            throw new TestException('Test exception thrown!');
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from FeatureParameterMapper to throw an exception
    **************************************************************************************************************************************/ 
    private class STUB_ExceptionFeatureParameterMapper extends FeatureParameterMapper {
        @TestVisible 
        public override void updateFromFeatureParameterModel(FeatureParameterModel featureParamModel) {
            throw new TestException('Test exception thrown!');
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from FeatureParameterSerivce class to return models and update from models
    **************************************************************************************************************************************/ 
    private class STUB_FeatureParameterService extends FeatureParameterService {

        @TestVisible 
        public override void updateFromFeatureParameterModel(FeatureParameterModel featureParamModel) {
            UTIL_FeatureManagement featureManager = new UTIL_FeatureManagement();
            featureManager.setPackageDateValue('SettingsHealthCheckLastRunDate',  Date.today());
        }

        @TestVisible 
        public override FeatureParameterModel getFeatureParameterModel(String featureParamModel) {            
            FeatureParameterDateModel featureParamDateMdl = new FeatureParameterDateModel('SettingsHealthCheckLastRunDate', Date.today());
            return featureParamDateMdl;
        }
    }

    /**************************************************************************************
    * @description Custom exception class for testing.
    **************************************************************************************/
    public class TestException extends Exception {}
}