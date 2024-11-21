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
 * @description Test class for EDCSettingsProductInformationMapper
 */
@isTest
private class EDCSettingsProductInformationMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify the getProductInformationModel method returns an instance of
     * EDCSettingsProductInformationModel with all its values populated
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductInformationModel() {
        EDCSettingsProductInformationModel productInformationModel;

        Test.startTest();
        productInformationModel = EDCSettingsProductInformationMapper.getInstance().getProductInformationModel();
        Test.stopTest();

        System.assertEquals(
            EDCSettingsProductInformationMapper.PRODUCT_EDA_DESCRIPTION,
            productInformationModel.description,
            'description should be set to ' + EDCSettingsProductInformationMapper.PRODUCT_EDA_DESCRIPTION
        );
        System.assertEquals(
            EDCSettingsProductInformationMapper.PRODUCT_EDA_INITIALS,
            productInformationModel.initials,
            'initials should be set to ' + EDCSettingsProductInformationMapper.PRODUCT_EDA_INITIALS
        );
        System.assertEquals(
            EDCSettingsProductInformationMapper.PRODUCT_EDA_NAME,
            productInformationModel.name,
            'name should be set to ' + EDCSettingsProductInformationMapper.PRODUCT_EDA_NAME
        );

        String navigationPrefix = UTIL_Namespace.StrTokenNSPrefixComponent();
        System.assertEquals(
            navigationPrefix + EDCSettingsProductInformationMapper.PRODUCT_EDA_SETTINGSCOMPONENT,
            productInformationModel.settingsComponent,
            'settingsComponent should be set to ' + EDCSettingsProductInformationMapper.PRODUCT_EDA_SETTINGSCOMPONENT
        );
        System.assertEquals(
            EDCSettingsProductInformationMapper.PRODUCT_EDA_SETTINGSBUTTONA11Y,
            productInformationModel.settingsButtonA11y,
            'settingsButtonA11y should be set to ' + EDCSettingsProductInformationMapper.PRODUCT_EDA_SETTINGSBUTTONA11Y
        );
        System.assertEquals(
            EDCSettingsProductInformationMapper.PRODUCT_EDA_DOCUMENTATIONBUTTONA11Y,
            productInformationModel.documentationButtonA11y,
            'documentationButtonA11y should be set to ' +
            EDCSettingsProductInformationMapper.PRODUCT_EDA_DOCUMENTATIONBUTTONA11Y
        );
        System.assertEquals(
            EDCSettingsProductInformationMapper.PRODUCT_EDA_TRAILHEADURL,
            productInformationModel.trailheadUrl,
            'trailheadUrl should be set to ' + EDCSettingsProductInformationMapper.PRODUCT_EDA_TRAILHEADURL
        );
        System.assertEquals(
            EDCSettingsProductInformationMapper.PRODUCT_EDA_TRAILHEADBUTTONA11Y,
            productInformationModel.trailheadButtonA11y,
            'trailheadButtonA11y should be set to ' +
            EDCSettingsProductInformationMapper.PRODUCT_EDA_TRAILHEADBUTTONA11Y
        );
        System.assertEquals(
            EDCSettingsProductInformationMapper.PRODUCT_EDA_ICON,
            productInformationModel.icon,
            'icon should be set to ' + EDCSettingsProductInformationMapper.PRODUCT_EDA_ICON
        );
    }
}
