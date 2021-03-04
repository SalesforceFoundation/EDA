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
* @group-content ../../ApexDocContent/Relationships
* @description Test class for ContactRelationshipsModel. 
*/
@isTest
private with sharing class ContactRelAutoCreateMappingModel_TEST {

    /**************************************************************************************************************************
    * @description Tests the constructor for ContactRelAutoCreateMappingModel
    **************************************************************************************************************************/
    @isTest 
    private static void constructor() {
        Schema.DescribeFieldResult contactField = UTIL_Describe.getFieldDescribe('contact', 'LastName');
        String relationshipType = 'testType';
        String settingsContactValue = 'testSettingsContactValue';

        ContactRelAutoCreateMappingModel model = new ContactRelAutoCreateMappingModel(
            contactField, relationshipType, settingsContactValue
        );

        System.assertEquals(contactField.getName(),model.contactFieldApiName,'Model\'s Contact Field API Name should equal the field\'s api name.');
        System.assertEquals(contactField.getLabel(),model.contactFieldLabel,'Model\'s Contact Field Label should equal the field\'s label.');
        System.assertEquals(relationshipType,model.relationshipType,'Model\'s relationship type should equal the exact relationship type provided.');
        System.assertEquals(settingsContactValue,model.settingsContactFieldValue,'Model\'s settings contact value should equal the exact settings contact value.');
    }
}