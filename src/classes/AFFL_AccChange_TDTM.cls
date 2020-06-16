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
* @description Updates the the Primary Affiliation Fields on the related Contact in the following way
* 1) When Account on a Primary Affiliation is changed to a new Account of Same record type, then updates the Primary Affiliaiton field on the related Contact with the new Account
* 2.1) When Account on a Primary Affiliation is changed to a new Account of a different record type, then removes the value from the old Primary Affiliation field on the contact
* and updates the Primary affiliation field related to the new Account Record type on the Contact
* 2.2) When Account on a Primary Affiliation is changed to a an Account which is a part of Primary Affiliation on the same Contact, it throws an error
* 3) When Account in a Primary Affiliation is removed, it clears the Primary Affiliation field's value in the related contact
*/
public with sharing class AFFL_AccChange_TDTM extends TDTM_Runnable {

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
        if(!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_AccChange_TDTM)) {

            AFFL_MultiRecordType_TDTM afflMulti = new AFFL_MultiRecordType_TDTM();
            Map<ID, Contact> relatedContactsMap;

            if(newlist != null && newlist.size() > 0) {

                // Perform query outside loop for later user in AfterUpdate
                if(triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                    //Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
                    relatedContactsMap = afflMulti.queryAfflLookupFields(newlist);
                }

                Integer i = 0;
                List<Affiliation__c> afflsMadePrimary = new List<Affiliation__c>();
                Map<Id, List<Affiliation__c>> IdToOtherAffiliatonsWithSameAccAndCon = createdIdToOtherPrimaryAfflsWithSameAccAndCon(newlist);

                for (SObject so : newlist) {
               		Affiliation__c affl = (Affiliation__c)so;
               		String lookupLabelOrAPIName = AFFL_MultiRecordType_TDTM.afflMapper.accRecTypeToContactLabel.get(affl.Affiliation_Type__c);
                  if (lookupLabelOrAPIName == NULL) {
                      String affiliationTypeAPI = afflMapper.accRecTypeLabelToAPI.get(affl.Affiliation_Type__c);
                      lookupLabelOrAPIName = afflMapper.accRecTypeToContactLabel.get(affiliationTypeAPI);
                  }
           			  String lookupFieldAPIName = AFFL_MultiRecordType_TDTM.afflMapper.contactLabelNames.get(lookupLabelOrAPIName);

               		Affiliation__c afflOld;
               		String lookupFieldLabelOrAPIOld;
                    String lookupFieldAPINameOld;
               		if(oldlist[i] != null) {
                   		afflOld = (Affiliation__c)oldlist[i];
                   		lookupFieldLabelOrAPIOld = AFFL_MultiRecordType_TDTM.afflMapper.accRecTypeToContactLabel.get(afflOld.Affiliation_Type__c);
                        if (lookupFieldLabelOrAPIOld == NULL) {
                            String affiliationTypeAPI = afflMapper.accRecTypeLabelToAPI.get(afflOld.Affiliation_Type__c);
                            lookupFieldLabelOrAPIOld = afflMapper.accRecTypeToContactLabel.get(affiliationTypeAPI);
                        }
                   		lookupFieldAPINameOld = AFFL_MultiRecordType_TDTM.afflMapper.contactLabelNames.get(lookupFieldLabelOrAPIOld);
               		}

               		if (isAfflTypeEnforced == true) {
                       ERR_ExceptionHandler.handleAfflNullRecordTypeException(affl, afflMapper.validAccRecordTypesInMappings);
               		}

               		//AFTER UPDATE
               		if(triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                   		Contact relatedContact;
                   		relatedContact = relatedContactsMap.get(affl.Contact__c);

                   		//ACCOUNT FIELD CHANGED
                   		if (affl.Primary__c && affl.Account__c != null && afflOld.Account__c != null
                       		&& affl.Account__c != afflOld.Account__c && lookupFieldAPIName != null) {

                       		if(affl.Affiliation_Type__c == afflOld.Affiliation_Type__c) {
                           		//If the primary affl now points to an Account of the same type, update the
                           		//same primary field in Contact.
                           		relatedContact.put(lookupFieldAPIName, affl.Account__c);
                       		} else {
                           		//If the primary affl now points to an Account of different type, clear the old
                           		//primary field in Contact and populate the matching new field. Uncheck any other
                                //priamry affilations of same type.

                                // check if there are any other Primary affiliations with same account and show an error
                                if (IdToOtherAffiliatonsWithSameAccAndCon.size() > 0 && IdToOtherAffiliatonsWithSameAccAndCon.get(affl.ID).size() > 0) {
                                    affl.addError(Label.affiilaitonWithSameAccountExists);
                                }
                                
                           		if (lookupFieldAPINameOld != null) {
                                       relatedContact.put(lookupFieldAPINameOld, null);
                                    if (relatedContact.get(lookupFieldAPIName) != affl.Account__c) {
                               		    relatedContact.put(lookupFieldAPIName, affl.Account__c);
                                    }
                                    afflsMadePrimary.add(affl);
                           		}
                       		}
                       		dmlWrapper.objectsToUpdate.add(relatedContact);

                       	}
                        
                        //ACCOUNT FIELD CLEARED - the matching primary field in Contact needs to be cleared.
                       	if(affl.Primary__c && afflOld.Account__c != null && affl.Account__c == null && lookupFieldAPINameOld != null) {
                           	relatedContact.put(lookupFieldAPINameOld, null);
                           	dmlWrapper.objectsToUpdate.add(relatedContact);
                       	}
                       	TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_AccChange_TDTM, true);
                   	}
                   	i++;
                    //Turn off CON_PrimaryAffls_TDTM_After_Update temporarily to avoid creating duplicate affiliation
                    TDTM_ProcessControl.turnOffRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update);

               	}
                if (afflsMadePrimary.size() > 0) {
                    afflMulti.uncheckOtherPrimariesSameType(afflsMadePrimary, dmlWrapper);
                }
           	}
        }

        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        dmlWrapper = null;  
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {      
          	TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_AccChange_TDTM, false);
            TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update);
        }
        return dmlWrapper;
    }

    @testVisible
    private Map<Id, List<Affiliation__c>> createdIdToOtherPrimaryAfflsWithSameAccAndCon(List<Affiliation__c> newAffiliationList) {

        Set<ID> newPrimaryAffls = new Set<ID>();
        Set<ID> afflContactIDs = new Set<ID>();
        Set<String> afflAccIds = new Set<String>();
        List<Affiliation__c> oldPrimaryAffls = new List<Affiliation__c>();

        for (Affiliation__c affl : newAffiliationList) {
            newPrimaryAffls.add(affl.ID);
            afflContactIDs.add(affl.Contact__c);
            afflAccIds.add(affl.Account__c);
        }
        
        //Get all possible Primary Affiliation with Same Contact and Account
        List<Affiliation__c> otherPrimaryAffls = [SELECT Id, Contact__c, Account__c, Affiliation_Type__c, Primary__c
                                                  FROM Affiliation__c WHERE Account__c IN :afflAccIds and Contact__c IN :afflContactIDs
                                                  AND Primary__c = TRUE AND Id NOT IN :newPrimaryAffls];
        
        Map<Id, List<Affiliation__c>> idToOtherAffiliationWithSameAccAndCon = new Map<Id, List<Affiliation__c>>();

        // Organize the results in a map
        for (Affiliation__c otherPrimaryAffl : otherPrimaryAffls) {
            //Any pre-existing Affl with the same Contact and the Account as any new Affl should be added to idToOtherAffiliationWithSameAccAndCon map
            for (Affiliation__c newAffl : newAffiliationList) {
                if (otherPrimaryAffl.Contact__c == newAffl.Contact__c && otherPrimaryAffl.Account__c == newAffl.Account__c) {
                    if(idToOtherAffiliationWithSameAccAndCon.containsKey(newAffl.Id)) {
                        idToOtherAffiliationWithSameAccAndCon.get(newAffl.Id).add(otherPrimaryAffl);
                   }else {
                        idToOtherAffiliationWithSameAccAndCon.put(newAffl.Id, new List<Affiliation__c>{otherPrimaryAffl});
                   }
                }
            }
        }
        
        return idToOtherAffiliationWithSameAccAndCon;
    }
}