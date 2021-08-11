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
 * @description Test class for ApplicationSettingsMapper class.
 */
@isTest
private with sharing class ApplicationSettingsMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ApplicationSettingsMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ApplicationSettingsMapper applicationSettingsMapperInstance = ApplicationSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ApplicationSettingsMapper.instance,
            applicationSettingsMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            applicationSettingsMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ApplicationSettingsMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ApplicationSettingsMapper applicationSettingsMapperInstance1 = ApplicationSettingsMapper.getInstance();
        ApplicationSettingsMapper applicationSettingsMapperInstance2 = ApplicationSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ApplicationSettingsMapper.instance,
            applicationSettingsMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            applicationSettingsMapperInstance1,
            applicationSettingsMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            applicationSettingsMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getApplicationSettingsModel method returns a ApplicationSettingsModel
     * with all properties set to match the corresponding values in hierarchy settings.
     ***************************************************************************************************************************/
    @isTest
    private static void getApplicationSettingsModel() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Application_Window_Validation__c = true)
        );
        ApplicationSettingsMapper applicationSettingsMapperInstance = ApplicationSettingsMapper.getInstance();

        Test.startTest();
        ApplicationSettingsModel applicationSettingsModelInstance = applicationSettingsMapperInstance.getApplicationSettingsModel();
        Test.stopTest();

        System.assertEquals(
            true,
            applicationSettingsModelInstance.applicationWindowValidation,
            'True value for hierarchy setting Application_Window_Validation__c should set in the model'
        );
    }
}
