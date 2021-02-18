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
        if (!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_AccChange_TDTM)) {

            AFFL_MultiRecordType_TDTM afflMulti = new AFFL_MultiRecordType_TDTM();
            Map<ID, Contact> relatedContactsMap;

            if (newlist != null && newlist.size() > 0) {

                // Perform query outside loop for later user in AfterUpdate
                if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                    // Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
                    relatedContactsMap = afflMulti.queryAfflLookupFields(newlist);
                }

                Integer i = 0;
                List<Affiliation__c> afflsMadePrimaryList = new List<Affiliation__c>();
                Map<Id, List<Affiliation__c>> idToOtherAffiliatonsWithSameAccAndCon = createdIdToOtherPrimaryAfflsWithSameAccAndCon(newlist);

                for (SObject so : newlist) {
                    
                    Affiliation__c affl = (Affiliation__c)so;
                    // Get the Primary Affiliation lookup's API name for this affiliation type
                    String lookupFieldAPIName = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType(affl.Affiliation_Type__c);

                    Affiliation__c afflOld;
                    String lookupFieldAPINameOld;

                    if (oldlist[i] != null) {
                        afflOld = (Affiliation__c)oldlist[i];
                        lookupFieldAPINameOld = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType(afflOld.Affiliation_Type__c);
                    }

                    if (isAfflTypeEnforced == true) {
                        ERR_ExceptionHandler.handleAfflNullRecordTypeException(affl, afflMapper.validAccRecordTypesInMappings);
                    }

                    // AFTER UPDATE
                    if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                        Contact relatedContact;
                        relatedContact = relatedContactsMap.get(affl.Contact__c);

                        // ACCOUNT FIELD CHANGED
                        if (affl.Primary__c && affl.Account__c != null && afflOld.Account__c != null
                            && affl.Account__c != afflOld.Account__c && lookupFieldAPIName != null) {

                            if (affl.Affiliation_Type__c == afflOld.Affiliation_Type__c) {
                                //If the primary affl now points to an Account of the same type, update the
                                //same primary field in Contact.
                                relatedContact.put(lookupFieldAPIName, affl.Account__c);
                            } else {
                                //If the primary affl now points to an Account of different type, clear the old
                                //primary field in Contact and populate the matching new field. Uncheck any other
                                //primary affilations of same type.

                                // check if there are any other Primary affiliations with same account and show an error
                                if (idToOtherAffiliatonsWithSameAccAndCon.get(affl.ID) != null &&
                                    idToOtherAffiliatonsWithSameAccAndCon.get(affl.ID).isEmpty() == false) {
                                    affl.addError(Label.affiliationWithSameAccExists);
                                }
                                
                                if (lookupFieldAPINameOld != null) {
                                    relatedContact.put(lookupFieldAPINameOld, null);

                                    if (relatedContact.get(lookupFieldAPIName) != affl.Account__c) {
                                        relatedContact.put(lookupFieldAPIName, affl.Account__c);
                                    }
                                    afflsMadePrimaryList.add(affl);
                                }
                            }
                            dmlWrapper.objectsToUpdate.add(relatedContact);

                        }
                        
                        // ACCOUNT FIELD CLEARED - the matching primary field in Contact needs to be cleared.
                        if (affl.Primary__c && afflOld.Account__c != null && affl.Account__c == null && lookupFieldAPINameOld != null) {
                            relatedContact.put(lookupFieldAPINameOld, null);
                            dmlWrapper.objectsToUpdate.add(relatedContact);
                        }

                        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_AccChange_TDTM, true);
                    }
                    i++;
                    // Turn off CON_PrimaryAffls_TDTM_After_Update temporarily to avoid creating duplicate affiliation
                    TDTM_ProcessControl.turnOffRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update);

                }

                if (afflsMadePrimaryList.isEmpty() == false) {
                    afflMulti.uncheckOtherPrimariesSameType(afflsMadePrimaryList, dmlWrapper);
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
   
    /******************************************************************************************************************************
    * @description Creates a map Affiliation Id to other Primary Affilaitons with same Account and Contact
    * @param newAffiliationList List of affiliations that are being updated
    * @return idToOtherAffiliationWithSameAccAndCon A map Affiliation Id to other Primary Affilaitons with same Account and Contact
    ********************************************************************************************************************************/
    @testVisible
    private Map<Id, List<Affiliation__c>> createdIdToOtherPrimaryAfflsWithSameAccAndCon(List<Affiliation__c> newAffiliationList) {

        Set<ID> newPrimaryAfflSet = new Set<ID>();
        Set<ID> afflContactIdSet = new Set<ID>();
        Set<String> afflAccIdSet = new Set<String>();

        for (Affiliation__c affl : newAffiliationList) {
            newPrimaryAfflSet.add(affl.ID);
            afflContactIdSet.add(affl.Contact__c);
            afflAccIdSet.add(affl.Account__c);
        }
        
        Map<String, List<Affiliation__c>> idToOtherPrimaryAfflList = new Map<String, List<Affiliation__c>>();
        
        // Get all possible Primary Affiliation with Same Contact and Account
        for (Affiliation__c affiliation : [SELECT Id, Contact__c, Account__c, Affiliation_Type__c, Primary__c
                                            FROM Affiliation__c WHERE Account__c IN :afflAccIdSet 
                                            AND Contact__c IN :afflContactIdSet
                                            AND Primary__c = TRUE 
                                            AND Id NOT IN :newPrimaryAfflSet]) {
            string accIdConId = (String)affiliation.Account__c + (String)affiliation.Contact__c;                              
            if (idToOtherPrimaryAfflList.containsKey(accIdConId)) {
                idToOtherPrimaryAfflList.get(accIdConId).add(affiliation);
            } else {
                idToOtherPrimaryAfflList.put(accIdConId, new List<Affiliation__c>{affiliation});
            }
        }

        Map<Id, List<Affiliation__c>> idToOtherAffiliationWithSameAccAndCon = new Map<Id, List<Affiliation__c>>();

        if (idToOtherPrimaryAfflList.isEmpty()) {
            return idToOtherAffiliationWithSameAccAndCon;
        }
        
        for (Affiliation__c affiliation: newAffiliationList) {
            string accIdConId = (String)affiliation.Account__c + (String)affiliation.Contact__c;
            if (idToOtherPrimaryAfflList.get(accIdConId) != null && idToOtherPrimaryAfflList.get(accIdConId).isEmpty() == false) {
                idToOtherAffiliationWithSameAccAndCon.put(affiliation.Id, idToOtherPrimaryAfflList.get(accIdConId));                
            }
        }

        return idToOtherAffiliationWithSameAccAndCon;
    }
}