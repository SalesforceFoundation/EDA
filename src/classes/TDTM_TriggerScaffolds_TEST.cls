/*
    Copyright (c) 2009, Salesforce.org
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
* @date 2014
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description Tests that just verify exceptions aren't thrown for Objects where
* we don't have TDTM classes.
*/
@isTest
private class TDTM_TriggerScaffolds_TEST {

    public static testmethod void tdtmLead() {
        //Currently we don't have any Trigger_Handler__c record for Lead. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Lead(Company = 'Pencil Makers', LastName = 'Smith');

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmTask() {
        //Currently we don't have any Trigger_Handler__c record for Task. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Task();

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmEvent() {
        //Currently we don't have any Trigger_Handler__c record for Event. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Event(DurationInMinutes = 60, ActivityDateTime = DateTime.now());

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmCampaign() {
        //Currently we don't have any Trigger_Handler__c record for Campaign. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Campaign(Name = 'Test');

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmApplication() {
        //Currently we don't have any Trigger_Handler__c record for Application. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Application__c();

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmAttribute() {
        //Currently we don't have any Trigger_Handler__c record for Attribute. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Attribute__c(Name = 'Test');

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmBehavior_Involvement() {
        //Currently we don't have any Trigger_Handler__c record for Behavior_Involvement. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Behavior_Involvement__c();

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmBehavior_Response() {
        //Currently we don't have any Trigger_Handler__c record for Behavior_Response. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Behavior_Response__c();

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmCase() {
        //Currently we don't have any Trigger_Handler__c record for Case. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Case();

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmEducation_History() {
        //Currently we don't have any Trigger_Handler__c record for Education History. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Education_History__c();

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmFacility() {
        //Currently we don't have any Trigger_Handler__c record for Facility. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Facility__c(Capacity__c = 50);

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmLanguage() {
        //Currently we don't have any Trigger_Handler__c record for Language. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Language__c(Name = 'Spanish');

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmTest() {
        //Currently we don't have any Trigger_Handler__c record for Test. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Test__c();

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmTest_Score() {
        //Currently we don't have any Trigger_Handler__c record for Test Score. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new Test_Score__c();

        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

    public static testmethod void tdtmContentDocumentLink() {
        //Currently we don't have any Trigger_Handler__c record for ContentDocumentLink. This test is
        //just for test coverage, and to verify no exception gets thrown.
        insert new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data')
        );
        Application__c a = new Application__c();
        insert a;
        Id cdId = [Select Id from ContentDocument Limit 1].Id;
        Test.startTest();
        insert new ContentDocumentLink(ContentDocumentId = cdId, LinkedEntityId = a.Id);
        Test.stopTest();
       
        System.assert(true, 'No exception thrown'); //Just checking that we get to this point = no exception thrown
    }

}
