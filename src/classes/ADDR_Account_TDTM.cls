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
* @date 2014
* @group Address Management
* @description Trigger Handler on Account for Address management 
*/
public class ADDR_Account_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Trigger Handler on Account that handles Address management.
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Accounts 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
            
        DmlWrapper dmlWrapper = new DmlWrapper();  
        list<Account> listAccCreateAddr = new list<Account>();      
       
        integer i = -1;        
        for (SObject so : listNew) {
            Account acc = (Account)so;
            i++;

            // BEFORE INSERT
            if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
            }
            
            // BEFORE UPDATE
            if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
            }
            
            // AFTER INSERT
            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                // for new accounts that are using address management, create the address object.
                if (acc.SYSTEM_AccountType__c != CAO_Constants.HH_ACCOUNT_PROCESSOR && acc.SYSTEM_AccountType__c != CAO_Constants.ADM_ACCOUNT_PROCESSOR && 
                UTIL_CustomSettingsFacade.getSettings().Organizational_Account_Addresses_Enabled__c) {
                    if (isAccountAddressSpecified(acc))
                        listAccCreateAddr.add(acc);
                }
            }
    
            // AFTER UPDATE
            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                Account accOld = (Account)listOld[i];
                // note that we detect whether the address change is coming from the address trigger,
                // in which case we don't want to create a new address.
                if (ADDR_Addresses_TDTM.hasRunAddrTrigger) {
                    continue;
                }
                // we only support address management with HH Accounts and Organizational Accounts (if enabled)
                if (((acc.SYSTEM_AccountType__c == CAO_Constants.HH_ACCOUNT_PROCESSOR || acc.SYSTEM_AccountType__c == CAO_Constants.ADM_ACCOUNT_PROCESSOR) && 
                UTIL_CustomSettingsFacade.getSettings().Household_Adm_Acct_Addresses_Enabled__c) || 
                (acc.SYSTEM_AccountType__c != CAO_Constants.HH_ACCOUNT_PROCESSOR && acc.SYSTEM_AccountType__c != CAO_Constants.ADM_ACCOUNT_PROCESSOR && 
                UTIL_CustomSettingsFacade.getSettings().Organizational_Account_Addresses_Enabled__c)) {
                    // if the address changed, remember the account we want to add a new address for    
                    if (isAccountAddressChanged(acc, accOld)) 
                        listAccCreateAddr.add(acc);
                }
            }                
        }

        // create any new Address objects
        if (listAccCreateAddr.size() > 0)
            createAddrFromAcc(listAccCreateAddr, dmlWrapper);
                    
        return dmlWrapper;    
    }
    
    /*******************************************************************************************************
    * @description utility to see if an address is specified
    * @param acc1 an Account
    * @return boolean.  true if an address is specified in any of the Account Billing fields
    ********************************************************************************************************/
    private boolean isAccountAddressSpecified(Account acc1) {
        if (acc1 == null) 
           return false;
        
        boolean isSpecified = 
           acc1.BillingStreet != null ||
           acc1.BillingCity != null ||
           acc1.BillingState != null ||
           acc1.BillingPostalCode != null ||
            // note that we decided to ignore country so that a default value won't create unnecessary address objects
           (acc1.BillingCountry != null && !ADDR_Addresses_TDTM.isStateCountryPicklistsEnabled) ||
           // only test StateCode if picklists enabled.
           (ADDR_Addresses_TDTM.isStateCountryPicklistsEnabled && acc1.get('BillingStateCode') != null);

        return isSpecified;   
    }

    /*******************************************************************************************************
    * @description utility to compare two Accounts' (billing) addresses
    * @param acc1 an Account
    * @param acc2 an Account
    * @return boolean. true if there are any changes between the two accounts.
    ********************************************************************************************************/
    private boolean isAccountAddressChanged(Account acc1, Account acc2) {
        if (acc1 == null || acc2 == null) 
           return false;
        
        boolean isChanged = 
           !ADDR_Addresses_TDTM.equalsCaseSensitive(acc1.BillingStreet, acc2.BillingStreet) ||
           !ADDR_Addresses_TDTM.equalsCaseSensitive(acc1.BillingCity, acc2.BillingCity) ||
           !ADDR_Addresses_TDTM.equalsCaseSensitive(acc1.BillingState, acc2.BillingState) ||
           !ADDR_Addresses_TDTM.equalsCaseSensitive(acc1.BillingPostalCode, acc2.BillingPostalCode) ||
           !ADDR_Addresses_TDTM.equalsCaseSensitive(acc1.BillingCountry, acc2.BillingCountry);

        if (!isChanged && ADDR_Addresses_TDTM.isStateCountryPicklistsEnabled) {
            isChanged = 
                !ADDR_Addresses_TDTM.equalsCaseSensitive(string.valueOf(acc1.get('BillingStateCode')), string.valueOf(acc2.get('BillingStateCode'))) || 
                !ADDR_Addresses_TDTM.equalsCaseSensitive(string.valueOf(acc1.get('BillingCountryCode')), string.valueOf(acc2.get('BillingCountryCode')));
        }
        UTIL_Debug.debug('****Address changed: ' + isChanged);
        return isChanged;   

    }

    /*******************************************************************************************************
    * @description for each Account, create a new default address and add it to dmlWrapper
    * @param listAcc a list of Accounts
    * @param dmlWrapper to hold the Addresses that need creating
    * @return void
    ********************************************************************************************************/
    private void createAddrFromAcc(list<Account> listAcc, DmlWrapper dmlWrapper) {
        list<Address__c> listAddr = new list<Address__c>();
        for (Account acc : listAcc) {
            Address__c addr = new Address__c();
            addr.Parent_Account__c = acc.Id;
            addr.Default_Address__c = true;
            addr.Latest_Start_Date__c = system.today();
            addr.Latest_End_Date__c = null;
            ADDR_Addresses_TDTM.copyAddressStdSObjAddr(acc, 'Billing', addr, null);            
            listAddr.add(addr);         
        }
        // since coming from an account address, there is no Address Type, so exclude it from the match testing.
        ADDR_Addresses_TDTM.createNonDuplicateAddresses(listAddr, dmlWrapper, false);
    }

}