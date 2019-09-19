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
public class ACCT_IndividualAccounts_DF extends TDTM_Runnable {
    /*********************************************************************************
	* @description The selected Account record type.
	*/
    private static ID defaultRecTypeId = UTIL_CustomSettingsFacade.getSettings().Account_Processor__c;  //KD: Literally provides the defaultRecordTypeId  from the CS Hierarchy Settings's field called Account Processor.

    /*******************************************************************************************************
	* @description The user defined Administrative Account record type.
	*/
    private static ID userDefinedAdminRecordTypeId = Util_Describe.getAdminAccRecTypeID();

    /*******************************************************************************************************
	* @description The user defined Household Account record type.
	*/
    private static ID userDefinedHHRecordTypeId = Util_Describe.getHhAccRecTypeID();

    /*******************************************************************************************************
	* @description The set of languages that require different naming conventions
	*/
    private static Set<String> EasternOrderLanguages = new Set<String> {
        'ja','ko','vi','hu','ro','zh_CN','zh_TW'
    };

   	/*******************************************************************************************************
	* @description The current user's Locale/Language
	*/
	private static String OrgLanguage { get {
        if (OrgLanguage == null) {
            //[Select LanguageLocaleKey From Organization].LanguageLocaleKey;
        	OrgLanguage = UserInfo.getLocale();
        }
        return OrgLanguage;
   	} set; }

    public List<Contact> contacts;
    public List<Contact> oldContacts;
    public TDTM_Runnable.Action triggerAction;
    public DmlWrapper dmlWrapper;

	/*******************************************************************************************************
	* @description Trigger Handler on Contact that handles account management. Depending on the Account
	* Model, creates a Household Account, One-to-One Account, or uses the Individual Bucket Account.
	* @param listNew the list of Contacts from trigger new.
	* @param listOld the list of Contacts from trigger old.
	* @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
	* @param objResult the describe for Contacts.
	* @return dmlWrapper.
	********************************************************************************************************/
	public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
                                   TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        this.contacts = newlist;
        this.oldContacts = oldlist;
        this.triggerAction = triggerAction;
        this.dmlWrapper = new DmlWrapper();

        //Requery Contacts to include Account information
        if (contacts.size() > 0) {
            contacts = queryContacts();
        }

        wrapperHandleAfter wp;

