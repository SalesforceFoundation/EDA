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
    private static ID defaultRecTypeId = UTIL_CustomSettingsFacade.getSettings().Account_Processor__c;

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
    private static Set<String> easternOrderLanguages = new Set<String> {
        'ja','ko','vi','hu','ro','zh_CN','zh_TW'
            };

    /*******************************************************************************************************
    * @description The current user's Locale/Language
    */
    private static String orgLanguage {
        get {
    	    if (orgLanguage == null) {
            //[Select LanguageLocaleKey From Organization].LanguageLocaleKey;
                orgLanguage = UserInfo.getLocale();
            }
            return orgLanguage;
        }
        set;
    }

    public TDTM_Runnable.Action triggerAction;

    /*******************************************************************************************************
    * @description Trigger Handler on Contact that handles account management. Depending on the Account
    * Model, creates a Household Account, One-to-One Account, or uses the Individual Bucket Account.
    * @param listNew a list of Contacts from trigger new.
    * @param listOld a list of Contacts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Contacts.
    * @return dmlWrapper.
    */
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
                                   TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        List<Contact> newContacts = (List<Contact>)newlist;
        List<Contact> oldContacts = (List<Contact>)oldlist;
        this.triggerAction = triggerAction;
        DmlWrapper dmlWrapper = new DmlWrapper();

        //Requery Contacts to include Account information
        if (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            if (newContacts.size() > 0) {
                newContacts = queryContacts(newContacts);
            }
        }

        if (triggerAction == TDTM_Runnable.Action.AfterInsert &&
            !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert)) {
                handlesAfterInsertUpdate(newContacts, oldContacts, triggerAction);
            }

        if (triggerAction == TDTM_Runnable.Action.AfterUpdate &&
            !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update)) {
                handlesAfterInsertUpdate(newContacts, oldContacts, triggerAction);
            }

        if (triggerAction == TDTM_Runnable.Action.AfterDelete &&
            !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Delete)) {
                handlesAfterDelete(oldContacts);
            }

        dmlWrapper = null;
        return dmlWrapper;
    }

    /*******************************************************************************************************
    * @description Retrieves additional Contact and Account information.
    * @param contacts a list of Contacts from trigger new.
    * @return list.
    */
    private static List<Contact> queryContacts(List<Contact> newContacts) {
        List<Contact> returnedContacts = new List<Contact>();

        String dynamicSoql = 'SELECT Id, AccountId, Account.RecordTypeID, ' +
                           'Account.Primary_Contact__c, Account.Name, FirstName, ' +
                           'LastName, OwnerId, Salutation, ' +
                           'MailingStreet, MailingCity, MailingState, ' +
                           'MailingPostalCode, MailingCountry, MailingLatitude, ' +
                           'MailingLongitude, OtherStreet, OtherCity, ' +
            			   'OtherState, OtherPostalCode, OtherCountry, ' +
                           'OtherLatitude, OtherLongitude, Exclude_from_Household_Name__c,';

        if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
            dynamicSoql += 'MailingCountryCode, MailingStateCode, OtherCountryCode, OtherStateCode, ';
        }

        dynamicSoql += 'Phone, Fax FROM Contact WHERE Id IN :newContacts';

        returnedContacts = database.query(dynamicSoql);

        return returnedContacts;
    }

    /*******************************************************************************************************
    * @description Calls correct methods to process after insert and after update
    * logic and sets recursion flag.
    * @param contacts a list of Contacts from trigger new.
    * @param oldContacts a list of Contacts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @return void.
    */
    private void handlesAfterInsertUpdate(Contact [] newContacts, Contact [] oldContacts, TDTM_Runnable.Action triggerAction) {
        List<Contact> contactsNeedAccounts = new List<Contact>();
        HandleUpdateWrapperLogic updateWrapper;
        HandleInsertWrapperLogic insertWrapper;

        Integer i = 0;
        for (Contact c : newContacts) {

            //Account needs to be created if (1) Account does not exist or (2) Account model is not blank
            if (c.AccountId == NULL && defaultRecTypeId != NULL) {
                contactsNeedAccounts.add(c);
            }

            //AFTER INSERT
            if (triggerAction == TDTM_Runnable.Action.AfterInsert &&
                !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert)) {
                    insertWrapper = new HandleInsertWrapperLogic (c);
                }

            //AFTER UPDATE
            if (triggerAction == TDTM_Runnable.Action.AfterUpdate &&
                !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update)) {
                    updateWrapper = new HandleUpdateWrapperLogic (c, oldContacts, triggerAction, i);
                }
            i += 1;
        }

        //Set recursion flag
        if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert, true);
        }

        if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update, true);
        }

        if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Delete, true);
        }

        handleInsertProcessing(insertWrapper, contactsNeedAccounts);
        handleUpdateProcessing(updateWrapper, contactsNeedAccounts);
    }

    /*******************************************************************************************************
    * @description Processes after insert logic.
    * @return HandleInsertWrapperLogic.
    */
    private class HandleInsertWrapperLogic {
        public Map<Id,Id> accIdConIdToUpdate = new Map<Id,Id>();
        public Set<Id> accountIdToRename = new Set<Id>();

        private HandleInsertWrapperLogic(Contact c) {
            if (c.AccountId != NULL) {
                //(1) If the Contact is connected to an Account but Primary_Contact__c on Account is NULL
                if (c.Account.Primary_Contact__c == NULL) {
                    accIdConIdToUpdate.put(c.AccountId, c.Id);
                }

                //(2) If Contacts are connected to Accounts, make the association in the other direction
                if (checkHouseholdNaming(c.Account.RecordTypeID)) {
                    accountIdToRename.add(c.AccountId);
                }
            }
        }
    }

    /*******************************************************************************************************
    * @description This method checks if any of the after insert collections are not empty.
    * If not empty, it calls the appropriate methods to process the list/set/map.
    * @param insertWrapper contains the collections processed from after insert context.
    * @param contactsNeedAccounts a list of Contacts that needs new Accounts or an update.
    * @return void.
    */
    private void handleInsertProcessing(HandleInsertWrapperLogic insertWrapper, Contact[] contactsNeedAccounts) {
        DmlWrapper dmlWrapper = new DmlWrapper();

        //Creates new Account
        if (contactsNeedAccounts.size() > 0) {
            UTIL_Debug.debug('****Number of Contacts that need Accounts created: ' + contactsNeedAccounts.size());
            insertContactAccount(contactsNeedAccounts, dmlWrapper);
        }

        if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
            Map<Id,Id> updateAccPrimaryContact = insertWrapper.accIdConIdToUpdate;
            Set<Id> accountIdHHToRename = insertWrapper.accountIdToRename;

            //Updates the Primary Contact Field on New Account
            if (updateAccPrimaryContact.size() > 0) {
                updateAccountPrimaryContact(updateAccPrimaryContact, dmlWrapper);
            }

            //Updates Household Account name
            if (accountIdHHToRename.size() > 0) {
                UTIL_ACCT_Naming.updateHHAccountsName(accountIdHHToRename);
            }

            TDTM_TriggerHandler.processDML(dmlWrapper, true);
            updateRecursionFlag();
        }
    }

    /*******************************************************************************************************
    * @description Processes after update logic.
    * @param c is a Contact record from trigger new.
    * @param oldContacts is a list of Contacts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param i is an integer counter.
    * @return HandleUpdateWrapperLogic.
    */
    private class HandleUpdateWrapperLogic {
        public Map<Id,Id> contactIdAccountIdNewOppsToMove = new Map<Id,Id>();
        public Map<Id,Id> contactIdAccountIdOldOppsToMove = new Map<Id,Id>();
        public Map<Id,Contact> contactIdContactOwnerChange = new Map<Id,Contact>();
        public Set<Id> accountIdToRename = new Set<Id>();
        public List<Id> accountIdToUpdate = new List<Id>();
        public List<Contact> contactsChangedLastName = new List<Contact>();


        private HandleUpdateWrapperLogic(Contact c, Contact [] oldContacts, TDTM_Runnable.Action triggerAction, Integer i) {

            //If Account has changed :  (1) Update the Account's name (2) Move Opportunity
            if (c.AccountId != oldContacts[i].AccountId) {
                if(c.AccountId != NULL) {
                    accountIdToUpdate.add(c.AccountId);
                    contactIdAccountIdNewOppsToMove.put(c.Id, c.AccountId);

                    if (checkHouseholdNaming(c.Account.RecordTypeId)) {
                        accountIdToRename.add(c.AccountId);

                        if(oldContacts[i].AccountId != NULL) {
                            accountIdToRename.add(oldContacts[i].AccountId);
                        }
                    }
                }  else {
                    if (UTIL_CustomSettingsFacade.getSettings().Automatic_Household_Naming__c == TRUE) {
                        accountIdToRename.add(oldContacts[i].AccountId);
                    }
                }

                //Old HH Accounts that don't get deleted still need to have name redone
                if (oldContacts[i].AccountId != NULL) {
                    accountIdToupdate.add(oldContacts[i].AccountId);
                    contactIdAccountIdOldOppsToMove.put(c.Id, oldContacts[i].AccountId);
                }
            }

            //If Ownership has changed
            if (c.OwnerId != oldContacts[i].OwnerId) {
                contactIdContactOwnerChange.put(c.Id, c);
            }

            //If Contact's last name has changed and it is using admin account model
            if (c.LastName != oldContacts[i].LastName && c.AccountId != NULL) {
                contactsChangedLastName.add(c);
            }

            //If Contact Name or Exclude_from_Household_Name__c value has changed
            if ((c.LastName != oldContacts[i].LastName ||
                 c.FirstName != oldContacts[i].FirstName ||
                 c.Exclude_from_Household_Name__c != oldContacts[i].Exclude_from_Household_Name__c) &&
                c.AccountId != NULL &&
                checkHouseholdNaming(c.Account.RecordTypeId))
            {
                accountIdToRename.add(c.AccountId);
            }
        }
    }

    /*******************************************************************************************************
    * @description This method checks if any of the after update collections are not empty.
    * If not empty, it calls the appropriate methods to process the list/set/map.
    * param updateWrapper contains the collections processed from after update context.
    * param contactsNeedAccounts a list of Contacts that needs new Accounts or an update.
    * @return void.
    */
    private void handleUpdateProcessing(HandleUpdateWrapperLogic updateWrapper, Contact[] contactsNeedAccounts) {
        DmlWrapper dmlWrapper = new DmlWrapper();

        //Creates new Account
        if (contactsNeedAccounts.size() > 0) {
            UTIL_Debug.debug('****Number of Contacts that need Accounts created: ' + contactsNeedAccounts.size());
            insertContactAccount(contactsNeedAccounts, dmlWrapper);
        }

        if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            List<Contact> contactChangedLastName = updateWrapper.contactsChangedLastName;
            List<Id> accountIdsToUpdate = updateWrapper.accountIdToUpdate;
            Set<Id> accountIdsToRename = updateWrapper.accountIdToRename;
            Map<Id,Contact> contactsOwnerChange = updateWrapper.contactIdContactOwnerChange;
            Map<Id,Id> conIdAccIdNewOppsToMove = updateWrapper.contactIdAccountIdNewOppsToMove;
            Map<Id,Id> conIdAccIdOldOppsToMove = updateWrapper.contactIdAccountIdOldOppsToMove;

            //Updates Household Account name
            if (accountIdsToRename.size() > 0) {
                UTIL_ACCT_Naming.updateHHAccountsName(accountIdsToRename);
            }

            //Updates existing Account Primary Contact
            if (accountIdsToUpdate.size() > 0) {
                updateParentAcc(accountIdsToUpdate, dmlWrapper);
            }

            //Updates Account Owner to match Contact Owner change
            if (contactsOwnerChange.size() > 0) {
                updateOwners(contactsOwnerChange, dmlWrapper);
            }

            //Inject Adv logic to handle moving opportunity
            if (conIdAccIdNewOppsToMove.size() > 0 && Advancement_Info.useAdv() && Advancement_Info.getApiHEDA() != null) {
                Advancement_Info.getApiHEDA().moveOppsToContactAccount(conIdAccIdNewOppsToMove, conIdAccIdOldOppsToMove);
            }

            //Updates Admin Account Name
            if (contactChangedLastName.size() > 0) {
                dmlWrapper.objectsToUpdate.addAll((List<SObject>)UTIL_ACCT_Naming.updateAdminAccountsName(contactChangedLastName));
            }

            TDTM_TriggerHandler.processDML(dmlWrapper, true);
            updateRecursionFlag();

        }
    }

    /*******************************************************************************************************
    * @description Processes after delete logic.
    * @param oldContacts is a list of Contacts from trigger old.
    * @return void.
    */
    private void handlesAfterDelete(Contact[] oldContacts) {
        List<Contact> contactAccountDelete = new List<Contact>();
        List<Account> relatedAccounts = new List<Account>();
        Set<Id> accountIdsToRename = new Set<Id>();
        Set<Id> relatedAccountIds = new Set<Id>();

        for (Contact c : oldContacts) {
            contactAccountDelete.add(c);
            relatedAccountIds.add(c.AccountId);
        }

        //Requery to retrieve correct Account value
        relatedAccounts = [SELECT Id, RecordTypeID
                           FROM Account
                           WHERE Id IN : relatedAccountIds];

        for (Account account : relatedAccounts) {
            if (checkHouseholdNaming(account.RecordTypeID)) {
                accountIdsToRename.add(account.Id);
            }
        }
        handleDeleteProcessing(accountIdsToRename, contactAccountDelete);
    }

    /*******************************************************************************************************
    * @description This method checks if any of the after update collections are not empty.
    * If not empty, it calls the appropriate methods to process the list/set/map.
    * @param contactAccountDelete a list of Contacts whose Accounts needs deletion.
    * @param accountIdsToRename a set of AccountIds that needs Name update.
    * @return void.
    */
    private void handleDeleteProcessing(Set<Id> accountIdsToRename, Contact[] contactAccountDelete) {
        DmlWrapper dmlWrapper = new DmlWrapper();

        if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            //Updates Household Account name
            if (accountIdsToRename.size() > 0) {
                UTIL_ACCT_Naming.updateHHAccountsName(accountIdsToRename);
            }

            //Deletes old Account if they are left hanging around
            if (contactAccountDelete.size() > 0) {
                UTIL_Debug.debug('****Number of accs to delete: ' + contactAccountDelete.size());
                deleteContactAccountsIfEmpty(contactAccountDelete, dmlWrapper);
            }

            TDTM_TriggerHandler.processDML(dmlWrapper, true);
            updateRecursionFlag();
        }
    }

    /*******************************************************************************************************
    * @description This method sets the recursionflag to false for each triggerAction.
    * @return void.
    */
    private void updateRecursionFlag() {
        if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert, false);
        } else if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update, false);
        } else if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Delete, false);
        }
    }

    /*******************************************************************************************************
    * @description Inserts a new Account for an Individual Contact or if Account already exist, updates the
    * AccountId to the newly inserted Contact.
    * @param contacts is a list of Contacts from trigger new or update that needs new Accounts or update.
    * @param dmlWrapper to hold the Contacts that needs update.
    * @return void.
    */
    private void insertContactAccount(Contact[] contacts, DmlWrapper dmlWrapper) {
        List<Id> contactIds = new List<Id>();
        List<Account> accountInserts = new List<Account>();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> contactsWithNewAccount = new list<Contact>();
        Map<Id,Account> primaryConIdForAccount = new Map<Id,Account>();

        //Tracks which Contacts are being inserted vs. updated
        for (Contact c : contacts) {
            if (c.Id != NULL) {
                contactIds.add(c.Id);
            }
        }

        //Retrieves all Accounts that have a connected Primary Contact
        for (Account acc : [SELECT Id, Primary_Contact__c, RecordTypeId
                            FROM Account
                            WHERE Primary_Contact__c IN : contactIds])
        {
            primaryConIdForAccount.put(acc.Primary_Contact__c, acc);

        }

        //Determines if Account needs to be created
        for (Contact c : contacts) {
            //If we find an Account already connect to this Contact, connect the Contact to the Account if it is the correct
            //type for the current Account processor.
            Account acc = primaryConIdForAccount.get(c.Id);

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

                if (defaultRecTypeID != NULL) {
                    a.Name = UTIL_ACCT_Naming.updateName(new List<Contact>{c});
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
                contactsWithNewAccount.add(c);
            }
        }

        if (accountInserts.size() > 0) {
            UTIL_Debug.debug('****Number of accounts to insert: ' + accountInserts.size());
            // We can't use dmlWrapper because we need to get the new AccountID's into the Contacts.
            // We do want it to be all or nothing, so errors won't get lost.
            insert accountInserts;

            Integer i = 0;
            for (Contact c : contactsWithNewAccount) {
                // For each success, write the new AccountId to the Contact.
                c.AccountId = accountInserts[i].Id;
                contactsToUpdate.add(c);
                i += 1;
            }
        }

        if (contactsToUpdate.size() > 0) {
            update contactsToUpdate;
        }
    }

    /*******************************************************************************************************
    * @description Updates an Account's naming, primary contact, and rollups.
    * @param accountIdsToUpdate the list of Account (Id's) that needs update.
    * @param dmlWrapper to hold the Accounts that needs update.
    * @return void.
    */
    private void updateParentAcc(List<Id> accountIdsToUpdate, DmlWrapper dmlWrapper) {
        resetPrimaryContactForAccount(accountIdsToUpdate, dmlWrapper);

        //Inject Adv logic to do the rollup for Account
        if(Advancement_Info.useAdv() && Advancement_Info.getApiHEDA() != null) {
            Advancement_Info.getApiHEDA().rollupAccounts(accountIdsToUpdate);
        }
    }

    /*******************************************************************************************************
    * @description sets the Primary Account for each Account in the list of Accounts
    * @param accountIdsToUpdate a list of Account (Id's) that needs update.
    * @param dmlWrapper to hold the Accounts that needs update.
    * @return void.
    */
    private void resetPrimaryContactForAccount(List<Id> accountIdsToUpdate, DmlWrapper dmlWrapper) {
        Set<Id> primaryContactId = new Set<Id>();
        Set<Id> accountsToResetIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();

        //Builds a set of primary Contact Ids from the Account given existing AccountIds
        List<Account> listAccount = [SELECT Primary_Contact__c,
                                     (SELECT Id, Name FROM Contacts LIMIT 1)
                                     FROM Account
                                     WHERE Id IN :accountIdsToUpdate];

        //Retrieves the Primary_Contact__c from the Account
        for (Account acc : listAccount) {
            if (acc.Primary_Contact__c != NULL)
                primaryContactId.add(acc.Primary_Contact__c);
        }

        if (primaryContactId.size() > 0) {
            for (Account acc : [SELECT Primary_Contact__c,
                                (SELECT Id, Name FROM Contacts WHERE Id IN :primaryContactId LIMIT 1)
                                FROM Account
                                WHERE Id IN : accountIdsToUpdate])
            {
                //There are two cases account primary contact needs reset
                //1. An account has no child contact but is used to have primary contact
                //2. An account used to have no child contact but a child contact was just assigned to it
                if (acc.Contacts.size() == 0 || acc.Primary_Contact__c == NULL) {
                    accountsToResetIds.add(acc.Id);
                }
            }
        } else {
            accountsToResetIds.addAll(accountIdsToUpdate);
        }

        //If accountsToResetIds is empty, skip dml and return
        if (accountsToResetIds.size() == 0) {
            return;
        }

        //For each account that needs to be reset
        for (Account acc : listAccount) {
            accountsToResetIds.addAll(accountIdsToUpdate);
            if (accountsToResetIds.contains(acc.Id)) {
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
                accountsToUpdate.add(acc);
            }
        }

        if (accountsToUpdate.size() > 0) {
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)accountsToUpdate);
        }
    }

    /*******************************************************************************************************
    * @description Updates Accounts with the primary Individual Contact Id (specifically during Account creation).
    * @param updateAccPrimaryContact a map of AccountId's to ContactId's which specifies which accounts need update.
    * @param dmlWrapper to hold the Accounts that need update.
    * @return void.
    */
    private void updateAccountPrimaryContact(Map<Id,Id> updateAccPrimaryContact, DmlWrapper dmlWrapper) {
        List<Account> accountsToUpdate = new List<Account>();

        for (Id i : updateAccPrimaryContact.keySet()) {
            Account a = new Account(Id = i, Primary_Contact__c = updateAccPrimaryContact.get(i));
            //Inject the Adv logic to handle npsp primary contact of the Account
            if(Advancement_Info.useAdv() && Advancement_Info.getApiHEDA() != NULL) {
                Advancement_Info.getApiHEDA().primaryContact(a, updateAccPrimaryContact.get(i));
            }
            accountsToUpdate.add(a);
        }

        if (accountsToUpdate.size() > 0) {
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)accountsToUpdate);
        }
    }

    /*******************************************************************************************************
    * @description Contact's owner has changed. Consider updating related account owner.
    * @param contactOwnerChange a map of Contact Id to Contact, for the contacts to consider.
    * @param dmlWrapper to hold the Contacts that need update.
    * @return void
    */
    private void updateOwners(map<Id, Contact> contactOwnerChange, DmlWrapper dmlWrapper) {
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id> contactsAccountId = new Set<Id>();

        if (contactOwnerChange.size() > 0) {

            for (Contact con : contactOwnerChange.values()) {
                contactsAccountId.add(con.AccountId);
            }

            List<Account> listAcc = [SELECT Id, RecordTypeId, Primary_Contact__c, OwnerId,
                                     (SELECT Id FROM Contacts limit 2)
                                     FROM Account
                                     WHERE Id IN :contactsAccountId];

            for (Account acc : listAcc) {
                //TODO: use setting to determine if Account owner should be changed (W-009780)
                if (acc.RecordTypeId != NULL
                    && (acc.RecordTypeId == userDefinedHHRecordTypeId
                        || acc.RecordTypeId == userDefinedAdminRecordTypeId)) {
                            if (acc.Contacts.size() == 1 && acc.Primary_Contact__c != NULL) {

                                Contact c = contactOwnerChange.get(acc.Primary_Contact__c);
                                Id ownerIdContact = (c != NULL ? c.OwnerId : NULL);

                                if (acc.OwnerId != ownerIdContact) {
                                    acc.OwnerId = ownerIdContact;
                                    accountsToUpdate.add(acc);
                                }
                            }
                        }
            }

            if (accountsToUpdate.size() > 0) {
                dmlWrapper.objectsToUpdate.addAll((List<SObject>)accountsToUpdate);
            }
        }
    }

    /*******************************************************************************************************
    * @description Deletes the accounts for contacts that have been deleted if they are empty (no ops, no hh members).
    * @param contactAccountDelete the list of Contacts that need to be considered.
    * @param dmlWrapper to hold the Accounts that needs update.
    * @return void.
    */
    public void deleteContactAccountsIfEmpty(Contact[] contactAccountDelete, DmlWrapper dmlWrapper) {
        List<Id> accountIds = new List<Id>();
        List<Id> accountIdsUpdate = new list<Id>();
        List<Account> accountsOnContacts = new List<Account>();
        List<SObject> accountsForDeletion = new List<SObject>();

        if (contactAccountDelete.size() > 0) {
            for (Contact thisContact : contactAccountDelete) {
                accountIds.add(thisContact.accountId);
            }

            accountsOnContacts = [SELECT Id, Type, RecordTypeId,
                                  (SELECT Id FROM Opportunities LIMIT 1),
                                  (SELECT Id FROM Contacts LIMIT 1)
                                  FROM Account
                                  WHERE Id IN :accountIds];

            for (Account thisAccount : accountsOnContacts) {
                //Looking at setting to determine which account types can be deleted (W-009779)
                if (UTIL_CustomSettingsFacade.getSettings().Accounts_to_Delete__c != null && thisAccount.RecordTypeId != null
                    && UTIL_CustomSettingsFacade.getSettings().Accounts_to_Delete__c.contains(thisAccount.RecordTypeId)) {

                        // If there are no Opportunities && Contacts for this Account, add the Account for deletion
                        if (thisAccount.Opportunities.size() == 0 && thisAccount.Contacts.size() == 0) {
                            accountsForDeletion.add(thisAccount);
                        } else if (thisAccount.RecordTypeId != null
                                   && (thisAccount.RecordTypeId == userDefinedHHRecordTypeId
                                       || thisAccount.RecordTypeId == userDefinedAdminRecordTypeId)) {
                                           accountIdsUpdate.add(thisAccount.Id);
                                       }
                    }
            }
        }

        //Delete the accounts
        if (accountsForDeletion.size() > 0) {
            dmlWrapper.objectsToDelete.addAll(accountsForDeletion);
        }

        //Update any HH accounts that just lost a contact
        if (accountIdsUpdate.size() > 0) {
            updateParentAcc(accountIdsUpdate, dmlWrapper);
        }
    }

    /*******************************************************************************************************
    * @description Check if all conditions for household naming are met
    * @param accRecordTypeId the Id of parent Account's record type Id.
    * @return boolean.
    */
    public static boolean checkHouseholdNaming(Id accRecordTypeId) {

        if (accRecordTypeId != null
            && accRecordTypeId == userDefinedHHRecordTypeId
            && UTIL_CustomSettingsFacade.getSettings().Automatic_Household_Naming__c == true)
        {
            return true;
        } else {
            return false;
        }
    }
}