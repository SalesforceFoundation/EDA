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
* @description Test class for HealthCheckDefinitionVModel.
*/
@isTest 
public with sharing class HealthCheckDefinitionVModel_TEST {

    /****************************************************************************************************************************
    * @description Test to verify constructor with 3 parameters initializes object with properties set as expected.
    ****************************************************************************************************************************/
    @isTest 
    private static void threeParamConstructorValid(){
        Test.startTest();
        HealthCheckDefinitionVModel hlthChkDefVModl = new HealthCheckDefinitionVModel('TestName', 'TestClass', 'TEST');
        Test.stopTest();

        System.assertEquals('TestName', hlthChkDefVModl.name, 'Name property should be \'TestName\'.');
        System.assertEquals('TestClass', hlthChkDefVModl.className, 'Classname property should be \'TestClass\'.');
        System.assertEquals('TEST', hlthChkDefVModl.namespace, 'Namespace property should be \'TEST\'.');
    }

    /****************************************************************************************************************************
    * @description Test to verify compareTo() properly sorts Health Check View models by name
    * in ascending order when no duplicates are not present.
    ****************************************************************************************************************************/
    @isTest 
    private static void sortNamesWithoutDuplicates(){
        List<HealthCheckDefinitionVModel> healthCheckDefinitionVModelsList = new List<HealthCheckDefinitionVModel>();
        HealthCheckDefinitionVModel healthCheckDefinitionVModel1 = new HealthCheckDefinitionVModel('test1', 'TestClass', 'TEST');
        HealthCheckDefinitionVModel healthCheckDefinitionVModel2 = new HealthCheckDefinitionVModel('pineapple', 'TestClass', 'TEST');
        HealthCheckDefinitionVModel healthCheckDefinitionVModel3 = new HealthCheckDefinitionVModel('Banana', 'TestClass', 'TEST');
        HealthCheckDefinitionVModel healthCheckDefinitionVModel4 = new HealthCheckDefinitionVModel('Test4', 'TestClass', 'TEST');
        HealthCheckDefinitionVModel healthCheckDefinitionVModel5 = new HealthCheckDefinitionVModel('Papaya', 'TestClass', 'TEST');
        HealthCheckDefinitionVModel healthCheckDefinitionVModel6 = new HealthCheckDefinitionVModel('Apple', 'TestClass', 'TEST');
        
        healthCheckDefinitionVModelsList.add(healthCheckDefinitionVModel1);
        healthCheckDefinitionVModelsList.add(healthCheckDefinitionVModel2);
        healthCheckDefinitionVModelsList.add(healthCheckDefinitionVModel3);
        healthCheckDefinitionVModelsList.add(healthCheckDefinitionVModel4);
        healthCheckDefinitionVModelsList.add(healthCheckDefinitionVModel5);
        healthCheckDefinitionVModelsList.add(healthCheckDefinitionVModel6);
    
        Test.startTest();
        healthCheckDefinitionVModelsList.sort();
        Test.stopTest();

        System.assertEquals('Apple', healthCheckDefinitionVModelsList[0].name, 'First name in sorted list should be \'Apple\'');
        System.assertEquals('Banana', healthCheckDefinitionVModelsList[1].name, 'Second name in sorted list should be \'Banana\'');
        System.assertEquals('Papaya', healthCheckDefinitionVModelsList[2].name, 'Third name in sorted list should be \'Papaya\'');
        System.assertEquals('pineapple', healthCheckDefinitionVModelsList[3].name, 'Fourth name in sorted list should be \'pineapple\'');
        System.assertEquals('test1', healthCheckDefinitionVModelsList[4].name, 'Fifth name in sorted list should be \'test1\'');
        System.assertEquals('Test4', healthCheckDefinitionVModelsList[5].name, 'Sixth name in sorted list should be \'Test4\'');
    }

    /****************************************************************************************************************************
    * @description Test to verify compareTo() properly sorts Health Check View models by name
    * in ascending order when no duplicates are present.
    ****************************************************************************************************************************/
    @isTest 
    private static void sortNamesWithDuplicates(){
        List<HealthCheckDefinitionVModel> healthCheckDefinitionVModelsList = new List<HealthCheckDefinitionVModel>();
        HealthCheckDefinitionVModel healthCheckDefinitionVModel1 = new HealthCheckDefinitionVModel('Pineapple', 'TestClass', 'TEST');
        HealthCheckDefinitionVModel healthCheckDefinitionVModel2 = new HealthCheckDefinitionVModel('Pineapple', 'TestClass', 'TEST');
        HealthCheckDefinitionVModel healthCheckDefinitionVModel3 = new HealthCheckDefinitionVModel('Pineapple', 'TestClass', 'TEST');
        HealthCheckDefinitionVModel healthCheckDefinitionVModel4 = new HealthCheckDefinitionVModel('test4', 'TestClass', 'TEST');
        HealthCheckDefinitionVModel healthCheckDefinitionVModel5 = new HealthCheckDefinitionVModel('123Papaya', 'TestClass', 'TEST');
        HealthCheckDefinitionVModel healthCheckDefinitionVModel6 = new HealthCheckDefinitionVModel('Apple Pie', 'TestClass', 'TEST');
        
        healthCheckDefinitionVModelsList.add(healthCheckDefinitionVModel1);
        healthCheckDefinitionVModelsList.add(healthCheckDefinitionVModel2);
        healthCheckDefinitionVModelsList.add(healthCheckDefinitionVModel3);
        healthCheckDefinitionVModelsList.add(healthCheckDefinitionVModel4);
        healthCheckDefinitionVModelsList.add(healthCheckDefinitionVModel5);
        healthCheckDefinitionVModelsList.add(healthCheckDefinitionVModel6);
    
        Test.startTest();
        healthCheckDefinitionVModelsList.sort();
        Test.stopTest();

        System.assertEquals('123Papaya', healthCheckDefinitionVModelsList[0].name, 'First name in sorted list should be \'123Papaya\'');
        System.assertEquals('Apple Pie', healthCheckDefinitionVModelsList[1].name, 'Second name in sorted list should be \'Apple Pie\'');
        System.assertEquals('Pineapple', healthCheckDefinitionVModelsList[2].name, 'Third name in sorted list should be \'Pineapple\'');
        System.assertEquals('Pineapple', healthCheckDefinitionVModelsList[3].name, 'Fourth name in sorted list should be \'Pineapple\'');
        System.assertEquals('Pineapple', healthCheckDefinitionVModelsList[4].name, 'Fifth name in sorted list should be \'Pineapple\'');
        System.assertEquals('test4', healthCheckDefinitionVModelsList[5].name, 'Sixth name in sorted list should be \'test4\'');
    }
}
