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
 * @description Test class for EDCSettingsProductCardController
 */
@isTest
private class EDCSettingsProductCardController_TEST {
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
        String documentationUrl = 'testDocumentationUrl';
        String trailheadUrl = 'testTrailheadUrl';
        String icon = 'testIcon';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;

        EDCSettingsProductVModel productVModel;
        EDCSettingsProductVMapper.instance = new EDCSettingsProductVMapperStub();

        Test.startTest();
        productVModel = EDCSettingsProductCardController.getEDCSettingsProductVModel(classname, namespace, apiVersion);
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
            documentationUrl,
            productVModel.documentationUrl,
            'documentationUrl should be set to ' + documentationUrl
        );
        System.assertEquals(trailheadUrl, productVModel.trailheadUrl, 'trailheadUrl should be set to ' + trailheadUrl);
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
            productVModel = EDCSettingsProductCardController.getEDCSettingsProductVModel(
                classname,
                namespace,
                apiVersion
            );
            Test.stopTest();
            System.assert(true, 'this should not happen');
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
                'testDocumentationUrl',
                'testTrailheadUrl',
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
}
