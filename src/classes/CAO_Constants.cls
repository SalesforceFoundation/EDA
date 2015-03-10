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
    * @description One-to-One value for system processor field
    */ 
    public static final String ONE_TO_ONE_PROCESSOR = 'One-to-One';

    /*******************************************************************************************************
    * @description One-to-One org type value
    */ 
    public static final String ONE_TO_ONE_ORGANIZATION_TYPE = 'One-to-One Individual';

    /*******************************************************************************************************
    * @description Individual Bucket value for system processor field
    */ 
    public static final String BUCKET_PROCESSOR = 'Individual';

    /*******************************************************************************************************
    * @description Individual Bucket org type value
    */ 
    public static final String BUCKET_ORGANIZATION_TYPE = 'Bucket Individual';

    /*******************************************************************************************************
    * @description Individual Bucket Account name
    */ 
    public static String BUCKET_ACCOUNT_NAME = 'Individual';

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
    * @description Returns whether we are in the One-to-One Account Model
    * @return  boolean
    */ 
    public static boolean isOneToOne() {
        //if no settings exist, create defaults
        if (UTIL_CustomSettingsFacade.getContactsSettings().Account_Processor__c==ONE_TO_ONE_PROCESSOR) {
            return true;
        } else {
            return false;
        }
    }

    /*******************************************************************************************************
    * @description Returns whether we are in the Individual Bucket Account Model
    * @return  boolean
    */ 
    public static boolean isBucketModel() {
        return (UTIL_CustomSettingsFacade.getContactsSettings().Account_Processor__c == BUCKET_PROCESSOR);
    }

    /*******************************************************************************************************
    * @description Returns whether we are in the Household Account Model
    * @return  boolean
    */ 
    public static boolean isHHAccountModel() {
        return (UTIL_CustomSettingsFacade.getContactsSettings().Account_Processor__c == HH_ACCOUNT_PROCESSOR);
    }    

    /*******************************************************************************************************
    * @description The Salesforce Id of the Individual Bucket Account
    */ 
    public static Id IndividualAccountId;

    /*******************************************************************************************************
    * @description The name of the Individual Bucket Account
    */ 
    private static String IndividualAccountName = CAO_Constants.BUCKET_ACCOUNT_NAME;

    /*******************************************************************************************************
    * @description returns the Salesforce Id of the Individual Bucket Account
    * @return  Id
    */ 
    public static id getIndividualAccountId () {
    
        // look up the ID if we haven't already done it
        if ( IndividualAccountId == null ) {
            List<Account> acct = [select id,SYSTEMISINDIVIDUAL__c,SYSTEM_AccountType__c from account where Name =:IndividualAccountName LIMIT 1];
            if(acct.size()>0){
                if(acct[0].SYSTEMISINDIVIDUAL__c==false || acct[0].SYSTEM_AccountType__c<>CAO_Constants.BUCKET_ORGANIZATION_TYPE){
                    acct[0].SYSTEMISINDIVIDUAL__c = true;
                    acct[0].SYSTEM_AccountType__c = CAO_Constants.BUCKET_ORGANIZATION_TYPE;
                    update acct[0];
                }
                IndividualAccountId = acct[0].id;
            }
        }
        return IndividualAccountId;
    }

    /*******************************************************************************************************
    * @description Creates an Individual Bucket Account, for use in test code.
    * @return  Id of the Individual Bucket Account
    */ 
    public static Id setIndividualAccountForTests(String accountName) {
        //create a fake Individual Account for tests

        Account individualAccountForTests = new Account(
            Name=accountName,
            SYSTEMISINDIVIDUAL__c = true,
            SYSTEM_AccountType__c = CAO_Constants.BUCKET_ORGANIZATION_TYPE
        );
        
        insert individualAccountForTests;

        CAO_Constants.BUCKET_ACCOUNT_NAME = accountName;
        IndividualAccountName = accountName;

        return individualAccountForTests.id;
    }
}