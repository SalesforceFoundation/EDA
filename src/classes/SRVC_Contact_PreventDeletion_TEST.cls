/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group 
* @group-content ../../ApexDocContent/
* @description Test class for SRVC_Contact_PreventDeletion
*/
@isTest
private class SRVC_Contact_PreventDeletion_TEST {

    // Tests getInstance()
    @isTest
    static void testGetInstance() {
        SRVC_Contact_PreventDeletion srvcConPreventDeleteInstance = SRVC_Contact_PreventDeletion.getInstance();
        System.assertEquals(SRVC_Contact_PreventDeletion.instance, srvcConPreventDeleteInstance);
        System.assertNotEquals(NULL, srvcConPreventDeleteInstance);

        srvcConPreventDeleteInstance = SRVC_Contact_PreventDeletion.getInstance();
        System.assertEquals(SRVC_Contact_PreventDeletion.instance, srvcConPreventDeleteInstance);
    }

    // Tests Prevent Deletion for Contacts with STUB_AlwaysHasChildRelationships
    @isTest
    static void testPreventDeletionForContactsWithChildren() {
        SRVC_Contact_PreventDeletion.instance = new STUB_AlwaysHasChildRelationships();

        Map<Id,Contact> contactById = new Map<Id,Contact>();
        List<Contact> contactsWithErrorsList = SRVC_Contact_PreventDeletion.getInstance().PreventDeletionForContacts(
            contactById
        );

        System.assertEquals(contactById.values().size(), contactsWithErrorsList.size());

        for (Contact contactToCheck : contactsWithErrorsList) {
            System.assert(contactById.get(contactToCheck.Id) != null);
        }
    }

    // Tests Prevent Deletion for Contacts with STUB_DoesNotHaveChildRelationships
    @isTest
    static void testPreventDeletionForContactsWithNoChildren() {
        SRVC_Contact_PreventDeletion.instance = new STUB_DoesNotHaveChildRelationships();

        Map<Id,Contact> contactById = new Map<Id,Contact>();
        List<Contact> contactsWithErrorsList = SRVC_Contact_PreventDeletion.getInstance().PreventDeletionForContacts(
            contactById
        );

        System.assertEquals(0, contactsWithErrorsList.size());
        for (Contact contactToCheck : contactsWithErrorsList) {
            System.assert(contactById.get(contactToCheck.Id) == null);
        }
    }
    
    @isTest
    static void poisitveIntegrationTestForpreventDeletionForContacts() {


    }

    @isTest
    static void negativeIntegrationTestForpreventDeletionForContacts() {


    }

    @isTest
    static void positiveIntegrationTestForGetContactsAndChildRelationships() {


    }

    @isTest
    static void negativeIntegrationTestForGetContactsAndChildRelationships() {


    }

    @isTest
    static void positiveIntegrationTestForContactHasChildRecords() {


    }

    @isTest
    static void negativeIntegrationTestForContactHasChildRecords() {


    }

    // STUB class which extends SRVC_Contact_PreventDeletion
    private class STUB_AlwaysHasChildRelationships extends SRVC_Contact_PreventDeletion {

        @TestVisible
        protected override Boolean contactHasChildRecords(Contact con) {
            return true;
        }
    }
    
    // STUB class which extends SRVC_Contact_PreventDeletion
    private class STUB_DoesNotHaveChildRelationships extends SRVC_Contact_PreventDeletion {

        @TestVisible
        protected override Boolean contactHasChildRecords(Contact con) {
            return false;
        }
    }
}