/*
    Copyright (c) 2009, Salesforce.org
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
* @date 2011 (1.x)
* @group Accounts
* @group-content ../../ApexDocContent/Accounts.htm
* @description Implements Household or Administrative account model - controls syncing within the model 
*/
public class ACCT_IndividualAccounts_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description The selected Account record type.
    */     
    private static ID defaultRecTypeID = UTIL_CustomSettingsFacade.getSettings().Account_Processor__c;
    
    /*******************************************************************************************************
    * @description a set of languages that require different naming conventions
    */ 
    private static Set<String> EasternOrderLanguages = new Set<String>{
        'ja','ko','vi','hu','ro','zh_CN','zh_TW'
    };
              
    /*******************************************************************************************************
    * @description the current user's Locale/Language
    */ 
    private static String OrgLanguage { get {
        if (OrgLanguage == null)
            OrgLanguage = UserInfo.getLocale();// [Select LanguageLocaleKey From Organization].LanguageLocaleKey;
        return OrgLanguage;             
    } set; }       
        	
    /*******************************************************************************************************
    * @description Trigger Handler on Contact that handles account management.  Depending on the Account
    * Model, creates a Household Account, One-to-One Account, or uses the Individual Bucket Account.
    * @param listNew the list of Contacts from trigger new. 
    * @param listOld the list of Contacts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Contacts.
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        list<Contact> contacts = (list<Contact>)newlist;
        list<Contact> oldContacts = (list<Contact>)oldlist;
        
        DmlWrapper dmlWrapper = new DmlWrapper();
    	            
        List<Contact> listContactNeedAccount = new List<Contact>();
        List<Contact> listContactNeedAccountUpdate = new List<Contact>();
        List<Contact> listContactAccountDelete = new List<Contact>();

        Map<Id,Id> mapAccountIdContactId = new Map<Id,Id>();
        
        List<Id> listAccountIdHHToUpdate = new list<Id>();
        List<Id> listAccountIdHHToRename = new list<Id>();
        
        map<Id, Contact> mapContactIdContactOwnerChange = new map<Id, Contact>();
        
		if (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
           
           // requery to get correct Account values (and all the other fields we will look at)
           string strSoql = 'select id, AccountId,' +
                'Account.RecordTypeID, ' +
                'Account.Primary_Contact__c, Account.Name,' +
                'firstname, lastname, OwnerId, Salutation,' +
                'MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, ' + 
                'OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude, '; 
            
            if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled)
                strSoql += 'MailingCountryCode, MailingStateCode, OtherCountryCode, OtherStateCode, ';
            
            strSoql += 'Phone, Fax from Contact where Id IN :contacts';
            contacts = database.query(strSoql);
        }        
                    
        // AFTER DELETE
        if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            for (Contact c : oldContacts)
                listContactAccountDelete.add(c);
        } else {               
            Integer i = 0; // used to index into oldContacts when needed
            for (Contact c : contacts) {
    
                // AFTER INSERT
                if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                	
                	// Account should be created if:
                    //    1. The account isn't set by the user
                    //    2. The Account Model is not blank
                    if (c.AccountId == null && defaultRecTypeID != null) {
                        listContactNeedAccount.add(c);
                    }
                    
                    // grab the Accounts that need to have the newly assigned Contact Id added to them if:
                    //    1. If the contact is connected to an Account
                    if (c.AccountId != null) { 
                        // contacts are connected to Accounts, make the connection in the other direction
                        mapAccountIdContactId.put(c.AccountId, c.Id);
                    }   
	            }
        
                // AFTER UPDATE
                if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                    // HH account should be created if:
	                //   1. The account has been blanked out by the user
	                //   2. The Account Model is not blank
	                if (c.AccountId == null && defaultRecTypeID != null) {
	                    listContactNeedAccount.add(c);
	                }
                    
                    // if the account (any type) has changed
                    if (c.AccountId != oldContacts[i].AccountId) {
                        listAccountIdHHToUpdate.add(c.AccountId);
                        
                        // old HH Accounts that don't get deleted still need to have name redone
                        listAccountIdHHToUpdate.add(oldContacts[i].AccountId);                                                                             
                    } 
                    
                    // check for ownership changes
                    if (c.OwnerId != oldContacts[i].OwnerId) {
                    	mapContactIdContactOwnerChange.put(c.Id, c);
                    }                     
                }
                i += 1;
            }
        }   

        // now done going thru all contacts, do our DML logic based on our lists
        
        if (listContactNeedAccount.size() > 0) {
        	UTIL_Debug.debug('****Number of contacts that need accounts created: ' + listContactNeedAccount.size());
            //add the newly created or updated Contacts that need a new individual account
            insertContactAccount(listContactNeedAccount, dmlWrapper);
        }
        if (mapAccountIdContactId.size() > 0) {
            //update Accounts that have newly created Contacts connected to them
            updateAccountPrimaryContact(mapAccountIdContactId, dmlWrapper);
            //we also need to create affiliations for those contacts that have been created as children of existing accounts, 
            //and we have to populate the key affiliation field on those contacts
            //createAfflsToExistingAccs(mapAccountIdContactId, dmlWrapper);
        }

        if (listAccountIdHHToUpdate.size() > 0) {
            updateParentAcc(listAccountIdHHToUpdate, dmlWrapper);
        }
        if (mapContactIdContactOwnerChange.size() > 0) {
        	updateOwners(mapContactIdContactOwnerChange, dmlWrapper);
        }
        if (listContactAccountDelete.size() > 0) {
        	UTIL_Debug.debug('****Number of accs to delete: ' + listContactAccountDelete.size());
            // check all old accounts to delete is they are left hanging around
            deleteContactAccountsIfEmpty(listContactAccountDelete, dmlWrapper);
        }

    	return dmlWrapper;
    }

    /*******************************************************************************************************
    * @description Updates Accounts with the primary Individual Contact Id.
    * @param mapAccountIdContactId a map of AccountId's to ContactId's which specifies which accounts need updating.
    * @param dmlWrapper to hold the Accounts that need updating.
    * @return void
    */ 
    private void updateAccountPrimaryContact(Map<Id, Id> mapAccountIdContactId, DmlWrapper dmlWrapper) {
        List<Account> listAccount = new List<Account>(); 
        for (Id i : mapAccountIdContactId.keySet()) {
            Account a = new Account(Id = i, Primary_Contact__c = mapAccountIdContactId.get(i));
            listAccount.add(a);
        }
        if (listAccount.size() > 0) {
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)listAccount);
        }      
    }
    
    /*******************************************************************************************************
    * @description Creates affiliations for those contacts that have been created as children of existing accounts, 
    * and populates the key affiliation field on those contacts.
    * @param mapAccountIdContactId a map of AccountId's to ContactId's which specifies which accounts need updating.
    * @param dmlWrapper to hold the Accounts that need updating.
    * @return void
    *
    * Functionality Change --> commenting out this method because we don't want an affiliation automatically created
    * from a Contact to its parent Account. 
    * 
    private void createAfflsToExistingAccs(Map<Id, Id> mapAccountIdContactId, DmlWrapper dmlWrapper) {
    	List<SObject> afflsToInsert = new List<Affiliation__c>();
    	for(ID accountId : mapAccountIdContactId.keySet()) {
    		afflsToInsert.add(new Affiliation__c(Contact__c =  mapAccountIdContactId.get(accountId), Account__c = accountId, 
								Primary__c = true, Status__c = 'Current'));
    	}
    	dmlWrapper.objectsToInsert.addAll(afflsToInsert);
    }*/

    /*******************************************************************************************************
    * @description Updates an Account's naming, primary contact, and rollups
    * @param listAccountId the list of Account (Id's) that need updating.
    * @param dmlWrapper to hold the Accounts that need updating.
    * @return void
    */ 
    private void updateParentAcc(list<Id> listAccountId, DmlWrapper dmlWrapper) {
        resetPrimaryContactForAccount(listAccountId, dmlWrapper);        
    }
    
    /*******************************************************************************************************
    * @description sets the Primary Account for each Account in the list of Accounts
    * @param listAccountId the list of Account (Id's) that need updating.
    * @param dmlWrapper to hold the Accounts that need updating.
    * @return void
    */ 
    private void resetPrimaryContactForAccount(list<Id> listAccountId, DmlWrapper dmlWrapper) {
    
        // for each account, we need a set of their contacts.
        map<Id, set<Id>> mapAccountIdSetContacts = new map<Id, set<Id>>();
        
        list<Contact> listCon = [select Id, AccountId, Account.Primary_Contact__c from Contact where AccountId in :listAccountId];
        for (Contact con : listCon) {
            set<Id> setContactId = mapAccountIdSetContacts.get(con.AccountId);
            if (setContactId == null) { 
                setContactId = new set<Id>();
                mapAccountIdSetContacts.put(con.AccountId, setContactId);
            }
            setContactId.add(con.Id);
        }
        
        // now go thru each account and update their primary contact if the current one isn't valid
        list<Account> listAcc = [select Id, Primary_Contact__c from Account where Id in :listAccountId];
        list<Account> listAccToUpdate = new list<Account>();
        for (Account acc : listAcc) {
            set<Id> setContactId = mapAccountIdSetContacts.get(acc.Id);
            if (setContactId != null && !setContactId.contains(acc.Primary_Contact__c)) {
                acc.Primary_Contact__c = firstIdFromSet(setContactId);
                listAccToUpdate.add(acc);
            }    
        }
        
        // now do the update
        dmlWrapper.objectsToUpdate.addAll((List<SObject>)listAccToUpdate);
    }
        
    /*******************************************************************************************************
    * @description returns the first Id from the specified set
    * @param setId a set of Id's
    * @return Id.  null if the set is empty.
    */ 
    private Id firstIdFromSet(set<Id> setId) {
        for (ID id : setId) {
            return Id;
        }
        return null;
    }

    /*******************************************************************************************************
    * @description Inserts a new Account for an Individual Contact
    * @param contacts the list of Contacts that need updating.
    * @param dmlWrapper to hold the Contacts that need updating.
    * @return void
    */ 
    private void insertContactAccount(Contact[] contacts, DmlWrapper dmlWrapper) {
    	
        List<Id> contactIds = new List<Id>();
        Map<Id,Account> mapContactIdAccount = new Map<Id,Account>();  
        list<Contact> listContactNewAcct = new list<Contact>();     
        
        for (Contact c : contacts) {
            //track which contacts are being inserted vs. updated
            if (c.Id != null) {
                contactIds.add(c.Id);
            }
        }
        // get all the Accounts that are connected to the existing Contacts
        for (Account acc : [Select Id, Primary_Contact__c, RecordTypeId from Account where Primary_Contact__c in :contactIds]) {
            mapContactIdAccount.put(acc.Primary_Contact__c, acc);
        }
        
        List<Account> accountInserts = new List<Account>();
        
        for (Contact c : contacts) {
            // if we found an Account already connected to this Contact, connect the Contact to that Account if it
            // is the correct type for the current account processor
            Account acc = mapContactIdAccount.get(c.Id);
            if (acc != null && (acc.RecordTypeId == UTIL_CustomSettingsFacade.getSettings().Account_Processor__c)) {
                UTIL_Debug.debug('****Account already existed');
                // if a user has blanked out the Account for a Contact, this will put it right back
                c.AccountId = acc.Id;                
            } else {
            	UTIL_Debug.debug('****Creating new account');
                
                // construct the individul account for the Contact
                Account a = new Account();
                
                // construct the Account name
                if(defaultRecTypeID == UTIL_CustomSettingsFacade.getSettings().Household_Addresses_RecType__c)
                	a.Name = strNameHHAccountForContact(c);
                //TODO: we should not be asking for the record type directly, and instead let the use tell us which record type
                //represents an Administrative account.
                else if(defaultRecTypeID == UTIL_Describe.getAdminAccRecTypeID()) 
                	a.Name = strNameAdmAccountForContact(c);
                else
                    a.Name = strNameAccountForContact(c);
                
                //connect the Account to the Contact for HHAccount
                if (c.Id != null) {
                    a.Primary_Contact__c = c.Id;
                }
                a.Phone = c.Phone;
                a.Fax = c.Fax;
                
                if(defaultRecTypeID == UTIL_CustomSettingsFacade.getSettings().Household_Addresses_RecType__c) {
                    ADDR_Addresses_UTIL.copyAddressStdSObj(c, 'Mailing', a, 'Billing');
                    ADDR_Addresses_UTIL.copyAddressStdSObj(c, 'Other', a, 'Shipping');
                }
                
                //Give it the default record type selected in the settings. 
                if(defaultRecTypeID != null)
                    a.RecordTypeID = defaultRecTypeID;
                
                accountInserts.add(a);
                listContactNewAcct.add(c);
            }
        }
        
        List<Contact> contactsToUpdate = new List<Contact>();
        List<SObject> afflsToInsert = new List<Affiliation__c>();
        if (accountInserts.size() > 0) {
        	UTIL_Debug.debug('****Number of accounts to insert: ' + accountInserts.size());
            // we can't use dmlWrapper because we need to get the new AccountID's into the Contacts.
            // we do want it to be all or nothing, so errors won't get lost.
            insert accountInserts;
            Integer i = 0;
            for (Contact c : listContactNewAcct) {
                // for each success, write the new AccountId to the Contact.
                c.AccountId = accountInserts[i].Id;
                contactsToUpdate.add(c);
                i += 1;
            }
        }
        ADDR_Contact_TDTM.hasRunAddrTrigger = true;
        update contactsToUpdate;
        dmlWrapper.objectsToInsert.addAll(afflsToInsert);
    }
    
    /*******************************************************************************************************
    * @description Deletes the accounts for contacts that have been deleted if they are empty (no ops, no hh members)
    * @param contacts the list of Contacts that need to be considered
    * @param dmlWrapper to hold the Accounts that need updating.
    * @return void
    */ 
    public void deleteContactAccountsIfEmpty(Contact[] contacts, DmlWrapper dmlWrapper) {
        List<Id> accountIds = new List<Id>();
        List<Account> accountsOnContacts = new List<Account>();
        List<SObject> accountsForDeletion = new List<SObject>();
        List<Id> listAccountIdUpdate = new list<Id>();
        
        if (contacts.size() > 0) {
            for (Contact thisContact : contacts) {
                accountIds.add(thisContact.accountId);
            }

            accountsOnContacts = [Select Id, Type, RecordTypeId, (Select Id from Opportunities limit 1), 
                                  (select Id from Contacts limit 1) from Account where Id IN :accountIds];
            
            for (Account thisAccount : accountsOnContacts) {
                // Looking at a setting to determine which account types can be deleted (W-009779)
                if (UTIL_CustomSettingsFacade.getSettings().Accounts_to_Delete__c != null && thisAccount.RecordTypeId != null
                && UTIL_CustomSettingsFacade.getSettings().Accounts_to_Delete__c.contains(thisAccount.RecordTypeId)) {
                    
                    // If there are no Opportunities for this Account, add it for deletion
                    if (thisAccount.Opportunities.size() == 0 && thisAccount.Contacts.size() == 0) {
                        accountsForDeletion.add(thisAccount);
                    } else if (thisAccount.RecordTypeId == UTIL_Describe.getHhAccRecTypeID() || 
                    thisAccount.RecordTypeId == UTIL_Describe.getAdminAccRecTypeID()) {
                        listAccountIdUpdate.add(thisAccount.Id);
                    }
                }   
            }        
        }
        // delete the accounts
        if (accountsForDeletion.size() > 0)
        	dmlWrapper.objectsToDelete.addAll(accountsForDeletion);
        // update any HH accounts that just lost a contact
        if (listAccountIdUpdate.size() > 0)
            updateParentAcc(listAccountIdUpdate, dmlWrapper);        
    }

    /*******************************************************************************************************
    * @description Contact's owner has changed. Consider updating related account owner.
    * @param mapContactIdContactOwnerChange a map of Contact Id to Contact, for the contacts to consider
    * @param dmlWrapper to hold the Contacts that need updating.
    * @return void
    */ 
    private void updateOwners(map<Id, Contact> mapContactIdContactOwnerChange, DmlWrapper dmlWrapper) {        
        if (mapContactIdContactOwnerChange.size() > 0) {
            list<Account> listAccToUpdate = new list<Account>();
            set<Id> setAccId = new set<Id>();
            for (Contact con : mapContactIdContactOwnerChange.values()) {
            	setAccId.add(con.AccountId);
            }
                       
            list<Account> listAcc = [Select Id, RecordTypeId, Primary_Contact__c, OwnerId, (select Id from Contacts limit 2) from Account 
                where Id IN :setAccId];
            
            for (Account acc : listAcc) {
                // only consider HH and Admin Accounts
                //TODO: use setting to determine if Account owner should be changed (W-009780)
                if (acc.RecordTypeId == UTIL_Describe.getHhAccRecTypeID() || 
                acc.RecordTypeId == UTIL_Describe.getAdminAccRecTypeID()) {                    
                    // if there is only 1 contact associated with this account
                    if (acc.Contacts.size() == 1 && acc.Primary_Contact__c != null) {
                    	Contact c = mapContactIdContactOwnerChange.get(acc.Primary_Contact__c);
                    	Id ownerIdContact = (c != null ? c.OwnerId : null);
                    	if (acc.OwnerId != ownerIdContact) {
                    		acc.OwnerId = ownerIdContact;
                    		listAccToUpdate.add(acc);
                    	}
                    }
                }   
            }
            // add all accounts needing updating to our list
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)listAccToUpdate);
        }
    }  

    /*******************************************************************************************************
    * @description returns the default name for a new HH Account. Custom household naming will update this 
    * account later if enabled, but we still need one if not enabled.
    * @param con the Contact
    * @return string. the Household account name
    */ 
    public static String strNameHHAccountForContact(Contact con) {
        return con.LastName + ' ' + system.label.DefaultHouseholdName;
    }
    
    /*******************************************************************************************************
    * @description returns the default name for a new Administrative Account.
    * @param con the Contact
    * @return string. the Household account name
    */ 
    public static String strNameAdmAccountForContact(Contact con) {
        return con.LastName + ' ' + system.label.DefaultAdminName;
    }
    
    /*******************************************************************************************************
    * @description returns the default name for a new generic Account.
    * @param con the Contact
    * @return string. the Household account name
    */ 
    public static String strNameAccountForContact(Contact con) {
        return con.LastName + ' ' + system.label.DefaultAccountName;
    }
}