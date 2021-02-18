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
* @description Test class for HealthCheckVModel class
*/
@isTest 
public with sharing class HealthCheckVModel_TEST {
    /****************************************************************************************************************************
    * @description Test to verify constructor with 3 parameters initializes object with properties set as expected.
    ****************************************************************************************************************************/
    @isTest 
    private static void threeParamConstructorValid(){
        List<HealthCheckDefinitionVModel> healthCheckDefinitionList = new List<HealthCheckDefinitionVModel>();

        for (Integer i=0; i<5; i++){
            HealthCheckDefinitionVModel healthCheckDefinitionVModel = new HealthCheckDefinitionVModel('Test ' + i, 'TestClass', 'TEST');
            healthCheckDefinitionList.add(healthCheckDefinitionVModel);
        }

        Test.startTest();
        HealthCheckVModel healthCheckVModel = new HealthCheckVModel(Date.today().format(), healthCheckDefinitionList.size(), healthCheckDefinitionList);
        Test.stopTest();

        System.assertEquals(Date.today().format(), healthCheckVModel.lastRunDate, 'Last run date should be today.');
        System.assertEquals(5, healthCheckVModel.numberOfHealthChecks, 'Number of health checks to run should be 5.');

        for (Integer i = 0; i < healthCheckVModel.healthCheckDefinitionList.size(); i++){
            System.assertEquals('Test ' + i, healthCheckVModel.healthCheckDefinitionList[i].name, 'View model name should be \'Test ' + i + '\'.');
        }
    }

}
