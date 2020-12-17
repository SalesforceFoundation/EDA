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
* @description Test class for HealthCheckController.
*/
@isTest
public with sharing class HealthCheckController_TEST {

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
        HealthCheckVModel hlthCheckVMod = HealthCheckController.getHealthCheckViewModel();
        Test.stopTest();

        System.assertEquals(Date.today().addDays(-1).format(), hlthCheckVMod.lastRunDate, 'Last run date should be one day ago.');
        System.assertEquals(5, hlthCheckVMod.numberOfHealthChecks, 'Should be 5 health checks to run.');
        System.assertEquals(5, hlthCheckVMod.healthCheckDefinitionList.size(), 'Should be 5 health check definitions.');

        for (Integer i = 0; i < hlthCheckVMod.healthCheckDefinitionList.size(); i++){
            System.assertEquals('Test Name ' + i, hlthCheckVMod.healthCheckDefinitionList[i].name, 'Name of Health Check Definition view model should be \'Test Name ' + i + '\'');
            System.assertEquals('TestClass', hlthCheckVMod.healthCheckDefinitionList[i].className, 'Classname of Health Check Definition view model should be \'TestClass\'');
            System.assertEquals('TEST', hlthCheckVMod.healthCheckDefinitionList[i].namespace, 'Namespace of Health Check Definition view model should be \'TEST\'');
        }
    }

    /****************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckViewModel method throws an exception when expected.
    ****************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckViewModelException(){
        HealthCheckVMapper.instance = new STUB_ExceptionHealthCheckVMapper();

        Test.startTest();
        try{
            HealthCheckVModel hlthCheckVMod = HealthCheckController.getHealthCheckViewModel();
        } catch (System.AuraHandledException ex){
            System.assertEquals('System.AuraHandledException', ex.getTypeName(), 'AuraHandledException should be thrown when exception occurs.');
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'AuraHandledException text should be associated with message when exception occurs.');
        }
        Test.stopTest();
    }

    /****************************************************************************************************************************
    * @description Test method to verify that the updateHealthCheckLastRunDate method returns today's date.
    ****************************************************************************************************************************/
    @isTest 
    private static void updateHealthCheckLastRunDate(){
        
        Test.startTest();
            String lastRunDate = HealthCheckController.updateHealthCheckLastRunDate();
        Test.stopTest();
        
        System.assertEquals(Date.today().format(), lastRunDate, 'Last Run date should be today\'s');
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
            List<HealthCheckDefinitionVModel> healthChkDefViewModelsList = new List<HealthCheckDefinitionVModel>();

            for (Integer i = 0; i < 5; i++){
                HealthCheckDefinitionVModel hthChkDefVMod = new HealthCheckDefinitionVModel('Test Name ' + i, 'TestClass', 'TEST');
                healthChkDefViewModelsList.add(hthChkDefVMod);
            }

            return new HealthCheckVModel(Date.today().addDays(-1).format(), healthChkDefViewModelsList.size(), healthChkDefViewModelsList);
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

    public class TestException extends Exception {}
}
