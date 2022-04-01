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
 * @description Test class for AddressSettingsService class.
 */
@isTest
private with sharing class AutoEnrollmentMappingModel_TEST {
    /**
     * @description Verifies five argument constructor returns an AutoEnrollmentMappingModel
     * with all properties populated.
     */
    @isTest
    private static void fiveArgumentConstructorValid() {
        String name = 'Academic_Program';
        String accountRecordTypeFieldValue = 'Academic_Program';
        String role = AffiliationTestSetupFactory_TEST.PROG_ENROLL_ROLE_STUDENT;
        String status = AffiliationTestSetupFactory_TEST.PROG_ENROLL_STATUS_CURRENT;
        Boolean active = true;

        Test.startTest();
        AutoEnrollmentMappingModel autoEnrollmentMappingModel = new AutoEnrollmentMappingModel(
            name,
            accountRecordTypeFieldValue,
            role,
            status,
            active
        );
        Test.stopTest();

        System.assertEquals(name, autoEnrollmentMappingModel.name, 'The \'name\' field should be the expected value.');
        System.assertEquals(
            accountRecordTypeFieldValue,
            autoEnrollmentMappingModel.accountRecordTypeFieldValue,
            'The \'accountRecordTypeFieldValue\' field should be the expected value.'
        );
        System.assertEquals(
            status,
            autoEnrollmentMappingModel.status,
            'The \'status\' field should be the expected value.'
        );
        System.assertEquals(role, autoEnrollmentMappingModel.role, 'The \'role\' field should be the expected value.');
        System.assertEquals(
            active,
            autoEnrollmentMappingModel.active,
            'The \'active\' field should be the expected value.'
        );
    }
}
