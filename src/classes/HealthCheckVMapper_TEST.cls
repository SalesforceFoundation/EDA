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
    // @isTest
    // private static void locateHealthCheckDefinitionServiceValid() {
    //     Test.startTest();
    //     HealthCheckDefinitionService healthCheckDefService = HealthCheckVMapper.getInstance().locateHealthCheckDefinitionService();
    //     Test.stopTest();

    //     System.assertEquals(HealthCheckDefinitionService.getInstance(), healthCheckDefService, 'Should return the instance of HealthCheckDefinitionService.');
    // }    

    /****************************************************************************************************************************
    * @description Test to verify that updateHealthCheckLastRunDate method return a string representing the current date.
    ****************************************************************************************************************************/
    @isTest 
    private static void updateHealthCheckLastRunDateValid(){

        FeatureParameterMapper.instance = new STUB_FeatureParameterDateModel();

        Test.startTest();
        String lastRunDate = HealthCheckVMapper.getInstance().updateHealthCheckLastRunDate();
        Test.stopTest();

        System.assertEquals(Date.today().addDays(-3).format(), lastRunDate, 'Last run date should be set to 3 days before current date.');
    }

    /****************************************************************************************************************************
    * @description Test to verify that getHealthCheckViewModel method returns a Health Check View Model.
    ****************************************************************************************************************************/
    // @isTest 
    // private static void getHealthCheckViewModelValid(){

    //     FeatureParameterMapper.instance = new STUB_FeatureParameterDateModel();
    //     HealthCheckDefinitionSerivce.instance = new STUB_HealthCheckDefinitionService();

    //     Test.startTest();
    //     HealthCheckVModel healthChkViewMod = HealthCheckVMapper.getInstance().getHealthCheckViewModel();
    //     Test.stopTest();

    //     System.assertEquals(Date.today().addDays(-3).format(), healthChkViewMod.lastRunDate, 'Last run date should be 3 days before current date.');
    //     System.assertEquals(10, healthChkViewMod.numberOfHealthChecks, 'Number of healt checks to run should equal 10.');
    //     System.assertEquals(10, healthChkViewMod.healthCheckDefinitionList.size(), 'There should be 10 health check definition view models.');
     
    //     for (Integer i = 0; i < healthChkViewMod.healthCheckDefinitionList.size(); i++){
    //         System.assertEquals('Test Health Check ' + i, healthChkViewMod.healthCheckDefinitionList[i].name, 'Name of health check view model should be \'Test Health Check ' + i + '\'');
    //         System.assertEquals('Test Classname', healthChkViewMod.healthCheckDefinitionList[i].className, 'Classname of health check should be \'Test Classname\'');
    //         System.assertEquals('TEST', healthChkViewMod.healthCheckDefinitionList[i].namespace, 'Classname of health check should be \'TEST\'');
    //     }  
    // }


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
    // private class STUB_HealthCheckDefinitionService extends HealthCheckDefinitionService {
    //     @TestVisible
    //     public override List<HealthCheckDefinitionVModel> getHealthCheckDefinitionModels(){
    //         List<HealthCheckDefinitionModel> healthChkDefModelsList = new List<HealthCheckDefinitionModel>();

    //         for (Integer i = 0; i < 10; i++){
    //             HealthCheckDefinitionModel healthChkDefMod = new HealthCheckDefinitionModel('Test Health Check ' + i, 'Test Classname', 'TEST');
    //             healthChkDefModelsList.add(healthChkDefMod);
    //         }

    //         return healthChkDefModelsList;
    //     }
    // }
}


