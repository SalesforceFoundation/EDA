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
* @date 2011 (1.x)
* @group Accounts
* @description Constants and helper methods used for common settings in npe01: account model, default contact role, etc. 
*/
public with sharing class CAO_Constants {

    /*******************************************************************************************************
    * @description Household Account value for system processor field
    */ 
    public static final String HH_ACCOUNT_PROCESSOR = 'Household Account';

    /*******************************************************************************************************
    * @description Household Account org type value
    */ 
    public static final String HH_ACCOUNT_TYPE = 'Household Account';

    /*******************************************************************************************************
    * @description Household Account value for the standard Type field
    */ 
    public static final string HH_TYPE = 'Household';

    /*******************************************************************************************************
    * @description A contact's firstname to use in test code.
    */ 
    public static  string CONTACT_FIRSTNAME_FOR_TESTS = 'test';

    /*******************************************************************************************************
    * @description A contact's lastname to use in test code.
    */ 
    public static  string CONTACT_LASTNAME_FOR_TESTS = 'Contact_forTests';

    /*******************************************************************************************************
    * @description A contact's email to use in test code.
    */ 
    public static  string CONTACT_EMAIL_FOR_TESTS = 'junk@test.net';

    /*******************************************************************************************************
    * @description A contact's preferred email to use in test code.
    */ 
    public static  string CONTACT_PREFERRED_EMAIL_FOR_TESTS = 'Work';

    /*******************************************************************************************************
    * @description A contact's phone number to use in test code.
    */ 
    public static  string CONTACT_PHONE_FOR_TESTS = '206-777-8888';

    /*******************************************************************************************************
    * @description A contact's preferred phone to use in test code.
    */ 
    public static  string CONTACT_PREFERRED_PHONE_FOR_TESTS = 'Work';
    
    /*******************************************************************************************************
    * @description The name to use for the Individual Bucket Account in test code.
    */ 
    public static  string INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS = 'IndividualAccountNameForTests';

    /*******************************************************************************************************
    * @description Returns whether we are in the Household Account Model
    * @return  boolean
    */ 
    public static boolean isHHAccountModel() {
        return (UTIL_CustomSettingsFacade.getContactsSettings().Account_Processor__c == HH_ACCOUNT_PROCESSOR);
    }
}