/*
    Copyright (c) 2020, Salesforce.org
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
 * @date 2020
 * @group Relationships
 * @description Unmanaged tests for REL_Relationships_Con_TDTM to verify
 * auto creation functionality works as expected with multiple mappings.
 */
@isTest
private class REL_Relationships_Con_FTST {
    private static Integer loopCount = 250;

    /*********************************************************************************************************
     * @description Unpackaged test to verify that when Relationship Auto Creation is enabled, and multiple
     * mappings exist, inserting a Contact record with all Auto Creation mapped fields populated generates
     * relationship  and reciprocal relationship records for each mapped field.
     *********************************************************************************************************/
    @isTest
    private static void insertContactWithMultipleAutoCreateMappingsAllPopulated() {
        REL_Relationships_Con_FTST.setupMultipleAutoCreateRelationships();

        Contact relatedContact = hed.UTIL_UnitTestData_API.getMultipleTestContacts(1)[0];
        relatedContact.FirstName = 'Test';
        relatedContact.LastName = 'Related';
        insert relatedContact;

        Contact employerContact = hed.UTIL_UnitTestData_API.getMultipleTestContacts(1)[0];
        employerContact.FirstName = 'Test';
        employerContact.LastName = 'Employer';
        insert employerContact;

        List<Contact> contactsList = hed.UTIL_UnitTestData_API.getMultipleTestContacts(loopCount);
        for (Integer i = 0; i < contactsList.size(); i++) {
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].ReportsToId = relatedContact.Id;
            contactsList[i].Employer__c = employerContact.Id;
        }

        Test.startTest();
        insert contactsList;
        Test.stopTest();

        List<hed__Relationship__c> relationshipResultsList = [
            SELECT Id, hed__Contact__c, hed__RelatedContact__c, hed__Status__c, hed__Type__c
            FROM hed__Relationship__c
            WHERE hed__Contact__c IN :contactsList OR hed__Contact__c = :relatedContact.Id OR hed__Contact__c = :employerContact.Id
        ];

        Map<Id, List<hed__Relationship__c>> relationshipsListByContactId = new Map<Id, List<hed__Relationship__c>>();
        for (hed__Relationship__c rel : relationshipResultsList) {
            List<hed__Relationship__c> currentConRelationshipsList = relationshipsListByContactId.get(rel.hed__Contact__c);

            if (currentConRelationshipsList == null) {
                currentConRelationshipsList = new List<hed__Relationship__c>();
            }
            currentConRelationshipsList.add(rel);

            relationshipsListByContactId.put(rel.hed__Contact__c, currentConRelationshipsList);
        }

