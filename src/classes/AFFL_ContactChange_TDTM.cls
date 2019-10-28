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
* @group Affiliations
* @group-content ../../ApexDocContent/Affiliations.htm
* @description Handles the Contact in a primary Affiliation being changed or cleared.
*/
public with sharing class AFFL_ContactChange_TDTM extends TDTM_Runnable {

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

        if (!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_ContactChange_TDTM)) {

            AFFL_MultiRecordType_TDTM afflMulti = new AFFL_MultiRecordType_TDTM();
            Map<ID, Contact> newRelatedContactsMap, oldRelatedContactsMap;

            if (newlist != null && newlist.size() > 0) {
                Integer i = 0;

                // Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
                if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                    if (newlist != null) {
                        newRelatedContactsMap = afflMulti.queryAfflLookupFields(newlist);
                    }
                    if (oldlist != null) {
                       oldRelatedContactsMap = afflMulti.queryAfflLookupFields(oldlist);
                    }
                }

	            for (SObject so : newlist) {
                    Affiliation__c affl = (Affiliation__c)so;
                    Affiliation__c afflOld;
               		if(oldlist[i] != null)
                   		afflOld = (Affiliation__c)oldlist[i];

	               	String lookupFieldLabel = AFFL_MultiRecordType_TDTM.afflMapper.AccRecTypeToContactLabel.get(affl.Affiliation_Type__c);
	               	String lookupFieldName = AFFL_MultiRecordType_TDTM.afflMapper.contactLabelNames.get(lookupFieldLabel);

					if (isAfflTypeEnforced == true) {
						ERR_ExceptionHandler.handleAfflNullRecordTypeException(affl, afflMapper.validAccRecordTypesInMappings);
					}

	               	//AFTER UPDATE
	               	if(triggerAction == TDTM_Runnable.Action.AfterUpdate) {

    		           	Contact newRelatedContact, oldRelatedContact;
		               	if(newlist != null) {
		                  	newRelatedContact = newRelatedContactsMap.get(affl.Contact__c);
		               	}
		               	if(oldlist != null) {
		                  	oldRelatedContact = oldRelatedContactsMap.get(afflOld.Contact__c);
		               	}

	                   	//CONTACT FIELD CHANGED
	                   	if(affl.Primary__c && affl.Contact__c != null && afflOld.Contact__c != null
	                   		&& affl.Contact__c != afflOld.Contact__c && newRelatedContact != null && oldRelatedContact != null && lookupFieldName != null) {

	                       	//Clear matching primary affiliation field in old Contact
	                       	oldRelatedContact.put(lookupFieldName, null);
	                       	dmlWrapper.objectsToUpdate.add(oldRelatedContact);

	                       	//Populate same field in new Contact
	                       	newRelatedContact.put(lookupFieldName, affl.Account__c);
                            dmlWrapper.objectsToUpdate.add(newRelatedContact);

	                       	//afflMulti.uncheckOtherPrimariesSameType(); --> we don't need to call this because
                           	//AFFL_MultiRecordType_TDTM will run after this class, and will take care of that.
	                   	}

	                   	//CONTACT FIELD CLEARED - same as if the Affiliation was deleted.
	                   	if(affl.Primary__c && afflOld.Contact__c != null && affl.Contact__c == null && lookupFieldName != null) {
	                       	afflMulti.processAfflDeleted(afflOld, oldRelatedContact, lookupFieldName, dmlWrapper);
	                   	}
	               	}
	               	i++;
                    //Turn off CON_PrimaryAffls_TDTM_After_Update temporarily to avoid creating duplicate affiliation
                    TDTM_ProcessControl.turnOffRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update);
	           	}
	       	}
           	TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_ContactChange_TDTM, true);
        }
        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        dmlWrapper = null;        
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_ContactChange_TDTM, false);
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate){
            TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update);
        }
        return dmlWrapper;
    }
}