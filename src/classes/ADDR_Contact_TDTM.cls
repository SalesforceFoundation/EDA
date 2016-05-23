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
* @description Trigger Handler on Contact for Address management. 
*/
public class ADDR_Contact_TDTM extends TDTM_Runnable {

    public static Boolean contactsUpdatedAfterInsert = false;
    
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
        list<Contact> listConAddrSet = new list<Contact>(); 
        list<Contact> listConCreateAddr = new list<Contact>();
        map<Id, boolean> mapAddrIdIsOverride = new map<Id, boolean>();
        list<Contact> listConAddrReset = new list<Contact>();
                
        // Rules:
        // inserting new contact - make their address a new default address, unless they say it is an override
        // updating an existing contact - make their address a new default address, unless they say it is an override
               
        integer i = -1;        
        for (SObject so : listNew) {
            i++;  
            Contact con = (Contact)so;              

            // BEFORE INSERT
            if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
                if (con.Current_Address__c != null) {
                    // remember which contacts will need their address set
                    listConAddrSet.add(con);
                    if (con.is_Address_Override__c) {
                        // track which address's need their dates updated
                        mapAddrIdIsOverride.put(con.Current_Address__c, true);
                    }
                }
            }
            
            // BEFORE UPDATE
            if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
                // there can be four different types of changes we need to consider
                // A. changes to isAddressOverride
                // B. changes to CurrentAddress
                // C. changes to MailingAddress fields
                //
                // that leads to 8 permutations! 
                // (it's actually more permutations, since we need to take into account what
                // the change in isAddressOverride or CurrentAddress is).
                //
                // A,B,C       if (CurrentAddress) refill to it, else update/new address object     
                // A,!B,!C     if !isAddrOverride, refill contact from Default Address
                // A,!B,C      if isAddrOverride, update/new addr object and refresh CurrentAddress, else update/new address object
                // A,B,!C      if (CurrentAddress) refill to it, else refill from Default Address
                // !A,B,C      if (CurrentAddress) refill to it, else update/new address object
                // !A,!B,C     update/new address object
                // !A,B,!C     if (CurrentAddress) refill to it, else refill from Default Address
                // !A,!B,!C    nothing!
                //
                // simplifying this to some precedence rules:
                //     - if CurrentAddress changes to a new non-null value, refill to it.
                //     - if isAddressOverride changes to false, refill from Default Address
                //     - if MailingAddress field changes, update/new address object
                
                Contact conOld = (Contact)listOld[i];
  
                // highest priority. if they are changing to a new Current Address, refill from it.
                if (con.Current_Address__c != conOld.Current_Address__c && con.Current_Address__c != null) {
                    listConAddrSet.add(con);
                    if (con.is_Address_Override__c)
                        // track which address's need their dates updated
                        mapAddrIdIsOverride.put(con.Current_Address__c, true);                    
                }
                
                // second priority.  if they are clearing isAddressOverride, refill from the Default Address
                if (con.is_Address_Override__c != conOld.is_Address_Override__c && !con.is_Address_Override__c) {
                    listConAddrReset.add(con);
                    if (conOld.Current_Address__c != null)
                        // track which address's need their dates updated
                        mapAddrIdIsOverride.put(conOld.Current_Address__c, false);
                }
                
