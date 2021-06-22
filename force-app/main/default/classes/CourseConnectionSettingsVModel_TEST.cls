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
 * @description Test class for CourseConnectionSettingsVModel.
 */
@isTest
private with sharing class CourseConnectionSettingsVModel_TEST {
    private static Integer loopCounter = 5;
    /***********************************************************************************
     * @description Test to verify that the constructor generates a model
     * with all properties populated as expected.
     ***********************************************************************************/
    @isTest
    private static void testConstructorValid() {
        List<ComboboxValueVModel> courseConnectionRecTypeComboboxValueVModelsList = new List<ComboboxValueVModel>();

        for (Integer i = 0; i < loopCounter; i++) {
            courseConnectionRecTypeComboboxValueVModelsList.add(
                new ComboboxValueVModel(
                    'Course Connection Record Type Label' + i,
                    'Course Connection Record Type Value' + i
                )
            );
        }

        ComboboxVModel defaultStudentComboboxVModel = new ComboboxVModel(
            'Default Student',
            courseConnectionRecTypeComboboxValueVModelsList
        );

        ComboboxVModel defaultFacultyComboboxVModel = new ComboboxVModel(
            'Default Faculty',
            courseConnectionRecTypeComboboxValueVModelsList
        );

        Test.startTest();
        CourseConnectionSettingsVModel courseConnectionSettingsVModel = new CourseConnectionSettingsVModel(
            true,
            defaultStudentComboboxVModel,
            defaultFacultyComboboxVModel
        );
        Test.stopTest();

        System.assertEquals(
            true,
            courseConnectionSettingsVModel.courseConnectionRecordTypes,
            'courseConnectionRecordTypes should be enabled'
        );

        for (Integer i = 0; i < loopCounter; i++) {
            System.assertEquals(
                'Course Connection Record Type Label' + i,
                courseConnectionSettingsVModel.defaultStudentRecType.options[i].label,
                'Label on comboboxValueVModel for Default Student Course Connection model should be set.'
            );

            System.assertEquals(
                'Course Connection Record Type Label' + i,
                courseConnectionSettingsVModel.defaultFacultyRecType.options[i].label,
                'Label on comboboxValueVModel for Default Faculty Course Connection model should be set.'
            );

            System.assertEquals(
                'Course Connection Record Type Value' + i,
                courseConnectionSettingsVModel.defaultStudentRecType.options[i].value,
                'Value on comboboxValueVModel for Default Student Course Connection model should be set.'
            );

            System.assertEquals(
                'Course Connection Record Type Value' + i,
                courseConnectionSettingsVModel.defaultFacultyRecType.options[i].value,
                'Value on comboboxValueVModel for Default Faculty Course Connection model should be set.'
            );
        }
    }
}
