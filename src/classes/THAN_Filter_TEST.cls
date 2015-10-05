/*
    Copyright (c) 2014, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
* @author Salesforce.com Foundation
* @date 2015
* @group Affiliation Management
* @description Tests for the THAN_Filter_TDTM class. 
*/
@isTest
public with sharing class THAN_Filter_TEST {
    
    public static void insertHandlers() {
        insert TDTM_DefaultConfig.getDefaultRecords();
    }
    
    @isTest
    public static void invalidRelationship() { 
        insertHandlers();       
        Trigger_Handler__c handler = [select Filter_Field__c from Trigger_Handler__c where Class__c = 'REL_Relationships_Con_TDTM'];        
        handler.Filter_Field__c = 'Account.Parent.Nonsense';
        Test.startTest();
        try {
            update handler;
            System.assertEquals('We should never get here.', 'We got here.');
        } catch(DmlException e) {
            System.AssertEquals(true, e.getMessage().contains(Label.InvalidFilter));
        } 
        Test.stopTest();
        
        //Transaction should have been rolled back
        handler = [select Filter_Field__c from Trigger_Handler__c where Class__c = 'REL_Relationships_Con_TDTM'];
        System.assertEquals(null, handler.Filter_Field__c);
    }
    
    //Testing that saving valid relationships does not throw an error is done in TDTM_Filter_TEST.

}