                // third priority.  if MailingAddress fields changed, update the existing address object or create a new one.
                // this is handled in the next block, since we do it for both new contacts and updated contacts.                            
            }
    
            // BEFORE UPDATE & AFTER UPDATE & BEFORE INSERT && AFTER INSERT
            // our functionality for dealing with contact address changes requires some trickery!
            // if the contact doesn't have an address override, we create (or match) a default address,
            // which requires us to do the work in the AfterUpdate (or else we can't propagate the default address).
            // but if the contact has an address override, we are supposed to create (or match) a non default address override.
            // in order to update the contact with the new address override's Id, we have to do it in the BeforeUpdate.
            if (triggerAction == TDTM_Runnable.Action.BeforeUpdate || triggerAction == TDTM_Runnable.Action.BeforeInsert ||  
               triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                // note that we detect whether the address change is coming from the address trigger,
                // in which case we don't want to create a new address.
                if (ADDR_Addresses_TDTM.hasRunAddrTrigger) {
                    //UTIL_Debug.debug('**** stop Addr Trigger recursion in ADDR_Contact_TDTM');
                    continue;
                }

                // if the address changed, remember the contact we want to add a new address for    
                Contact conOld = (listOld != null ? (Contact)listOld[i] : null);
                if (ADDR_Addresses_UTIL.isContactAddressChanged(con, conOld, contactsUpdatedAfterInsert)) 
                    listConCreateAddr.add(con);
            }             
        }
        
        // set the mailing address for contacts who specify an address lookup or override
        if (listConAddrSet.size() > 0) {
            setConAddrFromLookup(listConAddrSet);
            // to avoid pushing these address changes to the HH.
            ADDR_Addresses_TDTM.hasRunAddrTrigger = true;
        }
        
        // update the Latest date fields on any address overrides
        if (mapAddrIdIsOverride.size() > 0) 
            updateAddrIsOverride(mapAddrIdIsOverride, dmlWrapper);
            
        // create any new Default Address objects
        if (listConCreateAddr.size() > 0)
            createAddrFromCon(listConCreateAddr, dmlWrapper, triggerAction);
            
        return dmlWrapper;    
    }

    /*******************************************************************************************************
    * @description for each contact, refresh its mailing address from its Address lookup
    * @param listCon the list of Contacts to update
    * @return void  
    ********************************************************************************************************/
    private void setConAddrFromLookup(list<Contact> listCon) {
        set<Id> setAddrId = new set<Id>();
        for (Contact con : listCon) {
            if (con.Current_Address__c != null)
              setAddrId.add(con.Current_Address__c);
        }
    
        map<Id, Address__c> mapAddrIdAddr = new map<Id, Address__c>([select Id, Address_Type__c, MailingStreet__c, 
            MailingStreet2__c, MailingCity__c, MailingState__c, Geolocation__Latitude__s, Geolocation__Longitude__s, 
            MailingPostalCode__c, MailingCountry__c from Address__c where Id in :setAddrId]);
            
        for (Contact con : listCon) {
            Address__c addr = mapAddrIdAddr.get(con.Current_Address__c);
            if (addr != null) {
                con.Primary_Address_Type__c = addr.Address_Type__c;
                ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, con, 'Mailing', 'Primary_Address_Type__c');
            }
        }       
    }
       
    /*******************************************************************************************************
    * @description Creates a new address or matches an existing one, for each Contact.
    * This routine is called both by BeforeInsert/Update and AfterInsert/Update.
    * when pushing a new default address, we need to do it in the AfterInsert/Update.
    * otherwise we want to do it in the BeforeInsert/Update so we can update the contacts' info now.
    * @param listConAll the list of Contacts
    * @param dmlWrapper to hold the Addresses that need inserting/updating 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @return void  
    ********************************************************************************************************/
    private void createAddrFromCon(list<Contact> listConAll, DmlWrapper dmlWrapper,  TDTM_Runnable.Action triggerAction) {
        
        // Strategy:
        // create a new (unsaved) address for each contact.
        // see if there is an existing address that matches each new address.
        // 
        // for existing addresses we match
        //     process during BeforeInsert/Update
        //     update appropriate fields on contact
        //
        // for new addresses that won't be a default (ie, the contact has override set)
        //     process during BeforeInsert/Update
        //     create the address now
        //     update appropriate fields on contact
        //
        // for new addresses that will be a default address
        //     process during AfterInsert/Update
        //     mark the new address as default
        //     put it on dmlWrapper
        //
        
        map<Contact, Address__c> mapConAddr = new map<Contact, Address__c>();
        list<Contact> listCon = new list<Contact>();
        boolean isBefore = (triggerAction == TDTM_Runnable.Action.BeforeInsert || triggerAction == TDTM_Runnable.Action.BeforeUpdate);
        
        for (Contact con : listConAll) {
            listCon.add(con);
            Address__c addr = new Address__c();
            //addr.Parent_Account__c = con.AccountId; //TODO: do we still need this?
            //addr.Default_Address__c = !con.is_Address_Override__c;
            addr.Latest_Start_Date__c = system.today();
            addr.Latest_End_Date__c = null;         
            ADDR_Addresses_UTIL.copyAddressStdSObjAddr(con, 'Mailing', addr, con.Primary_Address_Type__c);
            mapConAddr.put(con, addr);
        }

        // look for duplicates for our proposed new addresses        
        map<Address__c, Address__c> mapAddrDupAddr = ADDR_Addresses_UTIL.findDuplicateAddresses(mapConAddr.values());
        
        // maps & lists to keep track of the addresses we must insert or update
        map<Contact, Address__c> mapConAddrInsertNow = new map<Contact, Address__c>();
        list<Address__c> listAddrUpdateDefault = new list<Address__c>();
        list<Address__c> listAddrInsertDefault = new list<Address__c>();
        
        for (Contact con : listCon) {
            Address__c addrNew = mapConAddr.get(con);
            Address__c addrDup = mapAddrDupAddr.get(addrNew);
            
            // if found a match
            if (addrDup != null) {
                // record the match in the contact
                if (isBefore) {
                    con.Current_Address__c = addrDup.Id;
                    con.Primary_Address_Type__c = addrDup.Address_Type__c; 
                } else {                    
                    // if it is a fuzzy match, not exact, then we want to update the existing address.
                    if (ADDR_Addresses_UTIL.isAddressChanged(addrNew, addrDup, false)) {
                        ADDR_Addresses_UTIL.copyAddressObj(addrNew, addrDup);
                        if (!con.is_Address_Override__c && !addrDup.Default_Address__c)
                            addrDup.Default_Address__c = true;
                            listAddrUpdateDefault.add(addrDup);
                    }                  
                    // exact match. we aren't specifying override, so the address should become the new hh default address
                    else if (!con.is_Address_Override__c && !addrDup.Default_Address__c) {
                        addrDup.Default_Address__c = true;
                        listAddrUpdateDefault.add(addrDup);
                    }
                }
            }

            // no match found, and its an override just for this contact
            else if (isBefore && con.is_Address_Override__c) {
                // put it on the list of addresss to create now
                mapConAddrInsertNow.put(con, addrNew);          
            }
            
            // no match, not an override, make it a new default hh address
            else if (!isBefore) {
                addrNew.Default_Address__c = true;
                listAddrInsertDefault.add(addrNew);                
            }
        }
        
        if (mapConAddrInsertNow.size() > 0 && isBefore) {
            insert mapConAddrInsertNow.values();
            for (Contact con : mapConAddrInsertNow.keySet()) {
                Address__c addr = mapConAddrInsertNow.get(con);
                con.Current_Address__c = addr.Id;
            }        
        }    
        
        if (listAddrUpdateDefault.size() > 0 && !isBefore) {
            for (Address__c addr : listAddrUpdateDefault)
                dmlWrapper.objectsToUpdate.add(addr);
        }
            
        if (listAddrInsertDefault.size() > 0 && !isBefore) {
            dmlWrapper.objectsToInsert.addAll((list<SObject>)listAddrInsertDefault);
        }
    }

    /*******************************************************************************************************
    * @description Updates the Latest date fields on any address overrides
    * @param mapAddrIdIsOverride map of Address Id's to an isOverride boolean
    * @param dmlWrapper to hold the Addresses that need updating 
    * @return void  
    ********************************************************************************************************/
    private void updateAddrIsOverride(Map<Id, boolean> mapAddrIdIsOverride, DmlWrapper dmlWrapper) {

        for (ID id : mapAddrIdIsOverride.keySet()) {
            Address__c addr = new Address__c();
            addr.Id = id;
            if (mapAddrIdIsOverride.get(id) == true) {
                addr.Latest_Start_Date__c = system.today();
                addr.Latest_End_Date__c = null;
            } else {
                addr.Latest_End_Date__c = system.today();
            }
            dmlWrapper.objectsToUpdate.add(addr);
        }        
    }
}