/*
    Copyright (c) 2015, Salesforce.org
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
* @date 2015
* @group Affiliations
* @group-content ../../ApexDocContent/Affiliations.htm
* @description Supports changing the record type of an Account.
*/
public class AFFL_AccRecordType_TDTM extends TDTM_Runnable {

	/*******************************************************************************************************
    * @description Updates key affiliation lookups on contact, and any other primary affiliation of the new type.
    * @param listNew the list of Affiliations from trigger new.
    * @param listOld the list of Affiliations from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Affiliations.
    * @return dmlWrapper
    ********************************************************************************************************/
	public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

    	 DmlWrapper dmlWrapper = new DmlWrapper();
    	 //Accounts that did not have a record type before but now they do
    	 Map<ID, String> accsTypeAdded = new Map<ID, String>();
    	 //Accounts whose record type has changed
    	 List<AccNewOldType> accsTypeChanged = new List<AccNewOldType>();

    	 //When a user changes the record type of an Account:
    	 //
    	 //    A. If that account already had a record type and was part of any primary affiliation:
         //         1. the key affl lookup field on Contacts affiliated to it needs to be updated
         //         2. other primary affiliations of the same NEW type need to be changed to not primary
         //
         //    B. If that account did not have a record type:
         //         --> the key affl lookup field for that type in Contacts affiliated to it needs to be populated

