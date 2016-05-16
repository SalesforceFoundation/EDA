/*
    Copyright (c) 2014, Salesforce.org
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
* @group Addresses
* @group-content ../../ApexDocContent/Addresses.htm
* @description Trigger Handler on Account for Address management. Creates Address__c record from Account.
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
            
            // AFTER INSERT
            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                // for new accounts that are using address management, create the address object.
                if (UTIL_CustomSettingsFacade.getSettings().Accounts_Addresses_Enabled__c != null && acc.RecordTypeId != null
                && UTIL_CustomSettingsFacade.getSettings().Accounts_Addresses_Enabled__c.contains(acc.RecordTypeId)) {
                    if (ADDR_Addresses_UTIL.isAccountAddressSpecified(acc))
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
                if (UTIL_CustomSettingsFacade.getSettings().Accounts_Addresses_Enabled__c != null && acc.RecordTypeId != null
                && UTIL_CustomSettingsFacade.getSettings().Accounts_Addresses_Enabled__c.contains(acc.RecordTypeId)) {
                    // if the address changed, remember the account we want to add a new address for    
                    if (ADDR_Addresses_UTIL.isAccountAddressChanged(acc, accOld)) 
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
            ADDR_Addresses_UTIL.copyAddressStdSObjAddr(acc, 'Billing', addr, null);            
            listAddr.add(addr);         
        }
        // since coming from an account address, there is no Address Type, so exclude it from the match testing.
        ADDR_Addresses_UTIL.createNonDuplicateAddresses(listAddr, dmlWrapper, false);
    }

}