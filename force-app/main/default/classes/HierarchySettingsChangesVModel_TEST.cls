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
* @group-content ../../ApexDocContent/Tests.htm
* @description Test class for HierarchySettingsChangesVModel class.
*/
@isTest 
public with sharing class HierarchySettingsChangesVModel_TEST {
    /******************************************************************************
    * @description Test method to verify the no argument constructor returns a
    * HierarchySettingsChangesVModel with empty properties initialized.
    ******************************************************************************/
    @isTest 
    private static void noParameterConstructor() {
        Test.startTest();
        HierarchySettingsChangesVModel hierarchySettingsChangesVModel = new HierarchySettingsChangesVModel();
        Test.stopTest();

        System.assertEquals(
            true, 
            hierarchySettingsChangesVModel.settingsSingleValueBySettingsName.isEmpty(), 
            'settingsSingleValueBySettingsName should be an empty map.'
        );

        System.assertEquals(
            true, 
            hierarchySettingsChangesVModel.settingsListSettingsName.isEmpty(), 
            'settingsListSettingsName should be an empty map.'
        );
    }

    /******************************************************************************
    * @description Test method to verify two argument constructor returns a
    * HierarchySettingsChangesVModel with all properties populated.
    ******************************************************************************/
    @isTest 
    private static void twoParameterConstructor() {
        Map<String, String> settingsSingleValueBySettingsName = new Map<String, String> {
            'Value1' => 'Changed Value 1'
        };

        Map<String, List<String>> settingsListSettingsName = new Map<String, List<String>> {
            'CollectionValue1' => new List<String>{'Change1', 'Change2', 'Change3'}
        };

        Test.startTest();
        HierarchySettingsChangesVModel hierarchySettingsChangesVModel = 
            new HierarchySettingsChangesVModel(settingsSingleValueBySettingsName, settingsListSettingsName);
        Test.stopTest();

        System.assertEquals(
            'Changed Value 1', 
            hierarchySettingsChangesVModel.settingsSingleValueBySettingsName.get('Value1'), 
            'Mapped value should match parameter value.'
        );

        System.assertEquals(
            3, 
            hierarchySettingsChangesVModel.settingsListSettingsName.get('CollectionValue1').size(), 
            'Mapped value should be list of 3 elements.'
        );

        System.assertEquals(
            true, 
            hierarchySettingsChangesVModel.settingsListSettingsName.get('CollectionValue1').contains('Change1'),
            'List of changes to setting should include \'Change1\''
        );

        System.assertEquals(
            true, 
            hierarchySettingsChangesVModel.settingsListSettingsName.get('CollectionValue1').contains('Change2'),
            'List of changes to setting should include \'Change2\''
        );

        System.assertEquals(
            true, 
            hierarchySettingsChangesVModel.settingsListSettingsName.get('CollectionValue1').contains('Change3'),
            'List of changes to setting should include \'Change3\''
        );
    }
}
