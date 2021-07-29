/*
    Copyright (c) 2021, Salesforce.org
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
 * @date 2021
 * @group
 * @group-content
 * @description Test class for EDCSettingsProductAPIService
 */
@isTest
private class EDCSettingsProductAPIService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * EDCSettingsProductAPIService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        EDCSettingsProductAPIService serviceInstance = EDCSettingsProductAPIService.getInstance();
        Test.stopTest();

        System.assertEquals(
            EDCSettingsProductAPIService.instance,
            serviceInstance,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(true, serviceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * EDCSettingsProductAPIService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        EDCSettingsProductAPIService serviceInstance1 = EDCSettingsProductAPIService.getInstance();
        Test.startTest();
        EDCSettingsProductAPIService serviceInstance2 = EDCSettingsProductAPIService.getInstance();
        Test.stopTest();

        System.assertEquals(
            EDCSettingsProductAPIService.instance,
            serviceInstance1,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(
            serviceInstance1,
            serviceInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );
        System.assertEquals(true, serviceInstance2 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify the getSettingsProductInformation method returns the instance
     * of EDCSettingsProdInfoActionResultModel correctly
     ***************************************************************************************************************************/
    @isTest
    private static void testGetSettingsProductInformation() {
        String classname = 'EDASettingsProductInformationAPIService';
        String namespace = 'hed';
        Decimal apiVersion = 52.0;
        String initials = 'testInitials';
        String name = 'testName';
        String description = 'testDescription';
        String settingsComponent = 'testSettingsComponent';
        String documentationUrl = 'testDocumentationUrl';
        String trailheadUrl = 'testTrailheadUrl';
        String icon = 'testIcon';

        EDCSettingsProductAPIService.instance = new EDCSettingsProductAPIServiceStub();
        EDCSettingsProdInfoActionResultModel actionResult;

        Test.startTest();
        actionResult = EDCSettingsProductAPIService.getInstance()
            .getSettingsProductInformation(classname, namespace, apiVersion);
        Test.stopTest();

        System.assertEquals(true, actionResult.success, 'success should be true');
        System.assertEquals(null, actionResult.error, 'error should be null');
        System.assertNotEquals(null, actionResult.result, 'result should not be null');

        EDCSettingsProductInformationModel product = actionResult.result;
        System.assertEquals(initials, product.initials, 'initials should be set to ' + initials);
        System.assertEquals(name, product.name, 'name should be set to ' + name);
        System.assertEquals(description, product.description, 'description should be set to ' + description);
        System.assertEquals(
            settingsComponent,
            product.settingsComponent,
            'settingsComponent should be set to ' + settingsComponent
        );
        System.assertEquals(
            documentationUrl,
            product.documentationUrl,
            'documentationUrl should be set to ' + documentationUrl
        );
        System.assertEquals(trailheadUrl, product.trailheadUrl, 'trailheadUrl should be set to ' + trailheadUrl);
        System.assertEquals(icon, product.icon, 'icon should be set to ' + icon);
    }

    /**************************************************************************************************************************
     * @description Test method to verify a callable class is found when a valid classname is provided.
     ***************************************************************************************************************************/
    @isTest
    private static void testExceptionLocateSettingsProductInfoApiService() {
        String classname = 'EDASettingsProductInformationAPIService';
        String namespace = 'hed';
        Callable edaCallable;

        Test.startTest();
        edaCallable = EDCSettingsProductAPIService.getInstance()
            .locateSettingsProductInformationAPIService(classname, namespace);
        Test.stopTest();

        System.assertNotEquals(null, edaCallable, 'The callable should not be appropriately instantiated.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify a EDCSettingsProductApiService.SettingsProductNotFoundException is thrown when an invalid
     * classname has been provided, or the class could not get instantiated correctly.
     ***************************************************************************************************************************/
    @isTest
    private static void testExceptionLocateSettingsProductInfoApiServiceNonExistence() {
        String classname = 'ABadClass';
        String namespace = 'hed';
        Callable edaCallable;
        String exceptionMessage;

        try {
            Test.startTest();
            edaCallable = EDCSettingsProductAPIService.getInstance()
                .locateSettingsProductInformationAPIService(classname, namespace);
            Test.stopTest();
            System.assert(true, 'this should not happen');
        } catch (EDCSettingsProductApiService.SettingsProductNotFoundException e) {
            exceptionMessage = e.getMessage();
        }
        System.assertNotEquals(null, exceptionMessage, 'exception message should not be null');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the behavior for providing a noncallable class is respected
     ***************************************************************************************************************************/
    @isTest
    private static void testExceptionLocateSettingsProductInfoApiServiceNotCallable() {
        String classname = 'EDCSettingsProductAPIService';
        String namespace = 'hed';
        Callable edaCallable;
        String exceptionMessage;

        try {
            Test.startTest();
            edaCallable = EDCSettingsProductAPIService.getInstance()
                .locateSettingsProductInformationAPIService(classname, namespace);
            Test.stopTest();
            System.assert(true, 'this should not happen');
        } catch (EDCSettingsProductApiService.SettingsProductNotFoundException e) {
            exceptionMessage = e.getMessage();
        }

        System.assertNotEquals(null, exceptionMessage, 'exception message should not be null');
    }

    /**************************************************************************************************************************
     * @description Test method to comply test coverage because of with the lines not touched because of our mocked classes
     ***************************************************************************************************************************/
    @isTest
    private static void testMakeCallForCoverage() {
        String settingsInformationJSON;
        String classname = 'EDASettingsProductInformationAPIService';
        Decimal apiVersion = 52.0;
        Map<String, Object> args = new Map<String, Object>{ 'Api Version' => apiVersion };

        Type settingsProductInformationAPIServiceType = Type.forName('', classname);
        Callable settingsProductInformationAPIService = (Callable) settingsProductInformationAPIServiceType.newInstance();

        Test.startTest();
        settingsInformationJSON = EDCSettingsProductAPIService.getInstance()
            .makeCall(settingsProductInformationAPIService, apiVersion);
        Test.stopTest();

        EDCSettingsProdInfoActionResultModel actionResult = (EDCSettingsProdInfoActionResultModel) JSON.deserialize(
            settingsInformationJSON,
            EDCSettingsProdInfoActionResultModel.class
        );

        System.assertEquals(true, actionResult.success, 'success should be true');
        System.assertEquals(null, actionResult.error, 'error should be null');
        System.assertNotEquals(null, actionResult.result, 'result should not be null');
    }

    /**************************************************************************************************************************
     * @description Stub class for EDCSettingsProductAPIService returning some
     * EDCSettingsProdInfoActionResultModel sample data
     ***************************************************************************************************************************/
    private class EDCSettingsProductAPIServiceStub extends EDCSettingsProductAPIService {
        private override String makeCall(Callable settingsProductInformationAPIService, Decimal apiVersion) {
            EDCSettingsProductInformationModel productInformation = new EDCSettingsProductInformationModel(
                'testInitials',
                'testName',
                'testDescription',
                'testSettingsComponent',
                'testDocumentationUrl',
                'testTrailheadUrl',
                'testIcon'
            );
            EDCSettingsProdInfoActionResultModel actionResult = new EDCSettingsProdInfoActionResultModel(
                productInformation,
                true,
                null
            );
            return JSON.serialize(actionResult);
        }
    }
}
