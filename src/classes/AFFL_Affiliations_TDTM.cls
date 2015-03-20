/*
    Copyright (c) 2009, Salesforce.com Foundation
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
* @date 2009
* @group Affiliations
* @group-content ../../ApexDocContent/Affiliations.htm
* @description  Trigger handler for Affiliations related operations on Contacts, Accounts, or Affiliations.
*/
public class AFFL_Affiliations_TDTM extends TDTM_Runnable {

    // static flags to prevent recursive call 
    public static boolean hasRunForContacts = false;
    public static boolean hasRunForAffiliations = false;
    public static boolean hasRunForAccounts = false;

    /*******************************************************************************************************
    * @description Trigger Handler on Contact, Account, or Affiliation, dispatches to the correct method
    * based on object type.
    * @param listNew the list of contacts, accounts, or affiliations from trigger new. 
    * @param listOld the list of contacts, accounts, or affiliations from trigger old. 
    * @param triggerAction Which action triggered the current context. (Before or After; Insert, Update, 
    * Delete, or Undelete.)
    * @param objResult The field describe object for the current trigger context. 
    * @return dmlWrapper Objects that need to be inserted or updated after the processing of the trigger.
    ********************************************************************************************************/    
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
            
        // dispatch to the correct handler
        if (objResult.getsObjectType() == Contact.sObjectType && !hasRunForContacts) {
            DmlWrapper wrapper = runContactTriggerHandler(newlist, oldlist, triggerAction, objResult);
            hasRunForContacts = true;
            return wrapper;
        } else if (objResult.getsObjectType() == Affiliation__c.sObjectType && !hasRunForAffiliations) {
            DmlWrapper wrapper = runAfflTriggerHandler(newlist, oldlist, triggerAction, objResult);
            hasRunForAffiliations = true;
            return wrapper;
        } else if (objResult.getsObjectType() == Account.sObjectType && !hasRunForAccounts) {
            DmlWrapper wrapper = runAccountTriggerHandler(newlist, oldlist, triggerAction, objResult);
            hasRunForAccounts = true;
            return wrapper;
        } else {
            return null;
        }
    }
                
    /*******************************************************************************************************
    * @description Affiliation trigger handler on Contact. Creates affiliations and/or updates existing 
    * affiliation primary checkbox and status field.
    * @param listNew The list of contacts from trigger new. 
    * @param listOld The list of contacts from trigger old. 
    * @param triggerAction Which action triggered the current context. (Before or After; Insert, Update, 
    * Delete, or Undelete.)
    * @param objResult The field describe object for Contact.
    * @return dmlWrapper Objects that need to be inserted or updated after the processing of the trigger.
    ********************************************************************************************************/
    private DmlWrapper runContactTriggerHandler(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        DmlWrapper dmlWrapper = new DmlWrapper();
        
        //Passing null basically indicates that the existing setting (in memory) should be used
        Affiliations_Settings__c currentAffiliationsSettings = UTIL_CustomSettingsFacade.getAffiliationsSettings();
        
        // we have multiple scenarios to support
        // 1. create a new current affiliation, potentially mark primary
        // 2. set an existing affiliation to former
        // 3. set an existing affiliation to non-primary
        // 4. set an existing affiliation to primary
        
        map<string, AfflOps> mapStrComboKeyAfflOps = new map<string, AfflOps>();
        
        Integer i = 0;
        if (currentAffiliationsSettings.Automatic_Affiliation_Creation_Turned_On__c) {
            
            for (SObject so : newlist) {
                Contact contact = (Contact)so;

                // AFTER INSERT
                if (triggerAction == TDTM_Runnable.Action.AfterInsert) {

                    if (contact.AccountId != null) {
                        string strComboKey = strComboKeyFromContactIdAccountId(contact.Id, contact.AccountId);
                        AfflOps ao = mapStrComboKeyAfflOps.get(strComboKey);
                        if (ao == null) ao = new AfflOps(contact.Id, contact.AccountId);
                        ao.fCurrent = true;
                        ao.strRole = contact.Title;
                        mapStrComboKeyAfflOps.put(strComboKey, ao);
                    }
                    if (contact.Primary_Affiliation_1__c != null) {
                        string strComboKey = strComboKeyFromContactIdAccountId(contact.Id, contact.Primary_Affiliation_1__c);                     
                        AfflOps ao = mapStrComboKeyAfflOps.get(strComboKey);
                        if (ao == null) ao = new AfflOps(contact.Id, contact.Primary_Affiliation_1__c);
                        ao.fPrimary = true;
                        ao.strRole = contact.Title;
                        mapStrComboKeyAfflOps.put(strComboKey, ao);
                    }
                }

                // AFTER UPDATE
                if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {                
                    Contact oldContact = (Contact) oldlist[i];
                    
                    if (contact.AccountId != oldContact.AccountId) {
                        if (contact.AccountId != null) {
                            string strComboKey = strComboKeyFromContactIdAccountId(contact.Id, contact.AccountId);
                            AfflOps ao = mapStrComboKeyAfflOps.get(strComboKey);
                            if (ao == null) ao = new AfflOps(contact.Id, contact.AccountId);
                            ao.fCurrent = true;
                            ao.strRole = contact.Title;
                            mapStrComboKeyAfflOps.put(strComboKey, ao);
                        }
                        if (oldContact.AccountId != null) {
                            string strComboKey = strComboKeyFromContactIdAccountId(oldContact.Id, oldContact.AccountId);
                            AfflOps ao = mapStrComboKeyAfflOps.get(strComboKey);
                            if (ao == null) ao = new AfflOps(oldContact.Id, oldContact.AccountId);
                            ao.fFormer = true;
                            mapStrComboKeyAfflOps.put(strComboKey, ao);
                        }
                    }
    
                    if (contact.Primary_Affiliation_1__c != oldContact.Primary_Affiliation_1__c) {
                        if (contact.Primary_Affiliation_1__c != null) {
                            string strComboKey = strComboKeyFromContactIdAccountId(contact.Id, contact.Primary_Affiliation_1__c);                     
                            AfflOps ao = mapStrComboKeyAfflOps.get(strComboKey);
                            if (ao == null) ao = new AfflOps(contact.Id, contact.Primary_Affiliation_1__c);
                            ao.fPrimary = true;
                            ao.strRole = contact.Title;
                            mapStrComboKeyAfflOps.put(strComboKey, ao);
                        }
                        if (oldContact.Primary_Affiliation_1__c != null) {
                            string strComboKey = strComboKeyFromContactIdAccountId(oldContact.Id, oldContact.Primary_Affiliation_1__c);                     
                            AfflOps ao = mapStrComboKeyAfflOps.get(strComboKey);
                            if (ao == null) ao = new AfflOps(oldContact.Id, oldContact.Primary_Affiliation_1__c);
                            ao.fFormer = true;
                            ao.fUnprimary = true;
                            mapStrComboKeyAfflOps.put(strComboKey, ao);
                        }
                    }
                }
    
                i++;
            }
        
            if (mapStrComboKeyAfflOps.size() > 0) {
                processAfflOps(mapStrComboKeyAfflOps, dmlWrapper);
            }

        }
        return dmlWrapper;
    }

    /*******************************************************************************************************
    * @description Affiliation trigger handler on Account. Creates affiliations and/or updates existing 
    * affiliation primary checkbox and status field.
    * @param listNew The list of Accounts from trigger new. 
    * @param listOld The list of Accounts from trigger old. 
    * @param triggerAction Which action triggered the current context. (Before or After; Insert, Update, 
    * Delete, or Undelete.)
    * @param objResult The field describe object for Account. 
    * @return dmlWrapper Objects that need to be inserted or updated after the processing of the trigger.
    ********************************************************************************************************/
    private DmlWrapper runAccountTriggerHandler(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        DmlWrapper dmlWrapper = new DmlWrapper();

        //Passing null basically indicates that the existing setting (in memory) should be used
        Affiliations_Settings__c currentAffiliationsSettings = UTIL_CustomSettingsFacade.getAffiliationsSettings();
        
        // we have multiple scenarios to support
        // 1. insert: create new current affiliation (not primary)
        // 2. update: search for existing affiliations
        //      if one exists and isn't marked current, mark it as current
        //      otherwise create it
        
        map<string, AfflOps> mapStrComboKeyAfflOps = new map<string, AfflOps>();
        map<id, AfflOps> mapConIdToAfflOps = new map<id, AfflOps>();
        
        if (currentAffiliationsSettings.Automatic_Affiliation_Creation_Turned_On__c) {
            
            for (integer i=0; i<newlist.size(); i++) {
                Account account = (Account)newlist[i];
                //if this account is an organization, and we have a primary contact
                if (account.SYSTEMIsIndividual__c == false && account.One2OneContact__c != null) {
                    // AFTER INSERT
                    if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                        string strComboKey = strComboKeyFromContactIdAccountId(account.One2OneContact__c, account.id);
                        AfflOps ao = mapStrComboKeyAfflOps.get(strComboKey);
                        if (ao == null) ao = new AfflOps(account.One2OneContact__c, account.id);
                        ao.fCurrent = true;
                        mapConIdToAfflOps.put(account.One2OneContact__c, ao);
                        mapStrComboKeyAfflOps.put(strComboKey, ao);
                    }

                    // AFTER UPDATE
                    if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                        Account oldAccount = (Account)oldlist[i];
                        
                        if (account.One2OneContact__c != oldAccount.One2OneContact__c) {
                            string strComboKey = strComboKeyFromContactIdAccountId(account.One2OneContact__c, account.id);
                            AfflOps ao = mapStrComboKeyAfflOps.get(strComboKey);
                            if (ao == null) ao = new AfflOps(account.One2OneContact__c, account.id);
                            ao.fCurrent = true;
                            mapConIdToAfflOps.put(account.One2OneContact__c, ao);
                            mapStrComboKeyAfflOps.put(strComboKey, ao);
                        }
                    }
                }
    
            }
        
            //we need an extra query here to get the correct role from the contact title
            if (!mapConIdToAfflOps.isEmpty()) {
                for (Contact con : [SELECT Id, Title FROM Contact WHERE Id IN :mapConIdToAfflOps.keySet()])
                    mapConIdToAfflOps.get(con.id).strRole = con.Title;
            }

            if (!mapStrComboKeyAfflOps.isEmpty()) {
                processAfflOps(mapStrComboKeyAfflOps, dmlWrapper);
            }

        }
        return dmlWrapper;
    }


    /*******************************************************************************************************
    * @description Wrapper class to track affiliations and which operations need to be performed on them.
    */ 
    private class AfflOps {

        // constructor
        AfflOps(Id contactId, Id accountId) {
            strComboKey = strComboKeyFromContactIdAccountId(contactId, accountId);
            fCurrent = false;
            fFormer = false;
            fPrimary = false;
            fUnprimary = false;
        }

        string strComboKey;
        boolean fCurrent;
        boolean fFormer;
        boolean fPrimary;
        boolean fUnprimary;
        string strRole;
        
        ID ContactId {
            get {
                if (strComboKey == null) return null;
                return strComboKey.left(strComboKey.indexOf('|'));
            }
        }
        
        ID AccountId {
            get {
                if (strComboKey == null) return null;
                return strComboKey.substring(strComboKey.indexOf('|') + 1);
            }
        }
        
    }
    
    /*******************************************************************************************************
    * @description Combines the ids of a contact and an account as a unique identifier for affiliations.
    * @param contactId The id of a contact.
    * @param accountId The id of an account.
    * @return string A string with the contact id, a pipe character |, and the account id.
    ********************************************************************************************************/
    private static string strComboKeyFromContactIdAccountId(Id contactId, Id accountId) {
        return contactId + '|' + accountId;
    }

    /*******************************************************************************************************
    * @description Using a map of unique affiliation identifiers and our AfflOps class, this method queries
    * existing affiliations, then processes AfflOps to create new or update existing affiliations.
    * @param mapStrComboKeyAfflOps A map of combination contact id and account id keys from the 
    * strComboKeyFromContactIdAccountId method to AfflOps objects.
    * @param dmlWrapper The dmlWrapper class for this transaction.
    * @return void This class updates the dmlWrapper parameter and returns nothing.
    ********************************************************************************************************/  
    private static void processAfflOps(map<string, AfflOps> mapStrComboKeyAfflOps, DmlWrapper dmlWrapper) {

        // the collections we want to insert/update in the db
        list<Affiliation__c> listAfflInsert = new list<Affiliation__c>();
        list<Affiliation__c> listAfflIdAfflUpdate = new list<Affiliation__c>();

        // get all the accounts & contacts
        set<Id> setContactId = new set<Id>();
        set<Id> setAccountId = new set<Id>();
        for (AfflOps ao : mapStrComboKeyAfflOps.values()) {
            setContactId.add(ao.ContactId);
            setAccountId.add(ao.AccountId);
        }
        
        Map<Id,Account> mapAccountIdAccount = new Map<Id,Account>([Select Id, SYSTEMIsIndividual__c from Account where Id in :setAccountId]);
        
        // get existing affiliations
        map<string, Affiliation__c> mapStrComboKeyAffl = new map<string, Affiliation__c>();

        for (Affiliation__c a : [Select Id, Contact__c, Organization__c from Affiliation__c 
            where EndDate__c = null and Contact__c in :setContactId and Organization__c in :setAccountId]) {
            mapStrComboKeyAffl.put(strComboKeyFromContactIdAccountId(a.Contact__c, a.Organization__c), a);
        }

        for (AfflOps ao : mapStrComboKeyAfflOps.values()) {
            Id accountId = ao.AccountId;
            Id contactId = ao.ContactId;
            
            if (ao.fCurrent) {
                //check to see if this account isn't an individual.
                Account acc =  mapAccountIdAccount.get(accountId);
                if (acc != null && acc.SYSTEMIsIndividual__c != true) {
                    Affiliation__c a = new Affiliation__c();
                    a.Contact__c = contactId;
                    a.Organization__c = accountId;
                    a.Status__c = Label.DefaultCurrentStatus;
                    a.StartDate__c = System.Today();
                    a.Role__c = ao.strRole;
                    a.Primary__c = ao.fPrimary;
                    listAfflInsert.add(a);
                }           
            }
            
            if (!ao.fCurrent && ao.fPrimary) {
               // see if we have an existing current affiliation to use, otherwise create a new one
               Affiliation__c a = mapStrComboKeyAffl.get(ao.strComboKey);
               if (a != null) {
                   a.Primary__c = true;
                   listAfflIdAfflUpdate.add(a);
               } else {
                    a = new Affiliation__c();
                    a.Contact__c = contactId;
                    a.Organization__c = accountId;
                    a.Status__c = Label.DefaultCurrentStatus;
                    a.StartDate__c = System.Today();
                    a.Role__c = ao.strRole;
                    a.Primary__c = true;
                    listAfflInsert.add(a);              
               }
            }
            
            if (ao.fFormer || ao.fUnprimary) {
               Affiliation__c a = mapStrComboKeyAffl.get(ao.strComboKey);
               
               // deal with the affiliation being deleted (if the org or contact was deleted)
               if (a == null) continue;
               
               if (ao.fFormer) {
                    //flag it as former ending today
                    a.Status__c = Label.DefaultFormerStatus;
                    a.EndDate__c = System.Today();                
               }
               if (ao.fUnprimary) {
                    a.Primary__c = false;
               }  
               listAfflIdAfflUpdate.add(a);
            }
        }

        if (listAfflInsert.size() > 0) {
            //UTIL_Debug.debug('**** listAfflInsert: ' + JSON.serializePretty(listAfflInsert));
            dmlWrapper.objectsToInsert.addAll((list<SObject>) listAfflInsert);
        }
            
       if (listAfflIdAfflUpdate.size() > 0) {
            //UTIL_Debug.debug('**** listAfflIdAfflUpdate: ' + JSON.serializePretty(listAfflIdAfflUpdate.values()));
            dmlWrapper.objectsToUpdate.addAll((list<SObject>) listAfflIdAfflUpdate);
       }
    }
    
    /*******************************************************************************************************
    * @description Affiliation trigger handler on Affiliations. Updates a contact's primary affiliation
    * field for a new primary affiliation.
    * @param listNew The list of affiliations from trigger new. 
    * @param listOld The list of affiliations from trigger old. 
    * @param triggerAction Which action triggered the current context. (Before or After; Insert, Update, 
    * Delete, or Undelete.)
    * @param objResult The field describe object for Contact.
    * @return dmlWrapper Objects that need to be inserted or updated after the processing of the trigger.
    ********************************************************************************************************/
    private DmlWrapper runAfflTriggerHandler(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        DmlWrapper dmlWrapper = new DmlWrapper();
        
        map<Id, Id> mapConIdAccIdPrimary = new map<Id, Id>();
        map<Id, Id> mapConIdAccIdUnprimary = new map<Id, Id>();
        
        integer i = 0;        
        for (SObject so : newlist) {
            Affiliation__c affl = (Affiliation__c)so;

            // AFTER INSERT
            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                if (affl.Primary__c && affl.Contact__c != null && affl.Organization__c != null) {
                    mapConIdAccIdPrimary.put(affl.Contact__c, affl.Organization__c);
                }        
            }
            
            // AFTER UPDATE
            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                Affiliation__c afflOld = (Affiliation__c)oldlist[i];
                if (affl.Primary__c != afflOld.Primary__c) {
                    if (affl.Primary__c)    
                        mapConIdAccIdPrimary.put(affl.Contact__c, affl.Organization__c);
                    else
                        mapConIdAccIdUnprimary.put(afflOld.Contact__c, afflOld.Organization__c);                    
                }
            }
            
        i++;            
        }
       
        // update all our contacts as appropriate
        list<Contact> listCon = new list<Contact>();
        for (Id contactId : mapConIdAccIdPrimary.keySet()) {
            Contact con = new Contact(Id = contactId);
            con.Primary_Affiliation_1__c = mapConIdAccIdPrimary.get(contactId);
            listCon.add(con);
        }
        for (Id contactId : mapConIdAccIdUnprimary.keySet()) {
            Contact con = new Contact(Id = contactId);
            con.Primary_Affiliation_1__c = null;
            listCon.add(con);
        }
    
        if (listCon.size() > 0) {
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)listCon);
        }
        return dmlWrapper;
    }

}