    	 if(newlist != null && newlist.size() > 0 && oldlist != null && oldlist.size() > 0) {
    	 	for (Integer i = 0; i < newlist.size(); i++) {
    	 	    SObject so = newlist[i];
    	 	    //AFTER UPDATE
    	 		if(triggerAction == TDTM_Runnable.Action.AfterUpdate) {
	    	 		Account acc = (Account)so;
			        Account oldAcc = (Account)oldList[i];

			        if(acc.RecordTypeId != oldAcc.RecordTypeId) {
			        	AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();

			        	//Find the lookup field that matches the new record type
                        String keyAfflFieldNewType = afflMapper.getKeyAfflFieldByAccRecordType(acc.RecordTypeId);

			        	//Find the lookup field that matches the old record type
				        String keyAfflFieldOldType = afflMapper.getKeyAfflFieldByAccRecordType(oldAcc.RecordTypeId);

				       //Checking if keyAfflFieldOldType is null instead of acc.RecordTypeId because apparently that field
				       //has a value even if the Account is created without populating that field in a test.
				       if(keyAfflFieldOldType != null) {
				        	//Add the account info to the list that tracks accounts that have changed type
				        	accsTypeChanged.add(new AccNewOldType(acc.ID, keyAfflFieldOldType, keyAfflFieldNewType));
			        	} else if (keyAfflFieldNewType != null) {
			        	    accsTypeAdded.put(acc.Id, keyAfflFieldNewType);
			        	}
			        }
    	 		}
		    }

		    updatePrimaryAfflsOnChange(accsTypeChanged, dmlWrapper);
            updatePrimaryAfflsOnAdd(accsTypeAdded, dmlWrapper);
    	 }
    	 return dmlWrapper;
    }

    /*******************************************************************************************************
    * @description Update the primary affiliation fields on Contact when Accounts change record type.
    ********************************************************************************************************/
    private void updatePrimaryAfflsOnChange(List<AccNewOldType> accsTypeChanged, DmlWrapper dmlWrapper) {
        //A.1.a - Find all Contacts that had a value in one of the primary affiliation fields of the type of any of
        //the accounts that have changed.
        List<Contact> childrenAccsTypeChanged;
        if(accsTypeChanged.size() > 0) {
			Set<Id> allChangedIds = new Set<Id>();
			for (AccNewOldType accNewOldType:accsTypeChanged) {
				allChangedIds.add(accNewOldType.accId);
			}
			String childrenAccsTypeChangedQuery = 'select ID from Contact where '
                                                       + accsTypeChanged[0].oldType + ' IN :allChangedIds';
            for(Integer i = 1; i < accsTypeChanged.size(); i++) {
                childrenAccsTypeChangedQuery += ' OR ' + accsTypeChanged[i].oldType + ' IN :allChangedIds';
            }
            childrenAccsTypeChanged = Database.query(childrenAccsTypeChangedQuery);
        }

        //A.1.b - Replace primary affiliation fields in all Contacts that need it.
        if(childrenAccsTypeChanged != null && childrenAccsTypeChanged.size() > 0) {
            List<ID> contactIDs = new List<ID>();
            List<ID> accountIDs = new List<ID>();

            for(Contact contact : childrenAccsTypeChanged) {
                for(AccNewOldType accNewOldType : accsTypeChanged) {
                    if(!containsNew(accsTypeChanged, accNewOldType.oldType)) {
                        contact.put(accNewOldType.oldType, null);
                    }
                    contact.put(accNewOldType.newType, accNewOldType.accId);
                    dmlWrapper.objectsToUpdate.add(contact);

                    //Save the Contact ID and the Account ID of the Affiliation that has been made
                    //primary so we can update all others of the same type for the same Contact and
                    //make them not primary.
                    contactIDs.add(contact.ID);
                    accountIDs.add(accNewOldType.accId);
                }
            }
            //A.2 - Change all affiliations that are not primary any more.
            if(contactIDs.size() > 0 && accountIDs.size() > 0) {
                List<Affiliation__c> afflsMadePrimary = [select Contact__c, Account__c, Affiliation_Type__c
                          from Affiliation__c where Contact__c IN :contactIDs and Account__c IN :accountIDs];
                AFFL_MultiRecordType_TDTM afflMulti = new AFFL_MultiRecordType_TDTM();
                afflMulti.uncheckOtherPrimariesSameType(afflsMadePrimary, dmlWrapper);
            }
        }
    }

    /*******************************************************************************************************
    * @description Update the primary affiliation fields on Contact when record type is added to Accounts.
    ********************************************************************************************************/
    private void updatePrimaryAfflsOnAdd(Map<ID, String> accsTypeAdded, DmlWrapper dmlWrapper) {
        //B - Find all Contacts with an Affiliation to an Account that didn't have a record type before,
        //but that now has it. Update the matching primary affiliation field on Contact.
        if(accsTypeAdded.size() > 0) {
            String childrenAccsTypeAddedQuery = 'select Account__c, Contact__c';
            for(Integer i = 0; i < accsTypeAdded.values().size(); i++) {
                childrenAccsTypeAddedQuery += ', Contact__r.' + accsTypeAdded.values()[i];
            }
            Set<ID> accsTypeAddedIDs = accsTypeAdded.keySet();
            childrenAccsTypeAddedQuery += ' from Affiliation__c where Account__c IN :accsTypeAddedIDs';
            List<Affiliation__c> afflsAccsTypeAdded = Database.query(childrenAccsTypeAddedQuery);

            //Populate the necessary primary field for each Contact
            List<Contact> contactsToUpdate = new List<Contact>();
            for(Affiliation__c affl : afflsAccsTypeAdded) {
                Contact contact = new Contact(ID = affl.Contact__c);
                //Iterate over the Contact primary fields
                for(String primaryField : accsTypeAdded.values()) {
                    contact.put(primaryField, affl.Account__c);
                    contactsToUpdate.add(contact);
                }
            }
            if(contactsToUpdate.size() > 0) {
                dmlWrapper.objectsToUpdate.addAll((List<SObject>)contactsToUpdate);
            }
        }
    }

    /*******************************************************************************************************
    * @description Class used to store an Account ID, its old record type, and its new record type. Used to
    * track those Accounts whose record type has changed.
    ********************************************************************************************************/
    class AccNewOldType {
        ID accId;
        String oldType;
        String newType;

        AccNewOldType(ID accId, String oldType, String newType) {
            this.accId = accId;
            this.oldType = oldType;
            this.newType = newType;
        }
    }


    /*******************************************************************************************************
    * @description Tells the caller if the oldType account record type has become the new type of any of the
    * accounts that have changed record type.
    * @return Boolean
    ********************************************************************************************************/
    Boolean containsNew(List<AccNewOldType> accNewOldType, String oldType) {
        for(AccNewOldType acc : accNewOldType) {
            if(acc.newType == oldType) {
                UTIL_Debug.debug('****Some other Account has been changed to type ' + oldType);
                return true;
            }
        }
        UTIL_Debug.debug('****No other account has been set to record type ' + oldType);
        return false;
    }
}