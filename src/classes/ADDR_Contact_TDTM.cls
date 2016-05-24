/*
    Copyright (c) 2016, Salesforce.org
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
* @date 2016
* @group Addresses
* @group-content ../../ApexDocContent/Addresses.htm
* @description Trigger Handler on Contact for Address management. 
*/
public class ADDR_Contact_TDTM extends TDTM_Runnable {

    /* @description static flag to prevent recursive call */
    public static Boolean hasRunAddrTrigger = false;
    
    /*******************************************************************************************************
    * @description Trigger Handler on Contact that handles Address Management.
    *   Rules:
    *       inserting new contact - make their address a new default address, unless they say it is an override
    *       updating an existing contact - make their address a new default address, unless they say it is an override
    * @param listNew the list of Contacts from trigger new. 
    * @param listOld the list of Contacts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Contacts 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
            
         DmlWrapper dmlWrapper = new DmlWrapper();  
        List<Contact> listcontactCreateAddr = new List<Contact>();      
        List<Contact> listContactsAddrInfoCleared = new List<Contact>();
       
        Integer i = -1;        
        for (SObject so : listNew) {
            Contact contact = (Contact)so;
            i++;
            
            // AFTER INSERT
            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                // for new Contacts that are using address management, create the address object.
                if (UTIL_CustomSettingsFacade.getSettings().Contacts_Addresses_Enabled__c == true) {
                    if (!ADDR_Addresses_UTIL.isContactAddressEmpty(contact))
                        listcontactCreateAddr.add(contact);
                }
            }
    
            // AFTER UPDATE
            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {  
                // if address change is coming from the address trigger we don't want to create a new address   
                if (!ADDR_Addresses_TDTM.hasRunAddrTrigger) {
                    if (UTIL_CustomSettingsFacade.getSettings().Contacts_Addresses_Enabled__c == true) {
                        Contact contactOld = (Contact)listOld[i];
                        // if the address info has been removed
                        if(!ADDR_Addresses_UTIL.iscontactAddressEmpty(contactOld) && ADDR_Addresses_UTIL.iscontactAddressEmpty(contact))
                            listContactsAddrInfoCleared.add(contact);
                        // if the address changed, remember the Contact we want to add a new address for    
                        else if (ADDR_Addresses_UTIL.isContactAddressChanged(contact, contactOld)) 
                            listcontactCreateAddr.add(contact);
                    }
                }
            }                
        }

        // create any new Address objects
        if (listcontactCreateAddr.size() > 0)
            createAddrFromContact(listContactCreateAddr, dmlWrapper);
        
        // handle Contacts with address info removed
        if(listContactsAddrInfoCleared.size() > 0)
            addrInfoDeleted(listContactsAddrInfoCleared, dmlWrapper);
        
        hasRunAddrTrigger = true;
                            
        return dmlWrapper;
    }
    
    /*******************************************************************************************************
    * @description for each Contact, create a new default address and add it to dmlWrapper
    * @param Listcontact a List of Contacts
    * @param dmlWrapper to hold the Addresses that need creating
    * @return void
    ********************************************************************************************************/
    private void createAddrFromContact(List<Contact> listContact, DmlWrapper dmlWrapper) {
        List<Address__c> listAddr = new List<Address__c>();
        for (Contact contact : listContact) {
            Address__c addr = new Address__c();
            addr.Parent_Contact__c = contact.Id;
            addr.Default_Address__c = true;
            addr.Latest_Start_Date__c = system.today();
            addr.Latest_End_Date__c = null;
            ADDR_Addresses_UTIL.copyAddressStdSObjAddr(contact, 'Mailing', addr, null);            
            ListAddr.add(addr);
            UTIL_Debug.debug('****New address record: ' + JSON.serializePretty(addr));
        }
        //since coming from an Contact address, there is no Address Type, so exclude it from the match testing.
        List<Address__c> newAddrs = ADDR_Addresses_UTIL.createNonDuplicateAddresses(ListAddr, dmlWrapper, false);
        
        //Match each Contact with each new address
        List<ID> contactIDsToUpdate = new List<ID>();
        Map<ID, Address__c> parentcontactIdToAddrMap = new Map<ID, Address__c>();
        for(Address__c addr : newAddrs) {
            if(addr.Parent_Contact__c != null) {
               contactIDsToUpdate.add(addr.Parent_Contact__c);
               parentcontactIdToAddrMap.put(addr.Parent_Contact__c, addr);  
            }
        }
        
        //We need to re-query before we are in the "after" part of the trigger. We cannot change it to before because
        //we need the Contact ID to have a value when populating the addr.Parent_Contact__c field above.
        List<Contact> parentContacts = [select is_Address_Override__c, Current_Address__c from Contact where ID in :contactIDsToUpdate];
        List<Contact> ContactsToUpdate = new List<Contact>();
        for(Contact contact : parentContacts) {
            Address__c childAddr = parentcontactIdToAddrMap.get(contact.Id);
            if(childAddr != null && !contact.is_Address_Override__c) {
                contact.Current_Address__c = childAddr.Id;
                ContactsToUpdate.add(contact);
            }
        }
        update ContactsToUpdate;
    }
    
    private void addrInfoDeleted(List<Contact> listContactsAddrInfoCleared, DmlWrapper dmlWrapper) {
        List<ID> oldCurrentAddrIDs = new List<ID>();
        
        //We need to re-query before we are in the "after" part of the trigger
        List<Contact> Contacts = [select is_Address_Override__c, Current_Address__c from Contact where ID in :listContactsAddrInfoCleared];
        
        // clear Current_Address__c field from Contacts
        for(Contact contact : Contacts) {
            if(contact.Current_Address__c != null) // get all current addrs
                oldCurrentAddrIDs.add(contact.Current_Address__c);
            contact.Current_Address__c = null;
            contact.is_Address_Override__c = false;
            dmlWrapper.objectsToUpdate.add(contact); 
        }
        
        // clear Default_Address__c field from child addrs
        List<Address__c> addrs = [select Default_Address__c from Address__c where Default_Address__c = true and ID in :oldCurrentAddrIDs];
        for(Address__c addr : addrs) {
            addr.Default_Address__c = false;
            dmlWrapper.objectsToUpdate.add(addr);
        }
        //Don't run ADDR_Addresses_TDTM for these updated addresses
        ADDR_Addresses_TDTM.hasRunAddrTrigger = true;
    }
}