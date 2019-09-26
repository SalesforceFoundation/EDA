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


    public TDTM_Runnable.Action triggerAction;
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

        List<Contact> contacts = (List<Contact>)newlist;
        List<Contact> oldContacts = (List<Contact>)oldlist;
        this.triggerAction = triggerAction;
        DmlWrapper dmlWrapper = new DmlWrapper();

        //Requery Contacts to include Account information
        if (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
			if (contacts.size() > 0) {
                System.debug('beforeCallingContactQuery -->');
            	contacts = queryContacts(contacts);
            	System.debug('AfterCallingContactQuery -->' + contacts);
        	}
        }

        wrapperHandlesAfter wrapperList;

        System.debug('triggerAction -->' + triggerAction);
        System.debug('triggerAction Insert -->' + (!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert)));
        System.debug('triggerAction Update -->' + (!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update)));

        if (triggerAction == TDTM_Runnable.Action.AfterInsert &&
				!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert)) {
           		System.debug('InsideTriggerInsert&Update -->');
                wrapperList = handlesAfter(contacts, oldContacts, triggerAction);
                handleProcessing(wrapperList, NULL, NULL);
        }

        if (triggerAction == TDTM_Runnable.Action.AfterUpdate &&
            	!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update)) {
        		System.debug('InsideTriggerAfter --->');
               	wrapperList = handlesAfter(contacts, oldContacts, triggerAction);
                handleProcessing(wrapperList, NULL, NULL);
        }

       	if (triggerAction == TDTM_Runnable.Action.AfterDelete &&
        		!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Delete)) {
                System.debug('InsideTriggerDelete -->');
                handlesAfterDelete(oldContacts);
        }

		System.debug('BeforeSetting TDTM_ProcessControl --->');

        dmlWrapper = null;
    	return dmlWrapper;
	}

    private static List<Contact> queryContacts(List<Contact> contacts) {
        List<Contact> returnedContacts = new List<Contact>();

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

        returnedContacts = database.query(strSoql);
        System.debug('contactReturnQueryMethod -->' + returnedContacts);
        return returnedContacts;
    }

    private wrapperHandlesAfter handlesAfter(Contact [] contacts, Contact [] oldContacts, TDTM_Runnable.Action triggerAction) {
        wrapperHandlesAfter wrapper;

        System.debug('CheckTriggerContext -->' + triggerAction);
        //AfterInsert
        System.debug('handlesAfter triggerActionInsertResult -->' + (triggerAction == TDTM_Runnable.Action.AfterInsert &&
            !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert)));
        if (triggerAction == TDTM_Runnable.Action.AfterInsert &&
            !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert)) {
                System.debug('HandleAfterMethod Insert --->');
                wrapper = new wrapperHandlesAfter (contacts, oldContacts, triggerAction);
                System.debug('Wrapper insert -->' + wrapper);
            }

        //AfterUpdate
        System.debug('handlesAfter triggerActionInsertResult -->' + (triggerAction == TDTM_Runnable.Action.AfterUpdate &&
            !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update)));
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate &&
            !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update)) {
                System.debug('HandleAfterMethod Update --->');
                wrapper = new wrapperHandlesAfter (contacts, oldContacts, triggerAction);
				System.debug('Wrapper insert -->' + wrapper);
            }

        System.debug('SettingRecursionFlagSection --->');
       	//Set recursion flags
       	/*if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
				System.debug('SettingRecursion==InsertTrue -->');
	       		TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert, true);
       		}

       	if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            	System.debug('SettingRecursion==UpdateTrue -->');
           		TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update, true);
       		}

        if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            	TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Delete, true);
       		}*/

       	System.debug('handleProcessingCall Before -->');
       	//handleProcessing(wrapper, NULL, NULL);
       	System.debug('handleProcessingCall After -->');
        return wrapper;
    }
	/*******************************************************************************************************
		* @description Check if all conditions for household naming are met
		* @param accRecordTypeId the id of parent account's record type id
		* @return boolean
		*/
    	public  static boolean checkHouseholdNaming(Id accRecordTypeId) {
            System.debug('checkHouseholdNaming Method -->');
        	if (accRecordTypeId != null
            	&& accRecordTypeId == userDefinedHHRecordTypeId
            	&& UTIL_CustomSettingsFacade.getSettings().Automatic_Household_Naming__c == true) {
                    System.debug('checkHouseholdNaming True -->');
                	return true;
            } else {
                System.debug('checkHouseholdNaming False -->');
                return false;
            }
    	}
    private class wrapperHandlesAfter {
        public Map<Id,Id> mapAccountIdContactId = new Map<Id,Id>();
        public Map<Id,Id> mapContactIdAccountIdNewMoveOpps = new Map<Id,Id>();
        public Map<Id,Id> mapContactIdAccountIdOldMoveOpps = new Map<Id,Id>();
        public Map<Id,Contact> mapContactIdContactOwnerChange = new Map<Id,Contact>();
        public Set<Id> setAccountIdHHToRenameWP = new Set<Id>();
        public List<Id> listAccountIdHHToUpdate = new List<Id>();
        public List<Contact> listContactNeedAccount = new List<Contact>();
        public List<Contact> listContactsChangedLastName = new List<Contact>();

        private wrapperHandlesAfter(Contact[] contacts, Contact [] oldContacts, TDTM_Runnable.Action triggerAction) {
            System.debug('InsideWrapperHandlesAfter Method -->');
            Integer i = 0;
            System.debug('CheckInteger -->' + i);

            for (Contact c : contacts) {
                System.debug('InsideWrapperHandlesAfter ForLoop -->');

                //Account needs to be created if (1) Account does not exist or (2) Account model is not blank
                if (c.AccountId == NULL && defaultRecTypeId != NULL) {
                    System.debug('InsideWrapperHandlesAfter listContactNeedAccount -->');
                    listContactNeedAccount.add(c);
                    System.debug('InsideWrapperInsertlistContactNeedAccount -->' + listContactNeedAccount);
                }

                //After Insert
                if (triggerAction == TDTM_Runnable.Action.AfterInsert &&
            		!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert)) {
                    System.debug('InsideWrapperHandlesAfter Insert IF -->');
                    //Retrieve Accounts that needs to have the newly assigned Contact Id added to them if:
                    if (c.AccountId != NULL) {
                        System.debug('InsideContactHasAccount -->');
                        //(1) If the Contact is connected to an Account but Primary_Contact__c on Account is NULL
                        if (c.Account.Primary_Contact__c == NULL) {
                            System.debug('InsideWrapperHandlesAfter Insert PrimaryCon Check-->');
                            mapAccountIdContactId.put(c.AccountId, c.Id);
                            System.debug('InsideWrapperHandlesAfter Insert PrimaryCon Check-->' + mapAccountIdContactId);
                        }
                        //(2) If Contacts are connected to Accounts, make the association in the other direction
                        if (checkHouseholdNaming(c.Account.RecordTypeID)) {
                            System.debug('InsideWrapperHandlesAfter Insert checkHouseholdNaming Check-->');
                            setAccountIdHHToRenameWP.add(c.AccountId);
                            System.debug('InsideWrapperHandlesAfter Insert checkHouseholdNaming Check-->' + setAccountIdHHToRenameWP);
                        }
                    }
                    System.debug('InsideWrapperHandlesAfter Insert ContactHasNOAccount -->');
                }

                //After Update
                if (triggerAction == TDTM_Runnable.Action.AfterUpdate &&
                    !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update)) {
                    System.debug('InsideWrapperHandlesAfter Update -->');
                    //If Account has changed (1) Update the Account's name (2) Move Opportunity

                    if (c.AccountId != oldContacts[i].AccountId) {
                        System.debug('InsideWrapperHandlesAfter Update AccountIdNotChanged -->');
                        if(c.AccountId != NULL) {
                            System.debug('InsideWrapperHandlesAfter Update AccountIdNotBlank -->');
                            listAccountIdHHToUpdate.add(c.AccountId);
                            mapContactIdAccountIdNewMoveOpps.put(c.Id, c.AccountId);
                            System.debug('InsideWrapperHandlesAfter Update listAccountIdHHToUpdate -->' + listAccountIdHHToUpdate);
                            System.debug('InsideWrapperHandlesAfter Update mapContactIdAccountIdNewMoveOpps -->' + mapContactIdAccountIdNewMoveOpps);

                            if (checkHouseholdNaming(c.Account.RecordTypeId)) {
                                System.debug('InsideWrapperHandlesAfter Update checkHouseholdNaming -->' );
                                setAccountIdHHToRenameWP.add(c.AccountId);
                                System.debug('InsideWrapperHandlesAfter Update checkHouseholdNaming -->' + setAccountIdHHToRenameWP);

                                if(oldContacts[i].AccountId != NULL) {
                                    System.debug('InsideWrapperHandlesAfter Update oldConAcctIdNotBlank -->' );
                                    setAccountIdHHToRenameWP.add(oldContacts[i].AccountId);
                                    System.debug('InsideWrapperHandlesAfter Update oldConAcctIdNotBlank -->' + setAccountIdHHToRenameWP);
                                }
                            }
                        }  else {
                            if (UTIL_CustomSettingsFacade.getSettings().Automatic_Household_Naming__c == TRUE) {
                                System.debug('InsideWrapperHandlesAfter Update AutomaticHouseholdNaming -->' );
                                setAccountIdHHToRenameWP.add(oldContacts[i].AccountId);
                                System.debug('InsideWrapperHandlesAfter Update AutomaticHouseholdNaming -->' + setAccountIdHHToRenameWP);
                            }
                        }

                        //Old HH Accounts that don't get deleted still need to have name redone
                        if (oldContacts[i].AccountId != NULL) {
                            System.debug('InsideWrapperHandlesAfter Update oldConAccNotBlank 262 -->' );
                            listAccountIdHHToUpdate.add(oldContacts[i].AccountId);
                            mapContactIdAccountIdOldMoveOpps.put(c.Id, oldContacts[i].AccountId);
                            System.debug('InsideWrapperHandlesAfter Update oldConAccNotBlank listAccountIdHHToUpdate -->' + listAccountIdHHToUpdate);
                            System.debug('InsideWrapperHandlesAfter Update oldConAccNotBlank mapContactIdAccountIdOldMoveOpps -->' + mapContactIdAccountIdOldMoveOpps);
                        }
                    }

                    //If Ownership has changed
                    if (c.OwnerId != oldContacts[i].OwnerId) {
                        System.debug('InsideWrapperHandlesAfter Update ConOwnerIdNotChanged --->');
                        mapContactIdContactOwnerChange.put(c.Id, c);
                        System.debug('InsideWrapperHandlesAfter Update ConOwnerIdNotChanged --->' + mapContactIdContactOwnerChange);
                    }

                    //If Contact's last name has changed and it is using admin account model
                    if (c.LastName != oldContacts[i].LastName && c.AccountId != NULL) {
                        System.debug('InsideWrapperHandlesAfter Update LastNameChanged --->');
                        listContactsChangedLastName.add(c);
                        System.debug('InsideWrapperHandlesAfter Update LastNameChanged --->' + listContactsChangedLastName);
                    }

                    //If Contact Name or Exclude_from_Household_Name__c value has changed
                    if ((c.LastName != oldContacts[i].LastName ||
                         c.FirstName != oldContacts[i].FirstName ||
                         c.Exclude_from_Household_Name__c != oldContacts[i].Exclude_from_Household_Name__c) &&
                        c.AccountId != NULL &&
                        checkHouseholdNaming(c.Account.RecordTypeId)) {
                            System.debug('InsideWrapperHandlesAfter Update NameChanged OR ExcludeHHName --->');
                            setAccountIdHHToRenameWP.add(c.AccountId);
                            System.debug('InsideWrapperHandlesAfter Update NameChanged OR ExcludeHHName --->' + setAccountIdHHToRenameWP);
                        }
                }
                i += 1;
            }

            System.debug('SettingRecursionFlagSection --->');
       		//Set recursion flags
       		if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
				System.debug('SettingRecursion==InsertTrue -->');
	       		TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert, true);
       			}

       		if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            	System.debug('SettingRecursion==UpdateTrue -->');
           		TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update, true);
       		}

        	if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            	TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Delete, true);
       		}

        }


    }

    private void handlesAfterDelete(Contact[] oldContacts) {
        List<Contact> listContactAccountDelete = new List<Contact>();
    	List<Account> relatedAccounts = new List<Account>();
   		Set<Id> setAccountIdHHToRename = new Set<Id>();
        Set<Id> relatedAccountIds = new Set<Id>();
        wrapperHandlesAfter wp;


        System.debug('handlesAfterDelete -->');
        for (Contact c : oldContacts) {
            listContactAccountDelete.add(c);
            relatedAccountIds.add(c.AccountId);
            System.debug('handlesAfterDelete listContactAccountDelete -->'+ listContactAccountDelete);
            System.debug('handlesAfterDelete relatedAccountIds -->'+ relatedAccountIds);
        }

        //Requery to retrieve correct Account value
        relatedAccounts = [SELECT Id, RecordTypeID
                           FROM Account
                           WHERE Id IN : relatedAccountIds];
        System.debug('handlesAfterDelete relatedAccountIdsRequery -->'+ relatedAccountIds);

        for (Account account : relatedAccounts) {
           	System.debug('handlesAfterDelete InsideAccForLoop -->');

            //Boolean recordTypeCheck = wrapperHandlesAfter.checkHouseholdNaming(account.RecordTypeId);
            if (checkHouseholdNaming(account.RecordTypeID)) {
                System.debug('handlesAfterDelete InsideRecordTypeCheck -->');
                setAccountIdHHToRename.add(account.Id);
                System.debug('handlesAfterDelete wp.checkHouseholdNaming-->' + setAccountIdHHToRename);
            }
        }
        System.debug('HandlePRocessingBefore DELETE-->');
        handleProcessing(NULL, setAccountIdHHToRename, listContactAccountDelete);
        System.debug('HandlePRocessingAFTER DELETE-->');
    }

     	public boolean checkHouseholdNamingDelete(Id accRecordTypeId) {
            System.debug('checkHouseholdNaming Method -->');
        	if (accRecordTypeId != null
            	&& accRecordTypeId == userDefinedHHRecordTypeId
            	&& UTIL_CustomSettingsFacade.getSettings().Automatic_Household_Naming__c == true) {
                    System.debug('checkHouseholdNaming True -->');
                	return true;
            } else {
                System.debug('checkHouseholdNaming False -->');
                return false;
            }
    	}

    private void handleProcessing(wrapperHandlesAfter wp, Set<Id> setAccountIdHHToRename, List<Contact> listContactAccountDelete) {
        System.debug('handleProcessing wp -->' + wp);

        DmlWrapper dmlWrapper = new DmlWrapper();

        //AfterInsert
        if (triggerAction == TDTM_Runnable.Action.AfterInsert) {

                System.debug('HandleProcessing InsideInsert&Update --->');
                List<Contact> createNewAccountsForContacts = wp.listContactNeedAccount;
				Set<Id> accountIdHHToRename = wp.setAccountIdHHToRenameWP;
				Map<Id,Id> updateAccPrimaryContact = wp.mapAccountIdContactId;
                //Creates new Account
        		if (createNewAccountsForContacts.size() > 0) {
                    System.debug('createNewAccountsForContacts -->' + createNewAccountsForContacts);
            		UTIL_Debug.debug('****Number of Contacts that need Accounts created: ' + createNewAccountsForContacts.size());
            		insertContactAccount(createNewAccountsForContacts, dmlWrapper);
        		}

            	//Updates the Primary COntact Field on Account
            	if (updateAccPrimaryContact.size() > 0) {
            		System.debug('Inside updateAccPrimaryContact -->' + updateAccPrimaryContact);
            		//update Accounts that have newly created Contacts connected to them
            		updateAccountPrimaryContact(updateAccPrimaryContact, dmlWrapper);
            		//we also need to create affiliations for those contacts that have been created as children of existing accounts,
            		//and we have to populate the key affiliation field on those contacts
            		//createAfflsToExistingAccs(mapAccountIdContactId, dmlWrapper);
        		}

            	//Updates HH Account name : KD TO DO - Do I need this in here?
                if (accountIdHHToRename.size() > 0) {
                    System.debug('accountIdHHToRename IF -->' + accountIdHHToRename);
            		UTIL_ACCT_Naming.updateHHAccountsName(accountIdHHToRename);
        		}
            }



        //AfterUpdate
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate ) {

                System.debug('HandleProcessing UpdateONLY --->');
                List<Contact> listContactChangeLastName = wp.listContactsChangedLastName;
                List<Id> accountIdHHToUpdate = wp.listAccountIdHHToUpdate;
                Map<Id,Contact> mapContactOwnerChange = wp.mapContactIdContactOwnerChange;
                Map<Id,Id> mapContactIdAccountIdNewMoveOpp = wp.mapContactIdAccountIdNewMoveOpps;
                Map<Id,Id> mapContactIdAccountIdOldMoveOpp = wp.mapContactIdAccountIdOldMoveOpps;
				Set<Id> accountIdHHToRename = wp.setAccountIdHHToRenameWP;
				Map<Id,Id> updateAccPrimaryContact = wp.mapAccountIdContactId;
				List<Contact> createNewAccountsForContacts = wp.listContactNeedAccount;

            	if (createNewAccountsForContacts.size() > 0) {
                    System.debug('createNewAccountsForContacts -->' + createNewAccountsForContacts);
            		UTIL_Debug.debug('****Number of Contacts that need Accounts created: ' + createNewAccountsForContacts.size());
            		insertContactAccount(createNewAccountsForContacts, dmlWrapper);
        		}

            	//Updates existing Account Primary Contact
				if (accountIdHHToUpdate.size() > 0) {
                    System.debug('accountIdHHToUpdateIF --->');
            		updateParentAcc(accountIdHHToUpdate, dmlWrapper);
        		}

            	if (updateAccPrimaryContact.size() > 0) {
            		System.debug('Inside mapAccountIdContactId -->' + updateAccPrimaryContact);
            		//update Accounts that have newly created Contacts connected to them
            		updateAccountPrimaryContact(updateAccPrimaryContact, dmlWrapper);

        		}

        		//Updates Account Owner to match Contact Owner change
        		if (mapContactOwnerChange.size() > 0) {
                    System.debug('mapContactOwnerChangeIF --->');
            		updateOwners(mapContactOwnerChange, dmlWrapper);
        		}

            	//Updates HH Account name
                if (accountIdHHToRename.size() > 0) {
                    System.debug('accountIdHHToRename IF -->' + accountIdHHToRename);
            		UTIL_ACCT_Naming.updateHHAccountsName(accountIdHHToRename);
        		}
        		//Updates Admin Account Name : KD TO DO
        		if (listContactChangeLastName.size() > 0) {
                    System.debug('listContactChangeLastNameIF --->');
            		dmlWrapper.objectsToUpdate.addAll((List<SObject>)UTIL_ACCT_Naming.updateAdminAccountsName(listContactChangeLastName));
        		}
        		//Inject Adv logic to handle moving opportunity : KD TO DO
        		if (mapContactIdAccountIdNewMoveOpp.size() > 0 && Advancement_Info.useAdv() && Advancement_Info.getApiHEDA() != null) {
                    System.debug('mapContactIdAccountIdNewMoveOppIF --->');
            		Advancement_Info.getApiHEDA().moveOppsToContactAccount(mapContactIdAccountIdNewMoveOpp, mapContactIdAccountIdOldMoveOpp);
        		}
		}

        //AfterDELETE
        //KD: TO DO
        if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            	System.debug('HandleProcessing DELETEONLY --->');

				//Updates Account name
				if (setAccountIdHHToRename.size() > 0) {
            		UTIL_ACCT_Naming.updateHHAccountsName(setAccountIdHHToRename);
        		}

                //Deletes old Account if they are left hanging around
        		if (listContactAccountDelete.size() > 0) {
            		UTIL_Debug.debug('****Number of accs to delete: ' + listContactAccountDelete.size());
            		deleteContactAccountsIfEmpty(listContactAccountDelete, dmlWrapper);
        		}
         }

        TDTM_TriggerHandler.processDML(dmlWrapper, true);

		if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
            System.debug('SettingRecursion==InsertFalse -->');
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert, false);
            //System.debug('BeforeSetting TDTM_ProcessControl AfterInsert --->');
        } else if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            System.debug('SettingRecursion==UpdateFalse -->');
            //System.debug('BeforeSetting TDTM_ProcessControl AfterUpdate --->');
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update, false);
          	//System.debug('BeforeSetting TDTM_ProcessControl AfterUpdate --->');
        } else if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            System.debug('BeforeSetting TDTM_ProcessControl AfterDelete --->');
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Delete, false);
            System.debug('BeforeSetting TDTM_ProcessControl AfterDelete --->');
        }
    }
    /*******************************************************************************************************
	* @description Inserts a new Account for an Individual Contact
	* @param contacts the list of Contacts that need updating.
	* @param dmlWrapper to hold the Contacts that need updating.
	* @return void
	*/
    private void insertContactAccount(Contact[] contacts, DmlWrapper dmlWrapper) {
        List<Id> contactIds = new List<Id>();
        List<Account> accountInserts = new List<Account>();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> listContactNewAcct = new list<Contact>();
        Map<Id,Account> mapContactIdAccount = new Map<Id,Account>();

        System.debug('insertContactAccountMethods --->');

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
            System.debug('insertContactAccountMethods ForLoop --->');
            //If we find an Account already connect to this Contact, connect the Contact to the Account if it is the correct
            //type for the current Account processor.
            Account acc = mapContactIdAccount.get(c.Id);
            System.debug('acc --->' + acc);
            if (acc != NULL && (acc.RecordTypeId == UTIL_CustomSettingsFacade.getSettings().Account_Processor__c)) {
                System.debug('AccountExists --->');
                UTIL_Debug.debug('****Account already existed');
                c.AccountId = acc.Id;
                contactsToUpdate.add(c);
                System.debug('contactsToUpdate --->' + contactsToUpdate);
            } else {
                UTIL_Debug.debug('****Creating new account');
                System.debug('AccountDoesNotExist --->');
                //Constructs the Account
                Account a = new Account(
                    Phone = c.Phone,
                    Fax = c.Fax,
                    OwnerId = c.OwnerId
                );

                //Constructs the Account Name
                if(defaultRecTypeID != null
                   && defaultRecTypeID == userDefinedHHRecordTypeId) {
                       System.debug('userDefinedHHRecordTypeId --->');
                       a.Name = UTIL_ACCT_Naming.strNameHHAccountForContact(new List<Contact>{c});
                       System.debug('userDefinedHHRecordTypeId --->' + a.Name);
                   } else if(defaultRecTypeID != null
                             && defaultRecTypeID == userDefinedAdminRecordTypeId) {
                       	System.debug('userDefinedAdminRecordTypeId --->');
                       	a.Name = UTIL_ACCT_Naming.strNameAdmAccountForContact(c);
                        System.debug('userDefinedAdminRecordTypeId --->' + a.Name);
                   } else {
                       	System.debug('DefaultAccountName --->');
						a.Name = UTIL_ACCT_Naming.strNameAccountForContact(c);
                       	System.debug('DefaultAccountName --->' + a.Name);
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
                System.debug('accountInserts -->' + accountInserts);
                System.debug('listContactNewAcct -->' + listContactNewAcct);
            }
        }
        System.debug('accountInserts -->' + accountInserts);
        System.debug('listContactNewAcct -->' + listContactNewAcct);
        System.debug('OutsideForLoop --->');
        if (accountInserts.size() > 0) {
            UTIL_Debug.debug('****Number of accounts to insert: ' + accountInserts.size());
            // We can't use dmlWrapper because we need to get the new AccountID's into the Contacts.
            // We do want it to be all or nothing, so errors won't get lost.
            System.debug('accountInsertsB4 -->' + accountInserts);
            insert accountInserts;
            System.debug('accountInsertsAfter -->' + accountInserts);
            Integer i = 0;
            System.debug('accountInserts --->' );
            for (Contact c : listContactNewAcct) {
                System.debug('listContactNewAcct -->' + listContactNewAcct);
                // For each success, write the new AccountId to the Contact.
                c.AccountId = accountInserts[i].Id;
                System.debug('conAccountId -->' + c.AccountId);
                contactsToUpdate.add(c);
                i += 1;
                System.debug('contactsToUpdate --->' + contactsToUpdate);
                System.debug('iNumber -->' + i);
            }
        }

        if (contactsToUpdate.size() > 0) {
            System.debug('contactsToUpdate --->' + contactsToUpdate);
            //dmlWrapper.objectsToUpdate.addAll((List<SObject>)contactsToUpdate);
            Database.update(contactsToUpdate);
        }

        //update contactsToUpdate;
    }

    /*******************************************************************************************************
	* @description Updates an Account's naming, primary contact, and rollups
	* @param listAccountId the list of Account (Id's) that need updating.
	* @param dmlWrapper to hold the Accounts that need updating.
	* @return void
	*/
    private void updateParentAcc(List<Id> listAccountId, DmlWrapper dmlWrapper) {
        System.debug('updateParentAccMethod 1st-->');
        resetPrimaryContactForAccount(listAccountId, dmlWrapper);
        System.debug('updateParentAccMethod -->');
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
        System.debug('resetPrimaryContactForAccountMethod -->');


        System.debug('listAccountId Check --->' + listAccountId);
        //listAccountId contains the new AcctId from the Contact
        //Builds a set of primary Contact Ids from the Account given existing AccountIds
        List<Account> listAccount = [SELECT Name, Primary_Contact__c,
                                     (SELECT Id, Name
                                      FROM Contacts
                                      LIMIT 1)
                                     FROM Account
                                     WHERE Id IN :listAccountId];
        //listAccount retrieves the PrimaryCon from the new Account associated to the existing Contact
        System.debug('listAccount -->' + listAccount);

        //Retrieves the Primary_Contact__c from the Account
        for (Account acc : listAccount) {
            System.debug('accPrimaryCon -->' + acc.Primary_Contact__c);
            if (acc.Primary_Contact__c != NULL)
                setPrimaryContactIds.add(acc.Primary_Contact__c);
            System.debug('setPrimaryContactIds -->' + setPrimaryContactIds);
        }
        //SetPrimaryContactId --> is the old outdated PrimaryCon on the Account
        System.debug('setPrimaryContactIds -->' + setPrimaryContactIds);
        if (setPrimaryContactIds.size() > 0) {
            System.debug('setPrimaryContactIds -->' + setPrimaryContactIds);
            for (Account acc : [SELECT Name, Primary_Contact__c,
                                (SELECT Id, Name
                                 FROM Contacts
                                 WHERE Id IN :setPrimaryContactIds
                                 LIMIT 1)
                                FROM Account
                                WHERE Id IN : listAccountId]) {
                                    //There are two cases account primary contact needs reset
                                    //1. An account has no child contact but it used to have primary contact
                                    //2. An account used to have no child contact but a contact was just assigned to it
                                    System.debug('CheckIF -->' + acc.Contacts.size());
                                    System.debug('CheckIF 2 -->' + acc.Primary_Contact__c);
                                    if (acc.Contacts.size() == 0 || acc.Primary_Contact__c == NULL) {
                                        System.debug('InsidetheIFCheck --->');
                                        setAccToResetIds.add(acc.Id);
                                        System.debug('setAccToResetIds -->' + setAccToResetIds);
                                    }
                                }
        } else {
            System.debug('setAccToResetIdsIS0 -->');
            setAccToResetIds.addAll(listAccountId);
            System.debug('setAccToResetIdsIS0 -->' + setAccToResetIds);
        }

        System.debug('setAccToResetIds CHeck -->' + setAccToResetIds);
        //If setAccToResetIds is empty, skip dml and return
        if (setAccToResetIds.size() == 0) {
            System.debug('setAccToResetIdsIS0 -->');
            return;
        }

        //Checks if the newly assigned Acct matches the accId of the Contact.
        //For each account need to be reset
        for (Account acc : listAccount) {
            if (setAccToResetIds.contains(acc.Id)) {
                System.debug('AccountForLoop -->');
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
                System.debug('listAccToUpdate -->' + listAccToUpdate);
            }
        }

        if (listAccToUpdate.size() > 0) {
            System.debug('listAccToUpdate -->' + listAccToUpdate);
        	dmlWrapper.objectsToUpdate.addAll((List<SObject>)listAccToUpdate);
        }
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

    /*******************************************************************************************************
    * @description Contact's owner has changed. Consider updating related account owner.
    * @param mapContactIdContactOwnerChange a map of Contact Id to Contact, for the contacts to consider
    * @param dmlWrapper to hold the Contacts that need updating.
    * @return void
    */
    private void updateOwners(map<Id, Contact> mapContactIdContactOwnerChange, DmlWrapper dmlWrapper) {
        System.debug('updateOwners Method --->');

        if (mapContactIdContactOwnerChange.size() > 0) {
            List<Account> listAccToUpdate = new List<Account>();
            Set<Id> setAccId = new Set<Id>();

            for (Contact con : mapContactIdContactOwnerChange.values()) {
            	setAccId.add(con.AccountId);
            }

            List<Account> listAcc = [SELECT Id, RecordTypeId, Primary_Contact__c, OwnerId,
                                     (SELECT Id FROM Contacts limit 2)
                                     	FROM Account
                						WHERE Id IN :setAccId];

            for (Account acc : listAcc) {
                //TODO: use setting to determine if Account owner should be changed (W-009780)
                if (acc.RecordTypeId != null
                        && (acc.RecordTypeId == userDefinedHHRecordTypeId
                            || acc.RecordTypeId == userDefinedAdminRecordTypeId)) {
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
            System.debug('listAccToUpdate Check -->' + listAccToUpdate);
            if (listAccToUpdate.size() > 0) {
                dmlWrapper.objectsToUpdate.addAll((List<SObject>)listAccToUpdate);
            }
        }
    }

	/*******************************************************************************************************
    * @description Deletes the accounts for contacts that have been deleted if they are empty (no ops, no hh members)
    * @param contacts the list of Contacts that need to be considered
    * @param dmlWrapper to hold the Accounts that need updating.
    * @return void
    */
    public void deleteContactAccountsIfEmpty(Contact[] contacts, DmlWrapper dmlWrapper) {
        List<Id> accountIds = new List<Id>();
        List<Id> listAccountIdUpdate = new list<Id>();
        List<Account> accountsOnContacts = new List<Account>();
        List<SObject> accountsForDeletion = new List<SObject>();

        if (contacts.size() > 0) {
            for (Contact thisContact : contacts) {
                accountIds.add(thisContact.accountId);
            }

            accountsOnContacts = [SELECT Id, Type, RecordTypeId,
                                  (SELECT Id FROM Opportunities limit 1),
                                  (SELECT Id FROM Contacts limit 1)
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
                        listAccountIdUpdate.add(thisAccount.Id);
                    }
                }
            }
        }

        //Delete the accounts
        if (accountsForDeletion.size() > 0) {
			dmlWrapper.objectsToDelete.addAll(accountsForDeletion);
        }

        //Update any HH accounts that just lost a contact
        if (listAccountIdUpdate.size() > 0) {
			updateParentAcc(listAccountIdUpdate, dmlWrapper);
        }
    }
}