        for (Id conId : relationshipsListByContactId.keySet()) {
            List<hed__Relationship__c> relationshipsList = relationshipsListByContactId.get(conId);

            if (employerContact.Id == conId) {
                System.assertEquals(
                    loopCount,
                    relationshipsList.size(),
                    'There should be ' +
                    loopCount +
                    ' reciprocal relationship created for the employer contact.'
                );
                System.assertEquals(
                    'Employee',
                    relationshipsList[0].hed__Type__c,
                    'Relationships should be of type Employee.'
                );
                System.assertEquals('Current', relationshipsList[0].hed__Status__c, 'Relationships should be current.');
            } else if (relatedContact.Id == conId) {
                System.assertEquals(
                    loopCount,
                    relationshipsList.size(),
                    'There should be ' +
                    loopCount +
                    ' reciprocal relationship created for the relatedTo contact.'
                );
                System.assertEquals('Testee', relationshipsList[0].hed__Type__c, 'Relationships should be of type Testee.');
                System.assertEquals('Current', relationshipsList[0].hed__Status__c, 'Relationships should be current.');
            } else {
                System.assertEquals(
                    2,
                    relationshipsList.size(),
                    'There should be 2 relationships created for the main contact.'
                );
                for (hed__Relationship__c rel : relationshipsList) {
                    System.assertEquals('Current', rel.hed__Status__c, 'Relationship should be current.');

                    if (rel.hed__Type__c == 'Employer') {
                        System.assertEquals(
                            employerContact.Id,
                            rel.hed__RelatedContact__c,
                            'Employer contact should be associated with relationship of type Employer.'
                        );
                    } else {
                        System.assertEquals(
                            relatedContact.Id,
                            rel.hed__RelatedContact__c,
                            'RelatedTo contact should be associated with relationship of type Tester.'
                        );
                    }
                }
            }
        }
    }

    /*********************************************************************************************************
     * @description Unpackaged test to verify that when Relationship Auto Creation is enabled, and multiple
     * mappings exist, inserting a Contact record some Auto Creation mapped fields populated generates
     * relationship and reciprocal relationship records only for the populated mapped fields.
     *********************************************************************************************************/
    @isTest
    private static void insertContactWithMultipleAutoCreateMappingsSomePopulated() {
        REL_Relationships_Con_FTST.setupMultipleAutoCreateRelationships();

        Contact employerContact = hed.UTIL_UnitTestData_API.getMultipleTestContacts(1)[0];
        employerContact.FirstName = 'Test';
        employerContact.LastName = 'Employer';
        insert employerContact;

        List<Contact> contactsList = hed.UTIL_UnitTestData_API.getMultipleTestContacts(loopCount);
        for (Integer i = 0; i < contactsList.size(); i++) {
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].Employer__c = employerContact.Id;
        }

        Test.startTest();
        insert contactsList;
        Test.stopTest();

        List<hed__Relationship__c> relationshipResultsList = [
            SELECT Id, hed__Contact__c, hed__RelatedContact__c, hed__Status__c, hed__Type__c
            FROM hed__Relationship__c
            WHERE hed__Contact__c IN :contactsList OR hed__Contact__c = :employerContact.Id
        ];

        Map<Id, List<hed__Relationship__c>> relationshipsListByContactId = new Map<Id, List<hed__Relationship__c>>();
        for (hed__Relationship__c rel : relationshipResultsList) {
            List<hed__Relationship__c> currentConRelationshipsList = relationshipsListByContactId.get(rel.hed__Contact__c);

            if (currentConRelationshipsList == null) {
                currentConRelationshipsList = new List<hed__Relationship__c>();
            }
            currentConRelationshipsList.add(rel);

            relationshipsListByContactId.put(rel.hed__Contact__c, currentConRelationshipsList);
        }

        for (Id conId : relationshipsListByContactId.keySet()) {
            List<hed__Relationship__c> relationshipsList = relationshipsListByContactId.get(conId);

            if (employerContact.Id == conId) {
                System.assertEquals(
                    loopCount,
                    relationshipsList.size(),
                    'There should be ' +
                    loopCount +
                    ' reciprocal relationship created for the employer contact.'
                );
                System.assertEquals(
                    'Employee',
                    relationshipsList[0].hed__Type__c,
                    'Relationships should be of type Employee.'
                );
                System.assertEquals('Current', relationshipsList[0].hed__Status__c, 'Relationships should be current.');
            } else {
                System.assertEquals(
                    1,
                    relationshipsList.size(),
                    'There should be 1 relationship created for the main contact.'
                );
                for (hed__Relationship__c rel : relationshipsList) {
                    System.assertEquals('Current', rel.hed__Status__c, 'Relationship should be current.');
                    System.assertEquals('Employer', rel.hed__Type__c, 'Relationship record should be of type Employer.');
                    System.assertEquals(
                        employerContact.Id,
                        rel.hed__RelatedContact__c,
                        'Employer contact should be associated with relationship of type Employer.'
                    );
                }
            }
        }
    }

    /*********************************************************************************************************
     * @description Unpackaged test to verify that when Relationship Auto Creation is enabled, and multiple
     * mappings exist, inserting a Contact record without populating any of the mapped fields does not
     * generate any relationships records.
     *********************************************************************************************************/
    @isTest
    private static void insertContactWithMultipleAutoCreateMappingsNonePopulated() {
        REL_Relationships_Con_FTST.setupMultipleAutoCreateRelationships();

        List<Contact> contactsList = hed.UTIL_UnitTestData_API.getMultipleTestContacts(loopCount);
        for (Integer i = 0; i < contactsList.size(); i++) {
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
        }

        Test.startTest();
        insert contactsList;
        Test.stopTest();

        List<hed__Relationship__c> relationshipResultsList = [
            SELECT Id, hed__Contact__c, hed__RelatedContact__c, hed__Status__c, hed__Type__c
            FROM hed__Relationship__c
            WHERE hed__Contact__c IN :contactsList
        ];

        System.assertEquals(
            true,
            relationshipResultsList.isEmpty(),
            'There should be no relationship records generated for contacts inserted without mapped fields populated.'
        );
    }

    /*********************************************************************************************************
     * @description Helper method to create multiple Auto Creation settings and relationship mappings
     *********************************************************************************************************/
    private static void setupMultipleAutoCreateRelationships() {
        List<hed__Relationship_Auto_Create__c> relAutoCreateList = new List<hed__Relationship_Auto_Create__c>();

        hed__Relationship_Auto_Create__c contactReportToRelAutoCreate = new hed__Relationship_Auto_Create__c(
            Name = 'ConReportToAutoCreate',
            hed__Object__c = 'Contact',
            hed__Field__c = 'ReportsToId',
            hed__Relationship_Type__c = 'Tester',
            hed__Campaign_Types__c = ''
        );

        hed__Relationship_Auto_Create__c contactEmployerRelAutoCreate = new hed__Relationship_Auto_Create__c(
            Name = 'ConEmployerAutoCreate',
            hed__Object__c = 'Contact',
            hed__Field__c = 'Employer__c',
            hed__Relationship_Type__c = 'Employer',
            hed__Campaign_Types__c = ''
        );

        relAutoCreateList.add(contactReportToRelAutoCreate);
        relAutoCreateList.add(contactEmployerRelAutoCreate);
        insert relAutoCreateList;

        List<hed__Relationship_Lookup__c> relationshipLookupsList = new List<hed__Relationship_Lookup__c>();
        hed__Relationship_Lookup__c testerRelationshipLookup = new hed__Relationship_Lookup__c(
            Name = 'Tester',
            hed__Male__c = 'Testee-Male',
            hed__Female__c = 'Testee-Female',
            hed__Neutral__c = 'Testee'
        );

        hed__Relationship_Lookup__c testeeRelationshipLookup = new hed__Relationship_Lookup__c(
            Name = 'Testee',
            hed__Male__c = 'Tester-Male',
            hed__Female__c = 'Tester-Female',
            hed__Neutral__c = 'Tester'
        );

        hed__Relationship_Lookup__c employerRelationshipLookup = new hed__Relationship_Lookup__c(
            Name = 'Employer',
            hed__Male__c = 'Employee-Male',
            hed__Female__c = 'Employee-Female',
            hed__Neutral__c = 'Employee'
        );

        hed__Relationship_Lookup__c employeeRelationshipLookup = new hed__Relationship_Lookup__c(
            Name = 'Employee',
            hed__Male__c = 'Employer-Male',
            hed__Female__c = 'Employer-Female',
            hed__Neutral__c = 'Employer'
        );

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        relationshipLookupsList.add(employerRelationshipLookup);
        relationshipLookupsList.add(employeeRelationshipLookup);
        insert relationshipLookupsList;
    }
}
