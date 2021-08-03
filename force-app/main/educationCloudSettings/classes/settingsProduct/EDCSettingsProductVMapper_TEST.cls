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
 * @description Test class for ProductRegistryVModel
 */
@isTest
private class EDCSettingsProductVMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify the getEDCSettingsProductVModel method returns a
     * EDCSettingsProductVModel correctly
     ***************************************************************************************************************************/
    @isTest
    private static void testGetEDCSettingsProductVModel() {
        String initials = 'testInitials';
        String name = 'testName';
        String description = 'testDescription';
        String settingsComponent = 'testSettingsComponent';
        String documentationUrl = 'testDocumentationUrl';
        String trailheadUrl = 'testTrailheadUrl';
        String icon = 'testIcon';
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;

        EDCSettingsProductAPIService.instance = new EDCSettingsProductAPIServiceStub();
        EDCSettingsProductVModel productVModel;

        Test.startTest();
        productVModel = EDCSettingsProductVMapper.getInstance()
            .getEDCSettingsProductVModel(classname, namespace, apiVersion);
        Test.stopTest();

        System.assertEquals(initials, productVModel.initials, 'initials should be set to ' + initials);
        System.assertEquals(name, productVModel.name, 'name should be set to ' + name);
        System.assertEquals(description, productVModel.description, 'description should be set to ' + description);
        System.assert(
            productVModel.settingsComponent.contains(settingsComponent),
            'settingsComponent should contains ' + settingsComponent
        );
        System.assertEquals(
            documentationUrl,
            productVModel.documentationUrl,
            'documentationUrl should be set to ' + documentationUrl
        );
        System.assertEquals(trailheadUrl, productVModel.trailheadUrl, 'trailheadUrl should be set to ' + trailheadUrl);
        System.assertEquals(icon, productVModel.icon, 'icon should be set to ' + icon);
    }

    /**************************************************************************************************************************
     * @description Test method to verify a SettingsProductException is throw when
     * EDCSettingsProdInfoActionResultModel is not successful
     ***************************************************************************************************************************/
    @isTest
    private static void testExceptionGetEDCSettingsProductVModel() {
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;
        String exceptionMessage;

        EDCSettingsProductAPIService.instance = new EDCSettingsProductAPIServiceErrorStub();
        EDCSettingsProductVModel productVModel;

        try {
            Test.startTest();
            productVModel = EDCSettingsProductVMapper.getInstance()
                .getEDCSettingsProductVModel(classname, namespace, apiVersion);
            Test.stopTest();
            System.assert(true, 'this should not happen');
        } catch (EDCSettingsProductVMapper.SettingsProductException e) {
            exceptionMessage = e.getMessage();
        }

        System.assertNotEquals(null, exceptionMessage, 'exception message should not be null');
    }

    /**************************************************************************************************************************
     * @description Test method to assess the scenario when a getEDCSettingsProductVModel returns null
     ***************************************************************************************************************************/
    @isTest
    private static void TestNullProductInformation() {
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;

        EDCSettingsProductVMapper.instance = new EDCSettingsProductVMapperNullProductInformationStub();
        EDCSettingsProductVModel productVModel;

        Test.startTest();
        productVModel = EDCSettingsProductVMapper.getInstance()
            .getEDCSettingsProductVModel(classname, namespace, apiVersion);
        Test.stopTest();

        System.assertEquals(null, productVModel, 'productVModel should be null');
    }

    /**************************************************************************************************************************
     * @description Test method to assess the scenario when a getSettingsProductInformation returns null
     ***************************************************************************************************************************/
    @isTest
    private static void TestNullActionResult() {
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;

        EDCSettingsProductAPIService.instance = new EDCSettingsProductAPIServiceNullAction();

        EDCSettingsProductInformationModel productVModel;

        Test.startTest();
        productVModel = EDCSettingsProductVMapper.getInstance()
            .getSettingsProductInformation(classname, namespace, apiVersion);
        Test.stopTest();

        System.assertEquals(null, productVModel, 'productVModel should be null');
    }

    /**************************************************************************************************************************
     * @description Stub class for EDCSettingsProductAPIService, where the getSettingsProductInformation method returns some
     * EDCSettingsProdInfoActionResultModel sample data
     ***************************************************************************************************************************/
    private class EDCSettingsProductAPIServiceStub extends EDCSettingsProductAPIService {
        public override EDCSettingsProdInfoActionResultModel getSettingsProductInformation(
            String className,
            String namespace,
            Decimal apiVersion
        ) {
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
            return actionResult;
        }
    }
    /**************************************************************************************************************************
     * @description Stub class for EDCSettingsProductAPIService, where the getSettingsProductInformation method returns a
     * EDCSettingsProdInfoActionResultModel with success = false and an CallableError instance
     ***************************************************************************************************************************/
    private class EDCSettingsProductAPIServiceErrorStub extends EDCSettingsProductAPIService {
        public override EDCSettingsProdInfoActionResultModel getSettingsProductInformation(
            String className,
            String namespace,
            Decimal apiVersion
        ) {
            CallableError error = new CallableError(400, 'testErrorMessage');
            EDCSettingsProdInfoActionResultModel actionResult = new EDCSettingsProdInfoActionResultModel(
                null,
                false,
                error
            );
            return actionResult;
        }
    }

    /**************************************************************************************************************************
     * @description Stub class for EDCSettingsProductVMapper, where the getSettingsProductInformation method returns null
     ***************************************************************************************************************************/
    private class EDCSettingsProductVMapperNullProductInformationStub extends EDCSettingsProductVMapper {
        private override EDCSettingsProductInformationModel getSettingsProductInformation(
            String className,
            String namespace,
            Decimal apiVersion
        ) {
            return null;
        }
    }

    /**************************************************************************************************************************
     * @description Stub class for EDCSettingsProductAPIService, where the getSettingsProductInformation method returns null
     ***************************************************************************************************************************/
    private class EDCSettingsProductAPIServiceNullAction extends EDCSettingsProductAPIService {
        public override EDCSettingsProdInfoActionResultModel getSettingsProductInformation(
            String className,
            String namespace,
            Decimal apiVersion
        ) {
            return null;
        }
    }
}