        if ((triggerAction == TDTM_Runnable.Action.AfterInsert &&
				!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert)) ||
                (triggerAction == TDTM_Runnable.Action.AfterUpdate &&
                	!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update)))
        			{
                 	 //wp = handleAfter(contacts, oldContacts, triggerAction);
                 	 handleAfter(contacts, oldContacts, triggerAction);
                    } else if (triggerAction == TDTM_Runnable.Action.AfterDelete &&
                               !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Delete)) {
                      	handleAfterDelete(oldContacts);
                      }

		return dmlWrapper; //KD need to revisit this
	}

    private static List<Contact> queryContacts() {
        String strSoql = 'SELECT Id, AccountId,' +
            'Account.RecordTypeID, ' +
            'Account.Primary_Contact__c, Account.Name,' +
            'firstname, lastname, OwnerId, Salutation,' +
            'MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, ' +
            'OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude, ' +
            'Exclude_from_Household_Name__c,';

        if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
            strSoql += 'MailingCountryCode, MailingStateCode, OtherCountryCode, OtherStateCode, ';
        }

        strSoql += 'Phone, Fax FROM Contact WHERE Id IN :contacts';

        return database.query(strSoql);
    }

    private void handleAfter(Contact [] contacts, Contact [] oldContacts, TDTM_Runnable.Action triggerAction) {
        wrapperHandleAfter wrapper;

        //AfterInsert
        if (triggerAction == TDTM_Runnable.Action.AfterInsert &&
            TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert)) {
                wrapper = new wrapperHandleAfter (contacts, oldContacts, triggerAction);
            }

        //AfterUpdate
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate &&
            !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update)) {
                wrapper = new wrapperHandleAfter (contacts, oldContacts, triggerAction);
            }

        //Set recursion flags
        if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
            // Set reentrant flag
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert, true);
        }
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            // Set reentrant flag
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update, true);
        }
        if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            // Set reentrant flag
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Delete, true);
        }

        handleProcessing(wrapper, NULL);
    }

    private class wrapperHandleAfter {
        private Map<Id,Id> mapAccountIdContactId { get; set; }
        private Map<Id,Id> mapContactIdAccountIdNewMoveOpps { get; set; }
        private Map<Id,Id> mapContactIdAccountIdOldMoveOpps { get; set; }
        private Map<Id,Contact> mapContactIdContactOwnerChange { get; set; }
        private List<Id> setAccountIdHHToRenameWP { get; set; }
        private List<Id> listAccountIdHHToUpdate { get; set; }
        public List<Contact> listContactNeedAccount { get; set;}
        private List<Contact> listContactsChangedLastName { get; set; }

        private wrapperHandleAfter(Contact[] contacts, Contact [] oldContacts, TDTM_Runnable.Action triggerAction) {
            Integer i = 0;
            for (Contact c : contacts) {
                //Account needs to be created if (1) Account does not exist or (2) Account model is not blank
                if (c.AccountId == NULL && defaultRecTypeId != NULL) {
                    listContactNeedAccount.add(c);
                }

                //After Insert
                if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                    //Retrieve Accounts that needs to have the newly assigned Contact Id added to them if:
                    if (c.AccountId != NULL) {
                        //(1) If the Contact is connected to an Account but Primary_Contact__c on Account is NULL
                        if (c.Account.Primary_Contact__c == NULL) {
                            mapAccountIdContactId.put(c.AccountId, c.Id);
                        }
                        //(2) If Contacts are connected to Accounts, make the association in the other direction
                        if (checkHouseholdNaming(c.Account.RecordTypeID)) {
                            setAccountIdHHToRenameWP.add(c.AccountId);
                        }
                    }
                }

                //After Update
                if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                    //If Account has changed (1) Update the Account's name (2) Move Opportunity
                    if (c.AccountId != oldContacts[i].AccountId) {
                        if(c.AccountId != NULL) {
                            listAccountIdHHToUpdate.add(c.AccountId);
                            mapContactIdAccountIdNewMoveOpps.put(c.Id, c.AccountId);

                            if (checkHouseholdNaming(c.Account.RecordTypeId)) {
                                setAccountIdHHToRenameWP.add(c.AccountId);

                                if(oldContacts[i].AccountId != NULL) {
                                    setAccountIdHHToRenameWP.add(oldContacts[i].AccountId);
                                }
                            }
                        }  else {
                            if (UTIL_CustomSettingsFacade.getSettings().Automatic_Household_Naming__c == TRUE) {
                                setAccountIdHHToRenameWP.add(oldContacts[i].AccountId);
                            }
                        }

                        //Old HH Accounts that don't get deleted still need to have name redone
                        if (oldContacts[i].AccountId != NULL) {
                            listAccountIdHHToUpdate.add(oldContacts[i].AccountId);
                            mapContactIdAccountIdOldMoveOpps.put(c.Id, oldContacts[i].AccountId);
                        }
                    }

                    //If Ownership has changed
                    if (c.OwnerId != oldContacts[i].OwnerId) {
                        mapContactIdContactOwnerChange.put(c.Id, c);
                    }

                    //If Contact's last name has changed and it is using admin account model
                    if (c.LastName != oldContacts[i].LastName && c.AccountId != NULL) {
                        listContactsChangedLastName.add(c);
                    }

                    //If Contact Name or Exclude_from_Household_Name__c value has changed
                    if ((c.LastName != oldContacts[i].LastName ||
                         c.FirstName != oldContacts[i].FirstName ||
                         c.Exclude_from_Household_Name__c != oldContacts[i].Exclude_from_Household_Name__c) &&
                        c.AccountId != NULL &&
                        checkHouseholdNaming(c.Account.RecordTypeId)) {
                            setAccountIdHHToRenameWP.add(c.AccountId);
                        }
                }
            }
            i += 1;
        }

    	/*******************************************************************************************************
		* @description Check if all conditions for household naming are met
		* @param accRecordTypeId the id of parent account's record type id
		* @return boolean
		*/
    	public boolean checkHouseholdNaming(Id accRecordTypeId) {
        	if (accRecordTypeId != null
            	&& accRecordTypeId == userDefinedHHRecordTypeId
            	&& UTIL_CustomSettingsFacade.getSettings().Automatic_Household_Naming__c == true) {
                	return true;
            } else {
                return false;
            }
    	}
    }

    private void handleAfterDelete(Contact[] oldContacts) {
        List<Contact> listContactAccountDelete = new List<Contact>();
    	List<Account> relatedAccounts = new List<Account>();
   		Set<Id> setAccountIdHHToRename = new Set<Id>();
        Set<Id> relatedAccountIds = new Set<Id>();
        wrapperHandleAfter wp;

        for (Contact c : oldContacts) {
            listContactAccountDelete.add(c);
            relatedAccountIds.add(c.AccountId);
        }

        //Requery to retrieve correct Account value
        relatedAccounts = [SELECT Id, RecordTypeID
                           FROM Account
                           WHERE Id IN : relatedAccounts];

        for (Account account : relatedAccounts) {
            if (wp.checkHouseholdNaming(account.RecordTypeID)) {
                setAccountIdHHToRename.add(account.Id);
            }
        }
        handleProcessing(NULL, setAccountIdHHToRename);
    }

    private void handleProcessing(wrapperHandleAfter wp, Set<Id> setAccountIdHHToRename) {
        DmlWrapper dmlWrapper = new DmlWrapper(); //KD: Do I need this?
        //wrapperHandleAfter wp = new wrapperHandleAfter();
        List<Contact> createNewAccountsForContacts = wp.listContactNeedAccount;

        //Creates new Account
        if (createNewAccountsForContacts.size() > 0) {
            UTIL_Debug.debug('****Number of Contacts that need Accounts created: ' + createNewAccountsForContacts.size());
            insertContactAccount(createNewAccountsForContacts);
        }
        //Update Accounts that have newly created Contacts connected to them
        //KD: Need to verify if we need this method.
        /*if (mapAccountIdContactId.size() > 0) {
            updateAccountPrimaryContact(mapAccountIdContactId, dmlWrapper);
        }*/

        //Update existing Accounts
        if (wp.listAccountIdHHToUpdate.size() > 0) {
            //updateParentAcc(wp.listAccountIdHHToUpdate, dmlWrapper);
        }

        //Update HH Accounts
        if (setAccountIdHHToRename.size() > 0) {
            UTIL_ACCT_Naming.updateHHAccountsName(setAccountIdHHToRename);
        }

        if (wp.setAccountIdHHToRenameWP.size() > 0) {
            //UTIL_ACCT_Naming.updateHHAccountsName(wp.setAccountIdHHToRenameWP);
        }
    }
    /*******************************************************************************************************
	* @description Inserts a new Account for an Individual Contact
	* @param contacts the list of Contacts that need updating.
	* @param dmlWrapper to hold the Contacts that need updating.
	* @return void
	*/
    private void insertContactAccount(Contact[] contacts) {
        List<Id> contactIds = new List<Id>();
        List<Account> accountInserts = new List<Account>();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> listContactNewAcct = new list<Contact>();
        Map<Id,Account> mapContactIdAccount = new Map<Id,Account>();

        //Track which Contacts are being inserted vs. updated
        for (Contact c : contacts) {
            if (c.Id != NULL) {
                contactIds.add(c.Id);
            }
        }

        //Retrieve all the Accounts that have a connected Primary Contact
        for (Account acc : [SELECT Id, Primary_Contact__c, RecordTypeId
                            FROM Account
                            WHERE Primary_Contact__c IN : contactIds]) {
                                mapContactIdAccount.put(acc.Primary_Contact__c, acc);

                            }

        //Determines if Account needs to be created
        for (Contact c : contacts) {
            //If we find an Account already connect to this Contact, connect the Contact to the Account if it is the correct
            //type for the current Account processor.
            Account acc = mapContactIdAccount.get(c.Id);
            if (acc != NULL && (acc.RecordTypeId == UTIL_CustomSettingsFacade.getSettings().Account_Processor__c)) {
                UTIL_Debug.debug('****Account already existed');
                c.AccountId = acc.Id;
                contactsToUpdate.add(c);
            } else {
                UTIL_Debug.debug('****Creating new account');

                //Constructs the Account
                Account a = new Account(
                    Phone = c.Phone,
                    Fax = c.Fax,
                    OwnerId = c.OwnerId
                );

                //Constructs the Account Name
                if(defaultRecTypeID != null
                   && defaultRecTypeID == userDefinedHHRecordTypeId) {
                       a.Name = UTIL_ACCT_Naming.strNameHHAccountForContact(new List<Contact>{c});
                   } else if(defaultRecTypeID != null
                             && defaultRecTypeID == userDefinedAdminRecordTypeId) {
                                 a.Name = UTIL_ACCT_Naming.strNameAdmAccountForContact(c);
                             } else {
                                 a.Name = UTIL_ACCT_Naming.strNameAccountForContact(c);
                             }

                //Sets the Contact as the primary Contact for the newly created Account
                if (c.Id != NULL) {
                    a.Primary_Contact__c = c.Id;
                    if (Advancement_Info.useAdv() && Advancement_Info.getApiHEDA() != null) {
                        Advancement_Info.getApiHEDA().primaryContact(a, c.Id);
                    }
                }

                //Gives it the default record type selected in the settings
                if(defaultRecTypeID != null) {
                    a.RecordTypeID = defaultRecTypeID;
                }

                //Additional logic check for HH Account recordType
                if(defaultRecTypeID == UTIL_CustomSettingsFacade.getSettings().Household_Addresses_RecType__c) {
                    ADDR_Addresses_UTIL.copyAddressStdSObj(c, 'Mailing', a, 'Billing');
                    ADDR_Addresses_UTIL.copyAddressStdSObj(c, 'Other', a, 'Shipping');
                    ADDR_Contact_TDTM.afterAutomaticAccInsert = true;
                }

                //Inject Advancement logic to populate NPSP Account fields of the Contact
                if(Advancement_Info.useAdv() && Advancement_Info.getApiHEDA() != NULL) {
                    Advancement_Info.getApiHEDA().configAccountForContact(a);
                }
                accountInserts.add(a);
                listContactNewAcct.add(c);
            }
        }
        if (accountInserts.size() > 0) {
            UTIL_Debug.debug('****Number of accounts to insert: ' + accountInserts.size());
            // We can't use dmlWrapper because we need to get the new AccountID's into the Contacts.
            // We do want it to be all or nothing, so errors won't get lost.
            insert accountInserts;
            Integer i = 0;
            for (Contact c : listContactNewAcct) {
                // For each success, write the new AccountId to the Contact.
                c.AccountId = accountInserts[i].Id;
                contactsToUpdate.add(c);
                i += 1;
            }
        }
        update contactsToUpdate;
    }

    /*******************************************************************************************************
	* @description Updates an Account's naming, primary contact, and rollups
	* @param listAccountId the list of Account (Id's) that need updating.
	* @param dmlWrapper to hold the Accounts that need updating.
	* @return void
	*/
    private void updateParentAcc(List<Id> listAccountId, DmlWrapper dmlWrapper) {
        resetPrimaryContactForAccount(listAccountId, dmlWrapper);

        //Inject Adv logic to do the rollup for Account
        if(Advancement_Info.useAdv() && Advancement_Info.getApiHEDA() != null) {
            Advancement_Info.getApiHEDA().rollupAccounts(listAccountId);
        }
    }

    /*******************************************************************************************************
	* @description sets the Primary Account for each Account in the list of Accounts
	* @param listAccountId the list of Account (Id's) that need updating.
	* @param dmlWrapper to hold the Accounts that need updating.
	* @return void
	*/
    private void resetPrimaryContactForAccount(List<Id> listAccountId, DmlWrapper dmlWrapper) {
        Set<Id> setPrimaryContactIds = new Set<Id>();
        Set<Id> setAccToResetIds = new Set<Id>();
        List<Account> listAccToUpdate = new List<Account>();

        //Builds a set of primary Contact Ids from the Account given existing AccountIds
        List<Account> listAccount = [SELECT Primary_Contact__c,
                                     (SELECT Id
                                      FROM Contacts
                                      LIMIT 1)
                                     FROM Account
                                     WHERE Id IN :listAccountId];

        //Retrieves the Primary_Contact__c from the Account
        for (Account acc : listAccount) {
            if (acc.Primary_Contact__c != NULL)
                setPrimaryContactIds.add(acc.Primary_Contact__c);
        }


        if (setPrimaryContactIds.size() > 0) {
            for (Account acc : [SELECT Primary_Contact__c,
                                (SELECT Id
                                 FROM Contacts
                                 WHERE Id IN :setPrimaryContactIds
                                 LIMIT 1)
                                FROM Account
                                WHERE Id IN : listAccountId]) {
                                    //There are two cases account primary contact needs reset
                                    //1. An account has no child contact but it used to have primary contact
                                    //2. An account used to have no child contact but a contact was just assigned to it
                                    if (acc.Contacts.size() == 0 || acc.Primary_Contact__c == NULL) {
                                        setAccToResetIds.add(acc.Id);
                                    }
                                }
        } else {
            setAccToResetIds.addAll(listAccountId);
        }

        //If setAccToResetIds is empty, skip dml and return
        if (setAccToResetIds.size() == 0) {
            return;
        }

        //For each account need to be reset
        for (Account acc : listAccount) {
            if (setAccToResetIds.contains(acc.Id)) {
                if (acc.Contacts.size() > 0) {
                    //If any child contact exists, use one as primary contact
                    acc.Primary_Contact__c = acc.contacts[0].Id;
                    //Inject Adv logic to handle npsp primary contact of the Account
                    if(Advancement_Info.useAdv() && Advancement_Info.getApiHEDA() != NULL) {
                        Advancement_Info.getApiHEDA().primaryContact(acc, acc.contacts[0].Id);
                    }
                } else {
                    //If no child contact exists, clear up primary contact
                    acc.Primary_Contact__c = NULL;
                }
                listAccToUpdate.add(acc);
            }
        }

        //Now do the update
        dmlWrapper.objectsToUpdate.addAll((List<SObject>)listAccToUpdate);
    }

    /*******************************************************************************************************
	* @description Updates Accounts with the primary Individual Contact Id.
	* @param mapAccountIdContactId a map of AccountId's to ContactId's which specifies which accounts need updating.
	* @param dmlWrapper to hold the Accounts that need updating.
	* @return void
	*/
    private void updateAccountPrimaryContact(Map<Id,Id> mapAccountIdContactId, DmlWrapper dmlWrapper) {
        List<Account> listAccount = new List<Account>();
        for (Id i : mapAccountIdContactId.keySet()) {
            Account a = new Account(Id = i, Primary_Contact__c = mapAccountIdContactId.get(i));
            //Inject the Adv logic to handle npsp primary contact of the Account
            if(Advancement_Info.useAdv() && Advancement_Info.getApiHEDA() != NULL) {
                Advancement_Info.getApiHEDA().primaryContact(a, mapAccountIdContactId.get(i));
            }
            listAccount.add(a);
        }
        if (listAccount.size() > 0) {
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)listAccount);
        }
    }



}