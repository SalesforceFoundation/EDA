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
 * @description Test class for DualListboxVModel.
 */
@isTest
private with sharing class DualListboxVModel_TEST {
    /***********************************************************************************
     * @description Test to verify that the 2 argument constructor generates a model
     * with all properties populated as expected.
     ***********************************************************************************/
    @isTest
    private static void twoArgumentConstructorValid() {
        List<String> selectedValuesList = new List<String>();
        List<DualListboxValueVModel> allOptionsDualListboxValueVModelsList = new List<DualListboxValueVModel>();

        allOptionsDualListboxValueVModelsList.add(new DualListboxValueVModel('Record Type 1', '000000000000000001'));
        allOptionsDualListboxValueVModelsList.add(new DualListboxValueVModel('Record Type 2', '000000000000000002'));
        allOptionsDualListboxValueVModelsList.add(new DualListboxValueVModel('Record Type 3', '000000000000000003'));

        selectedValuesList.add('000000000000000001');
        selectedValuesList.add('000000000000000002');

        Test.startTest();
        DualListboxVModel dualListboxVModel = new DualListboxVModel(
            selectedValuesList,
            allOptionsDualListboxValueVModelsList
        );
        Test.stopTest();

        System.assertEquals(2, dualListboxVModel.value.size(), 'Should have 2 record type Ids set as selected.');
        System.assertEquals(
            3,
            dualListboxVModel.options.size(),
            'Options list should include all record types regardless of whether they are also selected.'
        );

        for (Integer i = 0; i < dualListboxVModel.value.size(); i++) {
            System.assertEquals(
                '00000000000000000' + (i + 1),
                dualListboxVModel.value[i],
                'Value for selected record type in DualListboxVModel should match value provided to constructor.'
            );
        }

        for (Integer i = 0; i < dualListboxVModel.options.size(); i++) {
            System.assertEquals(
                'Record Type ' + (i + 1),
                dualListboxVModel.options[i].label,
                'Label for current DualListboxValueVModel in options list should match value provided to constructor.'
            );
            System.assertEquals(
                '00000000000000000' + (i + 1),
                dualListboxVModel.options[i].value,
                'Value for current DualListboxValueVModel in options list should match value provided to constructor.'
            );
        }
    }
}
