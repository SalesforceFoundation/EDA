@isTest
private class EDCSettingsProductVModel_TEST {
    @isTest
    private static void testConstructor() {
        String initials = 'testInitials';
        String name = 'testName';
        String description = 'testDescription';
        String settingsComponent = 'testSettingsComponent';
        String documentationUrl = 'testDocumentationUrl';
        String trailheadUrl = 'testTrailheadUrl';
        String icon = 'testIcon';

        EDCSettingsProductVModel model;

        Test.startTest();
        model = new EDCSettingsProductVModel(
            initials,
            name,
            description,
            settingsComponent,
            documentationUrl,
            trailheadUrl,
            icon
        );
        Test.stopTest();

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
    }
}
