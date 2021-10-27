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
 * @description Test class for EDCSettingsProductInformationModel
 */
@isTest
private class EDCSettingsProductInformationModel_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify the constructor is setting the properties correctly
     ***************************************************************************************************************************/
    @isTest
    private static void testConstructor() {
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

        EDCSettingsProductInformationModel model;

        Test.startTest();

        model = new EDCSettingsProductInformationModel(
            initials,
            name,
            description,
            settingsComponent,
            settingsButtonA11y,
            documentationUrl,
            documentationButtonA11y,
            trailheadUrl,
            trailheadButtonA11y,
            icon
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
            settingsButtonA11y,
            model.settingsButtonA11y,
            'settingsButtonA11y should be set with the value it is passed'
        );
        System.assertEquals(
            documentationUrl,
            model.documentationUrl,
            'documentationUrl should be set with the value it is passed'
        );
        System.assertEquals(
            documentationButtonA11y,
            model.documentationButtonA11y,
            'documentationButtonA11y should be set with the value it is passed'
        );
        System.assertEquals(
            trailheadUrl,
            model.trailheadUrl,
            'settingsComponent should be set with the value it is passed'
        );
        System.assertEquals(
            trailheadButtonA11y,
            model.trailheadButtonA11y,
            'trailheadButtonA11y should be set with the value it is passed'
        );
        System.assertEquals(icon, model.icon, 'icon should be set with the value it is passed');
    }
}
