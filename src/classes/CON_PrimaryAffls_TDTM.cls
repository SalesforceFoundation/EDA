/*
    Copyright (c) 2014, Salesforce.org
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
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Creates Affiliations when the user manually populates
* any of the primary affiliation lookup fields.
*/
public class CON_PrimaryAffls_TDTM extends TDTM_Runnable {

    //Get the primary affiliation fields defined in the Affiliation Mappings
    private static AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();

    /*******************************************************************************************************
    * @description Handles primary affiliation fields.
    * @param listNew the list of Accounts from trigger new.
    * @param listOld the list of Accounts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Accounts
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        DmlWrapper dmlWrapper = new DmlWrapper();

        List<Affiliation__c> afflsToInsert = new List<Affiliation__c>();
        //Map of Contact ID to list of Account IDs that represent key Affl fields that have been cleared or modified.
        //The old Affls need to be made non-primary.
        Map<ID, List<ID>> changedConToAccsMap = new Map<ID, List<ID>>();

        // AFTER INSERT
        if( newlist != null && triggerAction == TDTM_Runnable.Action.AfterInsert  && !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert)) {
            // Loop over contact list
            for (integer i=0; i<newlist.size(); i++) {

                Contact newContact = (Contact)newlist[i];

                //If the Contact has been created with any of the Key Affiliation fields populated
                //  --> Create a matching primary Affiliation for the Contact
                for(Integer j = 0; j < afflMapper.primaryAfflFieldNames.size(); j++) {
                    try {
                        if(newContact.get(afflMapper.primaryAfflFieldNames[j]) != null) {
                            UTIL_Debug.debug('****Contact has been created with one of the Key Affiliation fields populated');
                            createAfflFromLookup(newContact, j, afflsToInsert);
                        }
                    } catch(Exception e) {
                        UTIL_Debug.debug('****Exception message: ' + e.getMessage());
                        UTIL_Debug.debug('****Stack trace: \n' + e.getStackTraceString());
                        newContact.addError(e.getMessage());
                    }
                }
            }
            // Set reentrant Flag
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert, true);
        }

        // BEFORE UPDATE
        if ( newlist != null && triggerAction == TDTM_Runnable.Action.AfterUpdate && !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update)) {
            for (integer i=0; i<newlist.size(); i++) {
                Contact newContact = (Contact)newlist[i];
                Contact oldContact = (Contact)oldlist[i];

                for(Integer j = 0; j < afflMapper.primaryAfflFieldNames.size(); j++) {
                    try {
                        //If any Key Affiliation field has been set
                        //  --> Create a matching primary Affiliation for the Contact
                        //  --> If another Affl to the same Account exists, it should be made not primary. But this is AFFL_MultiRecordType_TDTM's responsibility.
                        if(newContact.get(afflMapper.primaryAfflFieldNames[j]) != null && oldContact.get(afflMapper.primaryAfflFieldNames[j]) == null) {
                           UTIL_Debug.debug('****Key Affiliation field has been set');
                           createAfflFromLookup(newContact, j, afflsToInsert);
                        }

                        //If any Key Affiliation field has been changed to point to another Account
                        //  --> Create new Affiliation (even if another one exists to the same Account - used should have made existing one primary if that
                        //         was his intention)
                        //  --> Make the old Affiliation non-primary. Although this could be AFFL_MultiRecordType_TDTM's responsibility, since the Affl type
                        //        is not yet defined (and the formula will run later), we'll do it here.
                        else if(newContact.get(afflMapper.primaryAfflFieldNames[j]) != null && newContact.get(afflMapper.primaryAfflFieldNames[j])
                        != oldContact.get(afflMapper.primaryAfflFieldNames[j])) {
                            UTIL_Debug.debug('****Key Affiliation field has been changed');
                            createAfflFromLookup(newContact, j, afflsToInsert);
                            populateConToAccsMap(newContact, oldContact, changedConToAccsMap, j);
                        }

                        //If any Key Affiliation field has been cleared
                        //  --> Make the matching Affiliation non-primary
                        else if(newContact.get(afflMapper.primaryAfflFieldNames[j]) == null && oldContact.get(afflMapper.primaryAfflFieldNames[j]) != null) {
                            UTIL_Debug.debug('****Key Affiliation field has been cleared');
                            populateConToAccsMap(newContact, oldContact, changedConToAccsMap, j);
                        }

                    } catch(Exception e) {
                        UTIL_Debug.debug('****Exception message: ' + e.getMessage());
                        UTIL_Debug.debug('****Stack trace: \n' + e.getStackTraceString());
                        newContact.addError(e.getMessage());
                    }
                }
            }

            // Set reentrant Flag
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update, true);
        }

        if(afflsToInsert.size() > 0) {
            UTIL_Debug.debug('****Inserting ' + afflsToInsert.size() + ' affiliations.');
            dmlWrapper.objectsToInsert.addAll((List<SObject>)afflsToInsert);
        }

        if(changedConToAccsMap.size() > 0) {
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)makeOtherAfflsNotPrimary(changedConToAccsMap));
        }

        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        dmlWrapper = null;
        if (triggerAction == TDTM_Runnable.Action.AfterInsert){
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert, false);
            TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated);            
        }else if (triggerAction == TDTM_Runnable.Action.AfterUpdate){
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update, false);
            TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated);            
        }
        return dmlWrapper;
    }

    private void createAfflFromLookup(Contact newContact, Integer j, List<Affiliation__c> afflsToInsert) {
        if(!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary)) {
	        ID accID = (ID)newContact.get(afflMapper.primaryAfflFieldNames[j]);
	        if(accID != null)
	          afflsToInsert.add(new Affiliation__c(Contact__c = newContact.ID, Account__c = accID, Primary__c = true)); //Role and Status?
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated, true);
        }
    }

    private List<Affiliation__c> makeOtherAfflsNotPrimary(Map<ID, List<ID>> changedConToAccsMap) {
        //Find all the affiliations to make non-primary.
        List<Affiliation__c> afflsToMakeNonPrimary = new List<Affiliation__c>();
        //Initially we get all possible affiliations from those contacts.
        List<Affiliation__c> afflsAll = [select Contact__c, Account__c, Primary__c from Affiliation__c where Contact__c in :changedConToAccsMap.keySet()];
        UTIL_Debug.debug('****All possible affls to make non-primary: ' + JSON.serializePretty(afflsAll));
        //Then we refine the search - changedConToAccsMap should contain only the Acc IDs of those key Affl lookups that have been modified.
        for(Affiliation__c affl : afflsAll) {
            List<ID> contactAccIDs = changedConToAccsMap.get(affl.Contact__c);
            for(ID changedAccID : contactAccIDs) {
                if(affl.Account__c == changedAccID) {
                    affl.Primary__c = false;
                    UTIL_Debug.debug('****Making affl ' + affl.ID + ' non-primary.');
                    afflsToMakeNonPrimary.add(affl);
                }
            }
        }
        return afflsToMakeNonPrimary;
    }

    private static void populateConToAccsMap(Contact newContact, Contact oldContact, Map<ID, List<ID>> changedConToAccsMap, Integer j) {
        List<ID> accIDs = changedConToAccsMap.get(newContact.ID);
        if(accIDs == null) {
            accIDs = new List<ID>();
        }
        accIDs.add((ID)oldContact.get(afflMapper.primaryAfflFieldNames[j]));
        UTIL_Debug.debug('****Adding contact ' + newContact.ID + ' and list of accs to map: ' + JSON.serializePretty(accIDs));
        changedConToAccsMap.put(newContact.ID, accIDs);
    }
}