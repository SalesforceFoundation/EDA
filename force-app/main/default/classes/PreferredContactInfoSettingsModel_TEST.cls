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
 * @description Test class for PreferredContactInfoSettingsModel class.
 */
@isTest
private with sharing class PreferredContactInfoSettingsModel_TEST {
    /****************************************************************************
     * @description Test method to verify 4 argument constructor returns a model
     * with all properties populated
     ****************************************************************************/
    @isTest
    private static void fourArgumentConstructorValid() {
        Test.startTest();
        PreferredContactInfoSettingsModel referredContactInfoSettingsModel = new PreferredContactInfoSettingsModel(
            true,
            false,
            false,
            'Test Phone Field'
        );
        Test.stopTest();

        System.assertEquals(
            true,
            referredContactInfoSettingsModel.requirePreferredEmail,
            'Should require preferred email.'
        );
        System.assertEquals(
            false,
            referredContactInfoSettingsModel.enhancedPhoneFunctionality,
            'Should not require enhanced phone functionality.'
        );
        System.assertEquals(
            false,
            referredContactInfoSettingsModel.preferredPhoneEnforcement,
            'Should not require preferred phone enforcement.'
        );
        System.assertEquals(
            'Test Phone Field',
            referredContactInfoSettingsModel.defaultPreferredPhone,
            'Default preferred phone field should be specified.'
        );
    }

    /****************************************************************************
     * @description Test method to verify 4 argument constructor returns a model
     * with all properties appropriately defaulted when blank or null values are
     * provided.
     ****************************************************************************/
    @isTest
    private static void fourArgumentConstructorEmptyString() {
        Test.startTest();
        PreferredContactInfoSettingsModel referredContactInfoSettingsModel = new PreferredContactInfoSettingsModel(
            false,
            false,
            true,
            ''
        );
        Test.stopTest();

        System.assertEquals(
            false,
            referredContactInfoSettingsModel.requirePreferredEmail,
            'Preferred email value should be set to false.'
        );
        System.assertEquals(
            false,
            referredContactInfoSettingsModel.enhancedPhoneFunctionality,
            'Enhanced phone functionality should be set to false.'
        );
        System.assertEquals(
            true,
            referredContactInfoSettingsModel.preferredPhoneEnforcement,
            'Preferred phone enforcement should be set to true.'
        );
        System.assertEquals(
            '""',
            referredContactInfoSettingsModel.defaultPreferredPhone,
            'Blank value for default preferred phone field should be represented as blank value.'
        );
    }
}
