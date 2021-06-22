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
 * @description Test class for RelationshipLookupVModel class.
 */
@isTest
public with sharing class RelationshipLookupVModel_TEST {
    /*****************************************************************************
     * @description Test to verify constructor instantiates a
     * model with the appropriate data.
     *****************************************************************************/
    @isTest
    private static void relationshipLookupVModelValid() {
        Test.startTest();
        String testLookupName = 'Test Lookup Name';
        String testFemaleValue = 'test female value';
        String testMaleValue = 'test male value';
        String testNeutralValue = 'test neutral value';
        RelationshipLookupVModel relLookupVModel = new RelationshipLookupVModel(
            testLookupName,
            testFemaleValue,
            testMaleValue,
            testNeutralValue,
            false
        );
        Test.stopTest();

        System.assertEquals(
            testLookupName,
            relLookupVModel.name,
            'Relationship lookup name should be ' + testLookupName
        );
        System.assertEquals(testFemaleValue, relLookupVModel.femaleValue, 'Female value should be ' + testFemaleValue);
        System.assertEquals(testMaleValue, relLookupVModel.maleValue, 'Male value should be ' + testMaleValue);
        System.assertEquals(
            testNeutralValue,
            relLookupVModel.neutralValue,
            'Neutral value should be ' + testNeutralValue
        );
        System.assertEquals(false, relLookupVModel.isActive, 'isActive should be false');
    }
}
