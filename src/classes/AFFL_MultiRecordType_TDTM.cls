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
* @description Handles Affiliations of different record types, with one primary per type.
*/
public class AFFL_MultiRecordType_TDTM extends TDTM_Runnable {

	//Get the primary affiliation fields defined in the Affiliation Mappings
	public static AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();

	/*******************************************************************************************************
    * @description If affiliation type is enforced.
    */
	private static boolean isAfflTypeEnforced = UTIL_CustomSettingsFacade.getSettings().Affiliation_Record_Type_Enforced__c;

	/*******************************************************************************************************
    * @description Handles Affiliation management.
    * @param listNew the list of Accounts from trigger new.
    * @param listOld the list of Accounts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Accounts
    * @return dmlWrapper.
    ********************************************************************************************************/
	public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
			TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

		DmlWrapper dmlWrapper = new DmlWrapper();
		List<Affiliation__c> afflsMadePrimary = new List<Affiliation__c>();
		if(!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert)
				|| !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Update)
				|| !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Insert)) {

			//Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
			Map<ID, Contact> relatedContactsMap;
			if(newlist != null) {
				relatedContactsMap = queryAfflLookupFields(newlist);
			} else if(oldlist != null) {
				relatedContactsMap = queryAfflLookupFields(oldlist);
			}

			if(newlist != null && newlist.size() > 0) {
				Integer i = 0;
				for (SObject so : newlist) {
					Affiliation__c affl = (Affiliation__c)so;

					String lookupLabelOrAPIName = afflMapper.AccRecTypeToContactLabel.get(affl.Affiliation_Type__c);
					String lookupFieldName = afflMapper.contactLabelNames.get(lookupLabelOrAPIName);
          
					// If lookupFieldName of the Contact is not found, check if lookupLabelOrAPIName is an API, if yes assign it to lookupFieldName
					// such that the API name can be used to populate primay Affiliation lookup is populated on contact even when language is not English
						
      if ((lookupLabelOrAPIName != NULL && lookupLabelOrAPIName != '') && (lookupFieldName == '' || lookupFieldName == NULL)) {
          List<String> contactFieldAPINamesList = afflMapper.contactLabelNames.values();                     
          if (contactFieldAPINamesList.contains(lookupLabelOrAPIName)) {
             lookupFieldName = lookupLabelOrAPIName;                            
          }                        
      }

					if (isAfflTypeEnforced == true) {
						ERR_ExceptionHandler.handleAfflNullRecordTypeException(affl, afflMapper.validAccRecordTypesInMappings);
					}

					Contact relatedContact = relatedContactsMap.get(affl.Contact__c);

					//BEFORE INSERT - we do it in the Before so we don't get the affiliation we just created when we query for
					//affls of the same type.
					if (triggerAction == TDTM_Runnable.Action.BeforeInsert && !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert)) {
						if (affl.Primary__c && affl.Contact__c != null && affl.Account__c != null && affl.Affiliation_Type__c != null && lookupFieldName != null) {
							afflsMadePrimary.add(affl);
							TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, true);
							populateKeyAffls(affl, lookupFieldName, relatedContact, dmlWrapper);
						}
					}

					// AFTER UPDATE
					if (triggerAction == TDTM_Runnable.Action.AfterUpdate && !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Update)) {
						Affiliation__c afflOld = (Affiliation__c)oldlist[i];

						//If a primary affiliation is made nonprimary the key affiliation field on the contact needs to be cleared.
						if (afflOld.Primary__c
								&& !affl.Primary__c
								&& lookupFieldName != null
								&& relatedContact.get(lookupFieldName) == affl.Account__c) {
							UTIL_Debug.debug('****AFFL_MultiRecordType_TDTM - clearing field ' + lookupFieldName);
							if(!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated)) {
								relatedContact.put(lookupFieldName, null);
								dmlWrapper.objectsToUpdate.add(relatedContact);
							}
						}

						//If a non-primary affiliation is made primary the key affiliation field on the contact needs to be filled,
						//an any other primary affiliation of the same type needs to be made non-primary.
						if (affl.Primary__c && !afflOld.Primary__c && affl.Contact__c != null && affl.Account__c != null && lookupFieldName != null) {
							afflsMadePrimary.add(affl);
							TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, true);
							populateKeyAffls(affl, lookupFieldName, relatedContact, dmlWrapper);
						}
					}
					i++;
				}
				if (triggerAction == TDTM_Runnable.Action.BeforeInsert)
				{
					TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert, true);
				}else if (triggerAction == TDTM_Runnable.Action.AfterUpdate)
				{
					TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Update, true);

				}
				if(afflsMadePrimary.size() > 0) {
					uncheckOtherPrimariesSameType(afflsMadePrimary, dmlWrapper);
				}
			}

			if(oldlist != null && oldlist.size() > 0) {
				for(SObject so : oldlist) {
					Affiliation__c afflOld = (Affiliation__c)so;
					String lookupFieldLabel = afflMapper.AccRecTypeToContactLabel.get(afflOld.Affiliation_Type__c);
					String lookupFieldName = afflMapper.contactLabelNames.get(lookupFieldLabel);

					Contact relatedContact = relatedContactsMap.get(afflOld.Contact__c);

					//AFTER DELETE - delete lookup relationship, if necessary
					if (triggerAction == TDTM_Runnable.Action.AfterDelete && lookupFieldName != null ) {
						processAfflDeleted(afflOld, relatedContact, lookupFieldName, dmlWrapper);
					}
				}
			}
		}

		//AFTER INSERT
		if(!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Insert) && triggerAction == TDTM_Runnable.Action.AfterInsert) {
			if(newlist != null && newlist.size() > 0) {
				for (SObject so : newlist) {
					Affiliation__c affl = (Affiliation__c)so;
					createProgramEnrollmentIfNecessary(affl, dmlWrapper);
				}
			}
			TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Insert, true);
		}
		TDTM_TriggerHandler.processDML(dmlWrapper, true);
		dmlWrapper = null;
		if (triggerAction == TDTM_Runnable.Action.AfterInsert){
			TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Insert, false);
		}else if (triggerAction == TDTM_Runnable.Action.BeforeInsert){
			TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert, false);
			TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary);
		}else if (triggerAction == TDTM_Runnable.Action.AfterUpdate){
			TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Update, false);
			TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary);
		}

		return dmlWrapper;
	}

	public void processAfflDeleted(Affiliation__c afflOld, Contact relatedContact, String lookupFieldName, DmlWrapper dmlWrapper) {
		//If the affl is primary, and the lookup field of this type is pointing to the account that is part of the affl ==> clear the lookup
		if(afflOld.Primary__c && lookupFieldName != null && relatedContact != null && relatedContact.get(lookupFieldName) == afflOld.Account__c) {
			if(!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated)) {
				relatedContact.put(lookupFieldName, null);
				dmlWrapper.objectsToUpdate.add(relatedContact);
			}
		}
	}

	public Map<ID, Contact> queryAfflLookupFields(List<SObject> afflsList) {
		//Query the primary affiliation fields for all contacts at once
		String contactIDs = '(';
		Map<ID, Contact> relatedContactsMap = new Map<ID, Contact>();
		if(afflsList != null && afflsList.size() > 0) {
			Affiliation__c firstAffl = (Affiliation__c)afflsList[0];
			if(firstAffl.Contact__c != null)
				contactIDs += '\'' + firstAffl.Contact__c + '\'';
			Integer i = 1;
			while(i < afflsList.size()) {
				Affiliation__c affl = (Affiliation__c)afflsList[i];
				if(affl.Contact__c != null)
					contactIDs += ', \'' + affl.Contact__c + '\'';
				i++;
			}
			contactIDs += ')';

			//Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
			String dynamicQuery = 'select ID';
			for(String primaryField : afflMapper.primaryAfflFieldNames) {
				dynamicQuery = dynamicQuery + ', ' + primaryField;
			}
			dynamicQuery += ' from Contact where ID IN '+ contactIDs;
			UTIL_Debug.debug('****MRT: Dynamic query: ' + dynamicQuery);
			if(contactIDs != '()') {
				List<Contact> relatedContactsList = Database.query(dynamicQuery);
				for(Contact contact : relatedContactsList) {
					relatedContactsMap.put(contact.ID, contact);
				}
			}
		}
		return relatedContactsMap;
	}

	private void populateKeyAffls(Affiliation__c affl, String lookupFieldName, Contact relatedContact, DmlWrapper dmlWrapper) {
		//If the reason why Affiliations have been made primary is that key affiliation fields on Contact have been populated,
		//we don't need to try populating them. In fact, this causes an error notification to be sent (W-009272).
		if(!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated)) {
			//If we have a mapping, populate the lookup field defined in the mapping.
			if(!String.isBlank(lookupFieldName)) {
				UTIL_Debug.debug('****MRT: populating lookup field ' + lookupFieldName + ' on contact');
				relatedContact.put(lookupFieldName, affl.Account__c);
				dmlWrapper.objectsToUpdate.add(relatedContact);
			}
		}
	}

	public void uncheckOtherPrimariesSameType(List<Affiliation__c> affls, DmlWrapper dmlWrapper) {
		Set<ID> newPrimaryAffls = new Set<ID>();
		Set<ID> afflContactIDs = new Set<ID>();
		Set<String> afflTypes = new Set<String>();
		List<Affiliation__c> oldPrimaryAffls = new List<Affiliation__c>();

		for(Affiliation__c affl : affls) {
			newPrimaryAffls.add(affl.ID);
			afflContactIDs.add(affl.Contact__c);
			afflTypes.add(affl.Affiliation_Type__c);
		}

		//Get all possible matches
		List<Affiliation__c> otherPrimaryAffls = [select ID, Contact__c, Account__c, Affiliation_Type__c, Primary__c
		from Affiliation__c where Affiliation_Type__c in :afflTypes and Contact__c in :afflContactIDs
		and Primary__c = true and ID not in :newPrimaryAffls];
		//Refine the result
		for(Affiliation__c otherPrimaryAffl : otherPrimaryAffls) {
			//Any pre-existing Affl with the same Contact and the same Type as any new Affl should be added to oldPrimaryAffls
			for(Affiliation__c newAffl : affls) {
				if(otherPrimaryAffl.Contact__c == newAffl.Contact__c && otherPrimaryAffl.Affiliation_Type__c == newAffl.Affiliation_Type__c) {
					oldPrimaryAffls.add(otherPrimaryAffl);
					break;
				}
			}
		}

		//If the newly created affiliation is the primary, uncheck other primary affiliations of the same type.
		for(Affiliation__c otherAffl : oldPrimaryAffls) {
			otherAffl.Primary__c = false;
		}
		dmlWrapper.objectsToUpdate.addAll((List<SObject>)oldPrimaryAffls);
	}

	private void createProgramEnrollmentIfNecessary(Affiliation__c affl, DmlWrapper dmlWrapper) {
		if(affl != null && affl.Affiliation_Type__c != null) {
			Boolean needsProgramEnrollment = afflMapper.needsProgramEnrollment(affl);
			UTIL_Debug.debug('****needsProgramEnrollment: ' + needsProgramEnrollment);
			if(needsProgramEnrollment != null && needsProgramEnrollment) {
				Program_Enrollment__c enroll = new Program_Enrollment__c(Affiliation__c = affl.ID, Contact__c = affl.Contact__c, Account__c = affl.Account__c);
				dmlWrapper.objectsToInsert.add(enroll);
			}
		}
	}
}