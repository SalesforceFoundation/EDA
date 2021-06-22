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
 * @group-content
 * @description Test class for ContactLanguageSettingsVModel.
 */
@isTest
private with sharing class ContactLanguageSettingsVModel_TEST {
    /**********************************************************************************************************
     * @description Test method to verify single argument constructor returns a ContactLanguageSettingsVModel
     * with the selected value set matching the Hierarchy Settings field when populated.
     **********************************************************************************************************/
    @isTest
    private static void singleArugmentConstructorValid() {
        List<ComboboxValueVModel> defaultLanguageFluencyOptionsList = new List<ComboboxValueVModel>{
            new ComboboxValueVModel('Fluency 1', 'Fluency1'),
            new ComboboxValueVModel('Fluency 2', 'Fluency2'),
            new ComboboxValueVModel('Fluency 3', 'Fluency3')
        };

        ComboboxVModel defaultLanguageFluencyComboboxVModel = new ComboboxVModel(
            'Fluency2',
            defaultLanguageFluencyOptionsList
        );

        Test.startTest();
        ContactLanguageSettingsVModel contactLanguageSettingsVModel = new ContactLanguageSettingsVModel(
            defaultLanguageFluencyComboboxVModel
        );
        Test.stopTest();

        System.assertEquals(
            'Fluency2',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.value,
            'Selected value should match Hierarchy Settings.'
        );

        System.assertEquals(
            'Fluency 1',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[0].label,
            'Label for picklist options should match available active picklist entries.'
        );
        System.assertEquals(
            'Fluency1',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[0].value,
            'Value for picklist options should match available active picklist entries.'
        );

        System.assertEquals(
            'Fluency 2',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[1].label,
            'Label for picklist options should match available active picklist entries.'
        );
        System.assertEquals(
            'Fluency2',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[1].value,
            'Value for picklist options should match available active picklist entries.'
        );

        System.assertEquals(
            'Fluency 3',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[2].label,
            'Label for picklist options should match available active picklist entries.'
        );
        System.assertEquals(
            'Fluency3',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[2].value,
            'Value for picklist options should match available active picklist entries.'
        );
    }

    /**********************************************************************************************************
     * @description Test method to verify single argument constructor returns a ContactLanguageSettingsVModel
     * with no selected value set when the Hierarchy Settings field is left blank.
     **********************************************************************************************************/
    @isTest
    private static void singleArugmentConstructorNoCurrentSelection() {
        List<ComboboxValueVModel> defaultLanguageFluencyOptionsList = new List<ComboboxValueVModel>{
            new ComboboxValueVModel('Fluency 1', 'Fluency1'),
            new ComboboxValueVModel('Fluency 2', 'Fluency2'),
            new ComboboxValueVModel('Fluency 3', 'Fluency3')
        };

        ComboboxVModel defaultLanguageFluencyComboboxVModel = new ComboboxVModel(
            '""',
            defaultLanguageFluencyOptionsList
        );

        Test.startTest();
        ContactLanguageSettingsVModel contactLanguageSettingsVModel = new ContactLanguageSettingsVModel(
            defaultLanguageFluencyComboboxVModel
        );
        Test.stopTest();

        System.assertEquals(
            '""',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.value,
            'Selected value should be blank.'
        );

        System.assertEquals(
            'Fluency 1',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[0].label,
            'Label for picklist options should match available active picklist entries.'
        );
        System.assertEquals(
            'Fluency1',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[0].value,
            'Value for picklist options should match available active picklist entries.'
        );

        System.assertEquals(
            'Fluency 2',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[1].label,
            'Label for picklist options should match available active picklist entries.'
        );
        System.assertEquals(
            'Fluency2',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[1].value,
            'Value for picklist options should match available active picklist entries.'
        );

        System.assertEquals(
            'Fluency 3',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[2].label,
            'Label for picklist options should match available active picklist entries.'
        );
        System.assertEquals(
            'Fluency3',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[2].value,
            'Value for picklist options should match available active picklist entries.'
        );
    }
}
