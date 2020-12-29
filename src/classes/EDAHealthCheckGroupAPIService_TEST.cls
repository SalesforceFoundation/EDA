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
* @description Test class for EDAHealthCheckGroupAPIService.
*/
@isTest 
public with sharing class EDAHealthCheckGroupAPIService_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * EDAHealthCheckGroupAPIService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        HealthCheckGroupAPIServiceInterface EDAHealthCheckGroupAPIServiceInstance = EDAHealthCheckGroupAPIService.getInstance();
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
        HealthCheckGroupAPIServiceInterface EDAHealthCheckGroupAPIServiceInstance1 = EDAHealthCheckGroupAPIService.getInstance();
        HealthCheckGroupAPIServiceInterface EDAHealthCheckGroupAPIServiceInstance2 = EDAHealthCheckGroupAPIService.getInstance();
        Test.stopTest();

        System.assertEquals(EDAHealthCheckGroupAPIService.instance, EDAHealthCheckGroupAPIServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(EDAHealthCheckGroupAPIServiceInstance1, EDAHealthCheckGroupAPIServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, EDAHealthCheckGroupAPIServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckGroup method returns a valid HealthCheckGroupVModel when the 
    * name of a valid HealthCheckDefinitionModel is provided (case insensitive).
    ***************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckGroupValid(){
        Test.startTest();
        HealthCheckGroupVModel hlthChkGrpVMod = EDAHealthCheckGroupAPIService.getInstance().getHealthCheckGroup('mIXEd');
        Test.stopTest();

        System.assertEquals('Mixed', hlthChkGrpVMod.label, 'Label for HealthCheckGroupVModel should be \'Mixed\'');
        System.assertEquals('Fail', hlthChkGrpVMod.status, 'Status for HealthCheckGroupVModel should be \'Fail\'');
        System.assertEquals(2, hlthChkGrpVMod.passedChecks, 'PassedChecks for HealthCheckGroupVModel should be 2.');
        System.assertEquals(4, hlthChkGrpVMod.totalChecks, 'TotalChecks for HealthCheckGroupVModel should be 4.');
        System.assertEquals(1, hlthChkGrpVMod.expandedRowsList.size(), 'ExpandedRowsList should contain 1 value.');
        System.assertEquals('01', hlthChkGrpVMod.expandedRowsList[0], 'ExpandedRowsList should contain 1 value.');
        System.assertEquals(2, hlthChkGrpVMod.healthCheckItemList.size(), 'HealthCheckItemList should contain 2 values.');

        for (HealthCheckItemVModel hlthChkItmVMod : hlthChkGrpVMod.healthCheckItemList){
            System.assertEquals(2, hlthChkItmVMod.healthCheckItemList.size(), 'Each HealthCheckItemVModel should contain 2 nested items.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getHealthCheckGroup method returns null when an invalid name for a 
    * HealthCheckDefinitionModel is provided (case insensitive).
    ***************************************************************************************************************************/
    @isTest 
    private static void getHealthCheckGroupInValid(){
        Test.startTest();
        HealthCheckGroupVModel hlthChkGrpVMod = EDAHealthCheckGroupAPIService.getInstance().getHealthCheckGroup('Not a Valid Health Check Definition Model Name');
        Test.stopTest();

       System.assertEquals(null, hlthChkGrpVMod, 'Value returned should be null.');
    }
}
