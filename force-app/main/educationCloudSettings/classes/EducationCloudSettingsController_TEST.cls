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
 * @description Test class for EducationCloudSettingsController
 */
@isTest
private class EducationCloudSettingsController_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getProductRegistrySettingsProductInformationVModels method returns
     * the list of ProductRegistryVModel and all its values populated
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductRegistrySettingsProductInformationVModels() {
        String name = 'testName';
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;
        ProductRegistryVMapper.instance = new ProductRegistryVMapperStub();

        Test.startTest();
        List<ProductRegistryVModel> productRegistryList = EducationCloudSettingsController.getProductRegistrySettingsProductInformationVModels();
        Test.stopTest();

        System.assertEquals(1, productRegistryList.size(), 'productRegistryList size should be 1');

        ProductRegistryVModel model = productRegistryList.get(0);
        System.assertEquals(name, model.name, 'name should be set with the value: ' + name);
        System.assertEquals(action, model.action, 'action should be set with the value: ' + action);
        System.assertEquals(namespace, model.namespace, 'namespace should be set with the value: ' + namespace);
        System.assertEquals(classname, model.classname, 'classname should be set with the value: ' + classname);
        System.assertEquals(apiVersion, model.apiVersion, 'apiVersion should be set with the value: ' + apiVersion);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that an AuraHandledException is thrown if an exception is received inside the
     * getProductRegistrySettingsProductInformationVModels method
     ***************************************************************************************************************************/
    @isTest
    private static void testExceptionGetProductRegistrySettingsProductInformationVModels() {
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;
        String exceptionMessage;
        ProductRegistryVMapper.instance = new ProductRegistryVMapperExceptionStub();

        try {
            Test.startTest();
            List<ProductRegistryVModel> productRegistryList = EducationCloudSettingsController.getProductRegistrySettingsProductInformationVModels();
            Test.stopTest();
            System.assert(false, 'this should not happen');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(String.isNotBlank(exceptionMessage), 'exceptionMessage should be not be blank');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getEDCSettingsProductVModel method returns
     * a EDCSettingsProductVModel and all its values populated
     ***************************************************************************************************************************/
    @isTest
    private static void testGetEDCSettingsProductVModel() {
        String initials = 'testInitials';
        String name = 'testName';
        String description = 'testDescription';
        String settingsComponent = 'c__testSettingsComponent';
        String settingsButtonA11y = 'testSettingsButtonA11y';
        String documentationUrl = 'testDocumentationUrl';
        String documentationButtonA11y = 'testDocumentationButtonA11y';
        String trailheadUrl = 'testTrailheadUrl';
        String trailheadButtonA11y = 'testTrailheadButtonA11y';
        String icon = 'testIcon';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;

        EDCSettingsProductVModel productVModel;
        EDCSettingsProductVMapper.instance = new EDCSettingsProductVMapperStub();

        Test.startTest();
        productVModel = EducationCloudSettingsController.getEDCSettingsProductVModel(classname, namespace, apiVersion);
        Test.stopTest();

        System.assertEquals(initials, productVModel.initials, 'initials should be set to ' + initials);
        System.assertEquals(name, productVModel.name, 'name should be set to ' + name);
        System.assertEquals(description, productVModel.description, 'description should be set to ' + description);
        System.assertEquals(
            settingsComponent,
            productVModel.settingsComponent,
            'settingsComponent should be set to ' + settingsComponent
        );
        System.assertEquals(
            settingsButtonA11y,
            productVModel.settingsButtonA11y,
            'settingsButtonA11y should be set to ' + settingsButtonA11y
        );
        System.assertEquals(
            documentationUrl,
            productVModel.documentationUrl,
            'documentationUrl should be set to ' + documentationUrl
        );
        System.assertEquals(
            documentationButtonA11y,
            productVModel.documentationButtonA11y,
            'documentationButtonA11y should be set to ' + documentationButtonA11y
        );
        System.assertEquals(trailheadUrl, productVModel.trailheadUrl, 'trailheadUrl should be set to ' + trailheadUrl);
        System.assertEquals(
            trailheadButtonA11y,
            productVModel.trailheadButtonA11y,
            'trailheadButtonA11y should be set to ' + trailheadButtonA11y
        );
        System.assertEquals(icon, productVModel.icon, 'icon should be set to ' + icon);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that an AuraHandledException is thrown if an exception is received inside the
     * getEDCSettingsProductVModel method
     ***************************************************************************************************************************/
    @isTest
    private static void testExceptionGetEDCSettingsProductVModel() {
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;
        String exceptionMessage;

        EDCSettingsProductVModel productVModel;
        EDCSettingsProductVMapper.instance = new EDCSettingsProductVMapperExceptionStub();

        try {
            Test.startTest();
            productVModel = EducationCloudSettingsController.getEDCSettingsProductVModel(
                classname,
                namespace,
                apiVersion
            );
            Test.stopTest();
            System.assert(false, 'this should not happen');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }

        System.assert(String.isNotBlank(exceptionMessage), 'exceptionMessage should be not be blank');
    }

    /**************************************************************************************************************************
     * @description Stub class for EDCSettingsProductVMapper returning some sample data
     ***************************************************************************************************************************/
    private class EDCSettingsProductVMapperStub extends EDCSettingsProductVMapper {
        public override EDCSettingsProductVModel getEDCSettingsProductVModel(
            String classname,
            String namespace,
            Decimal apiVersion
        ) {
            EDCSettingsProductVModel model = new EDCSettingsProductVModel(
                'testInitials',
                'testName',
                'testDescription',
                'c__testSettingsComponent',
                'testSettingsButtonA11y',
                'testDocumentationUrl',
                'testDocumentationButtonA11y',
                'testTrailheadUrl',
                'testTrailheadButtonA11y',
                'testIcon'
            );
            return model;
        }
    }

    /**************************************************************************************************************************
     * @description Stub class for EDCSettingsProductVMapper, where the method getEDCSettingsProductVModel
     * throws an AuraHandledException
     ***************************************************************************************************************************/
    private class EDCSettingsProductVMapperExceptionStub extends EDCSettingsProductVMapper {
        public override EDCSettingsProductVModel getEDCSettingsProductVModel(
            String classname,
            String namespace,
            Decimal apiVersion
        ) {
            throw new AuraHandledException('testExceptionMessage');
        }
    }

    /**************************************************************************************************************************
     * @description Stub class for ProductRegistryVMapper returning some sample data
     ***************************************************************************************************************************/
    private class ProductRegistryVMapperStub extends ProductRegistryVMapper {
        public override List<ProductRegistryVModel> getProductRegistrySettingsProductInformation() {
            ProductRegistryVModel model = new ProductRegistryVModel(
                'testName',
                'testAction',
                'testNamespace',
                'testClassname',
                52.0
            );
            return new List<ProductRegistryVModel>{ model };
        }
    }

    /**************************************************************************************************************************
     * @description Stub class for ProductRegistryVMapper, where the method getProductRegistrySettingsProductInformation
     * throws an AuraHandledException
     ***************************************************************************************************************************/
    private class ProductRegistryVMapperExceptionStub extends ProductRegistryVMapper {
        public override List<ProductRegistryVModel> getProductRegistrySettingsProductInformation() {
            throw new AuraHandledException('testExceptionMessage');
        }
    }
}
