@isTest
private class EDCSettingsProductAPIModel_TEST {
    @isTest
    private static void testConstructor() {
        String initials = 'testInitials';
        String name = 'testName';
        String description = 'testDescription';
        String settingsComponent = 'testSettingsComponent';
        String documentationUrl = 'testDocumentationUrl';
        String trailheadUrl = 'testTrailheadUrl';
        String icon = 'testIcon';

        EDCSettingsProductAPIModel.SettingsProductInformation model;

        Test.startTest();

        model = new EDCSettingsProductAPIModel.SettingsProductInformation(
            initials,
            name,
            description,
            settingsComponent,
            documentationUrl,
            trailheadUrl,
            icon
        );

        EDCSettingsProductAPIModel.SettingsProductInformationResult productResult = new EDCSettingsProductAPIModel.SettingsProductInformationResult(
            model
        );

        EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult = new EDCSettingsProductAPIModel.SettingsProductInformationActionResult(
            productResult,
            true,
            null
        );

        Test.stopTest();

        //assert the data got mapped correctly to the model (product)
        System.assertEquals(initials, model.initials, 'initials should be set with the value it is passed');
        System.assertEquals(name, model.name, 'name should be set with the value it is passed');
        System.assertEquals(description, model.description, 'description should be set with the value it is passed');
        System.assertEquals(
            settingsComponent,
            model.settingsComponent,
            'settingsComponent should be set with the value it is passed'
        );
        System.assertEquals(
            documentationUrl,
            model.documentationUrl,
            'documentationUrl should be set with the value it is passed'
        );
        System.assertEquals(
            trailheadUrl,
            model.trailheadUrl,
            'settingsComponent should be set with the value it is passed'
        );
        System.assertEquals(icon, model.icon, 'settingsComponent should be set with the value it is passed');
        System.assertEquals(
            model,
            productResult.productInformation,
            'the model is not correct for this product information'
        );
        System.assertEquals(true, actionResult.success, 'success should be true');
        System.assertEquals(null, actionResult.error, 'error should be null');
        System.assertEquals(productResult, actionResult.result, 'result is not correct');
    }
}
