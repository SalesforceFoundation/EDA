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
 * @description Test class for EDASettingsProductInformationAPIService
 */
@isTest
private class EDASettingsProductInfoAPIService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify the call method of EDASettingsProductInformationAPIService
     * returns the EDCSettingsProdInfoActionResultModel instance correctly
     ***************************************************************************************************************************/
    @isTest
    private static void testCallable() {
        String settingsInformationJSON;
        String classname = 'EDASettingsProductInformationAPIService';
        String action = 'Settings Product Information';
        Decimal apiVersion = 52.0;
        String initials = 'testInitials';
        String name = 'testName';
        String description = 'testDescription';
        String settingsComponent = 'testSettingsComponent';
        String settingsButtonA11y = 'testSettingsButtonA11y';
        String documentationUrl = 'testDocumentationUrl';
        String documentationButtonA11y = 'testDocumentationButtonA11y';
        String trailheadUrl = 'testTrailheadUrl';
        String trailheadButtonA11y = 'testTrailheadButtonA11y';
        String icon = 'testIcon';
        Map<String, Object> args = new Map<String, Object>{ 'Api Version' => apiVersion };

        EDCSettingsProductInformationMapper.instance = new EDCSettingsProductInformationMapperStub();
        Type settingsProductInformationAPIServiceType = Type.forName('', classname);
        Callable settingsProductInformationAPIService = (Callable) settingsProductInformationAPIServiceType.newInstance();

        Test.startTest();
        settingsInformationJSON = (String) settingsProductInformationAPIService.call(action, args);
        Test.stopTest();

        EDCSettingsProdInfoActionResultModel actionResult = (EDCSettingsProdInfoActionResultModel) JSON.deserialize(
            settingsInformationJSON,
            EDCSettingsProdInfoActionResultModel.class
        );

        System.assertEquals(true, actionResult.success, 'success should be true');
        System.assertEquals(null, actionResult.error, 'error should be null');
        System.assertNotEquals(null, actionResult.result, 'result should not be null');

        EDCSettingsProductInformationModel product = actionResult.result;
        System.assertEquals(description, product.description, 'description should be set to ' + description);
        System.assertEquals(initials, product.initials, 'initials should be set to ' + initials);
        System.assertEquals(name, product.name, 'name should be set to ' + name);
        System.assertEquals(
            settingsComponent,
            product.settingsComponent,
            'settingsComponent should be set to ' + settingsComponent
        );
        System.assertEquals(
            settingsButtonA11y,
            product.settingsButtonA11y,
            'settingsButtonA11y should be set to ' + settingsButtonA11y
        );
        System.assertEquals(
            documentationUrl,
            product.documentationUrl,
            'documentationUrl should be set to ' + documentationUrl
        );
        System.assertEquals(
            documentationButtonA11y,
            product.documentationButtonA11y,
            'documentationButtonA11y should be set to ' + documentationButtonA11y
        );
        System.assertEquals(trailheadUrl, product.trailheadUrl, 'trailheadUrl should be set to ' + trailheadUrl);
        System.assertEquals(
            trailheadButtonA11y,
            product.trailheadButtonA11y,
            'trailheadButtonA11y should be set to ' + trailheadButtonA11y
        );
        System.assertEquals(icon, product.icon, 'icon should be set to ' + icon);
    }

    /**************************************************************************************************************************
     * @description Test method to verify an instance of EDCSettingsProdInfoActionResultModel
     * is returned with the success property set to false and the error property populated, when the provided Action is incorrect
     ***************************************************************************************************************************/
    @isTest
    private static void testCallableWrongAction() {
        String settingsInformationJSON;
        String classname = 'EDASettingsProductInformationAPIService';
        String action = 'Edit Info';
        Decimal apiVersion = 52.0;
        Map<String, Object> args = new Map<String, Object>{ 'Api Version' => apiVersion };

        Test.startTest();

        Type settingsProductInformationAPIServiceType = Type.forName('', classname);
        Callable settingsProductInformationAPIService = (Callable) settingsProductInformationAPIServiceType.newInstance();

        settingsInformationJSON = (String) settingsProductInformationAPIService.call(action, args);

        Test.stopTest();

        EDCSettingsProdInfoActionResultModel actionResult = (EDCSettingsProdInfoActionResultModel) JSON.deserialize(
            settingsInformationJSON,
            EDCSettingsProdInfoActionResultModel.class
        );

        System.assertEquals(false, actionResult.success, 'success should be false');
        System.assertEquals(null, actionResult.result, 'result should be null');
        System.assertNotEquals(null, actionResult.error, 'error should not be null');
        System.assertEquals(400, actionResult.error.code, 'error code should be 400');
        System.assertEquals(
            Label.stgErrorSettingsProductInvalidAction,
            actionResult.error.message,
            'the error message is incorrect, it should be: ' + Label.stgErrorSettingsProductInvalidAction
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify an instance of EDCSettingsProdInfoActionResultModel
     * is returned with the success property set to false and the error property populated, when the provided apiVesrion is null
     ***************************************************************************************************************************/
    @isTest
    private static void testCallableNoApiVersion() {
        String settingsInformationJSON;
        String classname = 'EDASettingsProductInformationAPIService';
        String action = 'Settings Product Information';
        Decimal apiVersion;
        Map<String, Object> args = new Map<String, Object>{ 'Api Version' => apiVersion };

        Test.startTest();

        Type settingsProductInformationAPIServiceType = Type.forName('', classname);
        Callable settingsProductInformationAPIService = (Callable) settingsProductInformationAPIServiceType.newInstance();

        settingsInformationJSON = (String) settingsProductInformationAPIService.call(action, args);

        Test.stopTest();

        EDCSettingsProdInfoActionResultModel actionResult = (EDCSettingsProdInfoActionResultModel) JSON.deserialize(
            settingsInformationJSON,
            EDCSettingsProdInfoActionResultModel.class
        );

        System.assertEquals(false, actionResult.success, 'success should be false');
        System.assertEquals(null, actionResult.result, 'result should be null');
        System.assertNotEquals(null, actionResult.error, 'error should not be null');
        System.assertEquals(400, actionResult.error.code, 'error code should be 400');
        System.assertEquals(
            Label.stgErrorSettingsProductInvalidApiVersion,
            actionResult.error.message,
            'the error message is incorrect, it should be: ' + Label.stgErrorSettingsProductInvalidApiVersion
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify an getApiVersion returns a decimal provided as parameter
     ***************************************************************************************************************************/
    @isTest
    private static void testGetApiVersion() {
        Decimal paramApiVersion = 52.0;
        Map<String, Object> args = new Map<String, Object>{ 'Api Version' => paramApiVersion };
        EDASettingsProductInformationAPIService service = new EDASettingsProductInformationAPIService();

        Test.startTest();
        Decimal apiVersion = service.getApiVersion(args);
        Test.stopTest();

        System.assertEquals(paramApiVersion, apiVersion, 'api version should be ' + paramApiVersion);
    }

    /**************************************************************************************************************************
     * @description Test method to assess an scenario when getApiVersion returns a null
     ***************************************************************************************************************************/
    @isTest
    private static void testNullGetApiVersion() {
        Map<String, Object> args = new Map<String, Object>{ 'Api Version' => null };
        EDASettingsProductInformationAPIService service = new EDASettingsProductInformationAPIService();
        String exceptionMessage;

        try {
            Test.startTest();
            Decimal apiVersion = service.getApiVersion(args);
            Test.stopTest();
            System.assert(false, 'this should not happen');
        } catch (EDASettingsProductInformationAPIService.ApiVersionNotFoundException ex) {
            exceptionMessage = ex.getMessage();
        }

        System.assertEquals(
            Label.stgErrorSettingsProductInvalidApiVersion,
            exceptionMessage,
            'the error message is incorrect, it should be: ' + Label.stgErrorSettingsProductInvalidApiVersion
        );
    }

    /**************************************************************************************************************************
     * @description Test method to assess an scenario when handleAction returns a valid EDCSettingsProdInfoActionResultModel
     ***************************************************************************************************************************/
    @isTest
    private static void testGoodCaseHandleAction() {
        String action = EDASettingsProductInformationAPIService.PRODUCT_INFORMATION_ACTION;
        Decimal apiVersion = 52.0;
        String initials = 'testInitials';
        String name = 'testName';
        String description = 'testDescription';
        String settingsComponent = 'testSettingsComponent';
        String settingsButtonA11y = 'testSettingsButtonA11y';
        String documentationUrl = 'testDocumentationUrl';
        String documentationButtonA11y = 'testDocumentationButtonA11y';
        String trailheadUrl = 'testTrailheadUrl';
        String trailheadButtonA11y = 'testTrailheadButtonA11y';
        String icon = 'testIcon';

        EDCSettingsProductInformationMapper.instance = new EDCSettingsProductInformationMapperStub();
        EDASettingsProductInformationAPIService service = new EDASettingsProductInformationAPIService();
        EDCSettingsProdInfoActionResultModel actionResult;

        try {
            Test.startTest();
            actionResult = service.handleAction(action, apiVersion);
            Test.stopTest();
        } catch (EDASettingsProductInformationAPIService.InvalidActionException ex) {
            System.assert(false, 'this should not happen');
        }

        System.assertEquals(true, actionResult.success, 'success should be true');
        System.assertEquals(null, actionResult.error, 'error should be null');
        System.assertNotEquals(null, actionResult.result, 'result should not be null');

        EDCSettingsProductInformationModel product = actionResult.result;
        System.assertEquals(description, product.description, 'description should be set to ' + description);
        System.assertEquals(initials, product.initials, 'initials should be set to ' + initials);
        System.assertEquals(name, product.name, 'name should be set to ' + name);
        System.assertEquals(
            settingsComponent,
            product.settingsComponent,
            'settingsComponent should be set to ' + settingsComponent
        );
        System.assertEquals(
            settingsButtonA11y,
            product.settingsButtonA11y,
            'settingsButtonA11y should be set to ' + settingsButtonA11y
        );
        System.assertEquals(
            documentationUrl,
            product.documentationUrl,
            'documentationUrl should be set to ' + documentationUrl
        );
        System.assertEquals(
            documentationButtonA11y,
            product.documentationButtonA11y,
            'documentationButtonA11y should be set to ' + documentationButtonA11y
        );
        System.assertEquals(trailheadUrl, product.trailheadUrl, 'trailheadUrl should be set to ' + trailheadUrl);
        System.assertEquals(
            trailheadButtonA11y,
            product.trailheadButtonA11y,
            'trailheadButtonA11y should be set to ' + trailheadButtonA11y
        );
        System.assertEquals(icon, product.icon, 'icon should be set to ' + icon);
    }

    /**************************************************************************************************************************
     * @description Test method to assess an scenario when handleAction throws an exception
     ***************************************************************************************************************************/
    @isTest
    private static void testExceptionHandleAction() {
        String action = 'a bad action';
        Decimal apiVersion = 52.0;

        EDASettingsProductInformationAPIService service = new EDASettingsProductInformationAPIService();
        String exceptionMessage;

        try {
            Test.startTest();
            EDCSettingsProdInfoActionResultModel actionResult = service.handleAction(action, apiVersion);
            Test.stopTest();
            System.assert(false, 'this should not happen');
        } catch (EDASettingsProductInformationAPIService.InvalidActionException ex) {
            exceptionMessage = ex.getMessage();
        }

        System.assertEquals(
            Label.stgErrorSettingsProductInvalidAction,
            exceptionMessage,
            'the error message is incorrect, it should be: ' + Label.stgErrorSettingsProductInvalidAction
        );
    }

    /**************************************************************************************************************************
     * @description Test method to assess an scenario when createErrorActionResult returns an instance of EDCSettingsProdInfoActionResultModel
     * with the error message and code populated
     ***************************************************************************************************************************/
    @isTest
    private static void testCreateErrorActionResult() {
        Integer code = 400;
        String errorMessage = 'testErrorMessage';
        EDASettingsProductInformationAPIService service = new EDASettingsProductInformationAPIService();

        Test.startTest();
        EDCSettingsProdInfoActionResultModel actionResult = service.createErrorActionResult(code, errorMessage);
        Test.stopTest();

        System.assertEquals(false, actionResult.success, 'success should be false');
        System.assertEquals(null, actionResult.result, 'result should be null');
        System.assertNotEquals(null, actionResult.error, 'error should not be null');
        System.assertEquals(400, actionResult.error.code, 'error code should be 400');
        System.assertEquals(errorMessage, actionResult.error.message, errorMessage);
    }

    /**************************************************************************************************************************
     * @description Stub class for EDCSettingsProductInformationMapper where getProductInformationModel method
     * provides sample data for testing
     ***************************************************************************************************************************/
    private class EDCSettingsProductInformationMapperStub extends EDCSettingsProductInformationMapper {
        public override EDCSettingsProductInformationModel getProductInformationModel() {
            EDCSettingsProductInformationModel productInformation = new EDCSettingsProductInformationModel(
                'testInitials',
                'testName',
                'testDescription',
                'testSettingsComponent',
                'testSettingsButtonA11y',
                'testDocumentationUrl',
                'testDocumentationButtonA11y',
                'testTrailheadUrl',
                'testTrailheadButtonA11y',
                'testIcon'
            );
            return productInformation;
        }
    }
}
