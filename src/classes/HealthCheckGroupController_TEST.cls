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
* @description Test class for HealthCheckGroupController.
*/
@isTest 
public with sharing class HealthCheckGroupController_TEST {
    /****************************************************************************************************************************
    * @description Test method to verify that the locateHealthCheckGroupService method returns instance of HealthCheckGroupService.
    ****************************************************************************************************************************/
    @isTest
    private static void locateHealthCheckGroupServiceValid() {
        Test.startTest();
            HealthCheckGroupService healthCheckGroupServiceInstance = HealthCheckGroupController.locateHealthCheckGroupService();
        Test.stopTest();

        System.assertEquals(HealthCheckGroupService.getInstance(), healthCheckGroupServiceInstance, 'Should return the instance of HealthCheckGroupService.');
    } 

    /****************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckGroupViewModel method returns a valid HealthCheckGroupVModel.
    ****************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckGroupViewModelValid(){
        HealthCheckGroupService.instance = new STUB_HealthCheckGroupServiceMixedBag();

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = HealthCheckGroupController.getHealthCheckGroupViewModel('Mixed Bag', 'TestClassName', 'abc');
        Test.stopTest();

        System.assertEquals('Mixed Bag', healthCheckGroupVModel.label, 'Label should \'Mixed Bag\'.');
        System.assertEquals('Fail', healthCheckGroupVModel.status, 'Status should be \'Fail\'.');
        System.assertEquals(5, healthCheckGroupVModel.passedChecks, 'Should be 5 health check definitions.');
        System.assertEquals(10, healthCheckGroupVModel.totalChecks, 'Should be 5 health check definitions.');
        System.assertEquals(true, healthCheckGroupVModel.expandedRowsList.isEmpty(), 'expandedRowsList should be empty.');
        System.assertEquals(true, healthCheckGroupVModel.healthCheckItemList.isEmpty(), 'healthCheckItemList should be empty.');
    }

    /****************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckGroupViewModel method throws an exception when expected.
    ****************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckGroupViewModelException(){
        HealthCheckGroupService.instance = new STUB_ExceptionHealthCheckGroupService();

        try{
            Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel = HealthCheckGroupController.getHealthCheckGroupViewModel('Exception Bag', 'TestClassName', 'abc');
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
    * @description Stub class to simulate the response from HealthCheckGroupService to return a HealthCheckGroupVModel
    **************************************************************************************************************************************/ 
    private class STUB_HealthCheckGroupServiceMixedBag extends HealthCheckGroupService {
        @TestVisible 
        public override HealthCheckGroupVModel getHealthCheckGroup(String name, String className, String namespace){   
            return new HealthCheckGroupVModel('Mixed Bag', 'Fail', 5, 10, new List<String>(), new List<HealthCheckItemVModel>());
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from HealthCheckGroupService to throw an exception
    **************************************************************************************************************************************/ 
    private class STUB_ExceptionHealthCheckGroupService extends HealthCheckGroupService {
        @TestVisible 
        public override HealthCheckGroupVModel getHealthCheckGroup(String name, String className, String namespace){   
            throw new TestException('Test exception thrown!');
        }
    }

    /**************************************************************************************
    * @description Custom exception class for testing.
    **************************************************************************************/
    public class TestException extends Exception {}
}
