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
* @group Addresses
* @group-content ../../ApexDocContent/Addresses.htm
* @description Stops an Address from being deleted if it has any Account or Contact child records. 
*/
public with sharing class ADDR_CannotDelete_TDTM extends TDTM_Runnable {
    /*******************************************************************************************************
    * @description Get the setting of preventing Address deletion
    */
    private static Boolean enabledPreventAddressDeletion = UTIL_CustomSettingsFacade.getSettings().Prevent_Address_Deletion__c;
    
    /*******************************************************************************************************
    * @description Stops an Address from being deleted if it has any Account or Contact child records. 
    * @param newlist the list of Addresses from trigger new. 
    * @param oldlist the list of Addresses from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Addresses 
    * @return DmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        if (ADDR_CannotDelete_TDTM.enabledPreventAddressDeletion == FALSE) {
            return new DmlWrapper(); 
        }
        
        Map<ID, Address__c> oldmap = new Map<ID, Address__c>((List<Address__c>)oldList);
        
        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            for (Address__c addr : [
                                    SELECT Id, 
                                        (SELECT Id FROM Address__c.Accounts__r LIMIT 1),
                                        (SELECT Id FROM Address__c.Contacts1__r LIMIT 1)
                                    FROM Address__c WHERE Id IN :oldlist
                                    
                                ]) {
                
                if (this.hasChildRecords(addr)) {
                    Address__c addressInContext = oldMap.get(addr.ID);
                    addressInContext.addError(Label.CannotDelete);
                }
            }     
        }

        return new DmlWrapper();
    }
    
    /*******************************************************************************************************
     * @description Evaluates whether the Address has any child (Account or Contact) related records.
     * @param addr is the current Address record.
     * @return Boolean.
     ********************************************************************************************************/
    @testVisible
    private Boolean hasChildRecords(Address__c addr) {
        
        return ( addr.Accounts__r.isEmpty() == FALSE || addr.Contacts1__r.isEmpty() == FALSE ); 
    
    }
}