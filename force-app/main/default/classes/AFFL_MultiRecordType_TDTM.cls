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
 * Before Insert - When a Primary affilaiton is inserted with a contact and Account, it updates the Primary affilaiton field on related Contact and unchecks other
 * Primary affilaitons on the Contact of same type
 * After Update - 1) If a primary affiliation is made non-primary, the Primary affiliation field on the contact will be cleared.
 * 2) If a non-primary affiliation is made primary the key affiliation field on the contact will to be filled,
 * and any other primary affiliation of the same type will be made non-primary.
 * After Insert - Creates Program enrollments if necessary
 * After Delete - If a Primary Affiliation is deleted then it clears its corresponding field's value on the Contact
 */
public class AFFL_MultiRecordType_TDTM extends TDTM_Runnable {
    //Trigger-specific recursion flags
    static final TDTM_ProcessControl.registeredTrigger BEFORE_INSERT_RECURSION = TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert;
    static final TDTM_ProcessControl.registeredTrigger AFTER_INSERT_RECURSION = TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Insert;
    static final TDTM_ProcessControl.registeredTrigger AFTER_UPDATE_RECURSION = TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Update;

    //Special recursion flags
    static final TDTM_ProcessControl.registeredTrigger AFFILIATION_MADE_PRIMARY_RECURSION = TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary;

    //Cross-trigger recursion flags. Potential antipattern.
    //NOTE: Evaluate if we can improve this
    static final TDTM_ProcessControl.registeredTrigger CONTACT_PRIMARY_AFFILIATION_UPDATED_RECURSION = TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated;

    //Get the primary affiliation fields defined in the Affiliation Mappings
    public static AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();

    /*******************************************************************************************************
     * @description If affiliation type is enforced.
     */
    private static boolean isAfflTypeEnforced = UTIL_CustomSettingsFacade.getSettings()
        .Affiliation_Record_Type_Enforced__c;

    /*******************************************************************************************************
     * @description Handles Affiliation management.
     * @param listNew the list of Accounts from trigger new.
     * @param listOld the list of Accounts from trigger old.
     * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
     * @param objResult the describe for Accounts
     * @return dmlWrapper.
     ********************************************************************************************************/
    public override DmlWrapper run(
        List<SObject> newlist,
        List<SObject> oldlist,
        TDTM_Runnable.Action triggerAction,
        Schema.DescribeSObjectResult objResult
    ) {
        DmlWrapper dmlWrapper = new DmlWrapper();
        List<Affiliation__c> afflsMadePrimary = new List<Affiliation__c>();
        if (
            this.isBeforeInsertRecursion() == false ||
            this.isAfterUpdateRecursion() == false ||
            this.isAfterInsertRecursion() == false
        ) {
            //Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
            Map<ID, Contact> relatedContactsMap;
            if (newlist != null) {
                relatedContactsMap = this.queryAfflLookupFields(newlist);
            } else if (oldlist != null) {
                relatedContactsMap = this.queryAfflLookupFields(oldlist);
            }

            if (newlist != null && newlist.size() > 0) {
                Integer i = 0;
                for (SObject so : newlist) {
                    Affiliation__c affl = (Affiliation__c) so;
                    // Get the Primary Affiliation lookup's API name for this affiliation type
                    String lookupFieldAPIName = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType(
                        affl.Affiliation_Type__c
                    );

                    if (isAfflTypeEnforced == true) {
                        ERR_ExceptionHandler.handleAfflNullRecordTypeException(
                            affl,
                            afflMapper.validAccRecordTypesInMappings
                        );
                    }

                    Contact relatedContact = relatedContactsMap.get(affl.Contact__c);

                    //BEFORE INSERT - we do it in the Before so we don't get the affiliation we just created when we query for
                    //affls of the same type.
                    if (triggerAction == TDTM_Runnable.Action.BeforeInsert && this.isBeforeInsertRecursion() == false) {
                        if (
                            affl.Primary__c &&
                            affl.Contact__c != null &&
                            affl.Account__c != null &&
                            affl.Affiliation_Type__c != null &&
                            lookupFieldAPIName != null
                        ) {
                            afflsMadePrimary.add(affl);
                            this.setAffiliationMadePrimaryRecursion();
                            this.populateKeyAffls(affl, lookupFieldAPIName, relatedContact, dmlWrapper);
                        }
                    }

                    // AFTER UPDATE - Runs when AFTER UPDATE Code has not already been run (checked from Recursion Flag - TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Update)
                    // And when BEFORE INSERT code has not already been run (checked from Recursion Flag - TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary) so that values
                    // populated in BEFORE INSERT is not getting over-written in AFTER UPDATE
                    if (triggerAction == TDTM_Runnable.Action.AfterUpdate && this.isAfterUpdateRecursion() == false) {
                        Affiliation__c afflOld = (Affiliation__c) oldlist[i];

                        //If a primary affiliation is made nonprimary the key affiliation field on the contact needs to be cleared.
                        if (
                            afflOld.Primary__c &&
                            !affl.Primary__c &&
                            lookupFieldAPIName != null &&
                            relatedContact.get(lookupFieldAPIName) == affl.Account__c
                        ) {
                            if (
                                this.isContactPrimaryAffiliationUpdatedRecursion() == false &&
                                this.isAffiliationMadePrimaryRecursion() == false
                            ) {
                                relatedContact.put(lookupFieldAPIName, null);
                                dmlWrapper.objectsToUpdate.add(relatedContact);
                            }
                        }

                        //If a non-primary affiliation is made primary the key affiliation field on the contact needs to be filled,
                        //an any other primary affiliation of the same type needs to be made non-primary.
                        if (
                            affl.Primary__c &&
                            !afflOld.Primary__c &&
                            affl.Contact__c != null &&
                            affl.Account__c != null &&
                            lookupFieldAPIName != null
                        ) {
                            afflsMadePrimary.add(affl);
                            this.setAffiliationMadePrimaryRecursion();
                            this.populateKeyAffls(affl, lookupFieldAPIName, relatedContact, dmlWrapper);
                        }
                    }
                    i++;
                }
                if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
                    this.setBeforeInsertRecursion();
                } else if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                    this.setAfterUpdateRecursion();
                }
                if (afflsMadePrimary.size() > 0) {
                    this.uncheckOtherPrimariesSameType(afflsMadePrimary, dmlWrapper);
                }
            }

            if (oldlist != null && oldlist.size() > 0) {
                for (SObject so : oldlist) {
                    Affiliation__c afflOld = (Affiliation__c) so;
                    String lookupFieldAPIName = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType(
                        afflOld.Affiliation_Type__c
                    );

                    Contact relatedContact = relatedContactsMap.get(afflOld.Contact__c);

                    //AFTER DELETE - delete lookup relationship, if necessary
                    if (triggerAction == TDTM_Runnable.Action.AfterDelete && lookupFieldAPIName != null) {
                        this.processAfflDeleted(afflOld, relatedContact, lookupFieldAPIName, dmlWrapper);
                    }
                }
            }
        }

        //AFTER INSERT - Runs when AFTER INSERT Code has not already been run (checked from Recursion Flag - TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Insert)
        if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
            dmlWrapper = this.handleAfterInsert(newList, dmlWrapper);
        }

        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        dmlWrapper = null;

        if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
            this.unsetAfterInsertRecursion();
        } else if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
            this.unsetBeforeInsertRecursion();
            this.resetAffiliationMadePrimaryRecursion();
        } else if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            this.unsetAfterUpdateRecursion();
            this.resetAffiliationMadePrimaryRecursion();
        }

        return dmlWrapper;
    }

    /**
     * @description Handles after insert context in a recursion-safe fashion, running program enrollment creation
     * @param newList The list of SObjects of the Affiliation__c type being inserted
     * @param dmlWrapper The DMLWrapper to register changes to
     * @return The dmlWrapper that changes have been registered to
     */
    @TestVisible
    private DMLWrapper handleAfterInsert(List<SObject> newList, DMLWrapper dmlWrapper) {
        //NOTE: This is only a partial refactor. Class is in need of an overhaul
        if (this.isAfterInsertRecursion()) {
            return dmlWrapper;
        }

        this.setAfterInsertRecursion();

        if (newList?.isEmpty() != false) {
            return dmlWrapper;
        }

        List<Affiliation__c> newAffiliationList = (List<Affiliation__c>) newlist;

        for (Affiliation__c newAffiliation : newAffiliationList) {
            this.createProgramEnrollmentIfNecessary(newAffiliation, dmlWrapper);
        }

        return dmlWrapper;
    }

    /*******************************************************************************************************
     * @description Updates contacts to clear primary affiliation fields
     * @param afflOld The affiliation being deleted
     * @param relatedContact The Affiliation's Contact
     * @param lookupFieldAPIName The api name of the Contact primary affiliation lookup field
     * @param dmlWrapper The DML wrapper for processing of contacts
     * @return The contact updated after deletion
     *******************************************************************************************************/
    public Contact processAfflDeleted(
        Affiliation__c afflOld,
        Contact relatedContact,
        String lookupFieldAPIName,
        DmlWrapper dmlWrapper
    ) {
        //If the affl is primary, and the lookup field of this type is pointing to the account that is part of the affl ==> clear the lookup
        if (
            afflOld.Primary__c &&
            lookupFieldAPIName != null &&
            relatedContact != null &&
            relatedContact.get(lookupFieldAPIName) == afflOld.Account__c
        ) {
            if (this.isContactPrimaryAffiliationUpdatedRecursion() == false) {
                relatedContact.put(lookupFieldAPIName, null);
                dmlWrapper.objectsToUpdate.add(relatedContact);
                return relatedContact;
            }
        }

        return null;
    }

    /*******************************************************************************************************
     * @description Retrieves Contacts with all associated primary Affiliation lookup fields
     * @param affiliationList The Affiliation being deleted
     * @return The map of Contacts by their Ids with all primary Affiliation fields populated
     *******************************************************************************************************/
    public Map<Id, Contact> queryAfflLookupFields(List<SObject> afflsList) {
        //Query the primary affiliation fields for all contacts at once
        String contactIDs = '(';
        Map<Id, Contact> relatedContactsMap = new Map<ID, Contact>();
        if (afflsList != null && afflsList.size() > 0) {
            Affiliation__c firstAffl = (Affiliation__c) afflsList[0];
            if (firstAffl.Contact__c != null)
                contactIDs += '\'' + firstAffl.Contact__c + '\'';
            Integer i = 1;
            while (i < afflsList.size()) {
                Affiliation__c affl = (Affiliation__c) afflsList[i];
                if (affl.Contact__c != null)
                    contactIDs += ', \'' + affl.Contact__c + '\'';
                i++;
            }
            contactIDs += ')';

            //Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
            String dynamicQuery = 'select ID';
            for (String primaryField : afflMapper.primaryAfflFieldNames) {
                dynamicQuery = dynamicQuery + ', ' + primaryField;
            }
            dynamicQuery += ' from Contact where ID IN ' + contactIDs;
            UTIL_Debug.debug('****MRT: Dynamic query: ' + dynamicQuery);
            if (contactIDs != '()') {
                List<Contact> relatedContactsList = Database.query(dynamicQuery);
                for (Contact contact : relatedContactsList) {
                    relatedContactsMap.put(contact.ID, contact);
                }
            }
        }
        return relatedContactsMap;
    }

    /*******************************************************************************************************
     * @description Populates the primary affiliation field for a Contact from an Affiliation's Account
     * @param affl The Primary Affiliation being modified.
     * @param lookupFieldAPIName The api name of the Primary Affiliation lookup field
     * @param relatedContact The Contact to populate the Primary Affiliation field for
     * @param dmlWrapper The DmlWrapper to register the change to
     * @return The modified contact
     *******************************************************************************************************/
    @TestVisible
    private Contact populateKeyAffls(
        Affiliation__c affl,
        String lookupFieldAPIName,
        Contact relatedContact,
        DmlWrapper dmlWrapper
    ) {
        //If the reason why Affiliations have been made primary is that key affiliation fields on Contact have been populated,
        //we don't need to try populating them. In fact, this causes an error notification to be sent (W-009272).
        if (this.isContactPrimaryAffiliationUpdatedRecursion() == false) {
            //If we have a mapping, populate the lookup field defined in the mapping.
            if (!String.isBlank(lookupFieldAPIName)) {
                relatedContact.put(lookupFieldAPIName, affl.Account__c);
                dmlWrapper.objectsToUpdate.add(relatedContact);
                return relatedContact;
            }
        }

        return null;
    }

    /*******************************************************************************************************
     * @description Sets former primary affiliations to non-primary affiliations
     * @param affls The List of affiliations to set to not primary
     * @param dmlWrapper The DmlWrapper to register the changes to
     * @return The modified affiliations
     *******************************************************************************************************/
    @TestVisible
    public List<Affiliation__c> uncheckOtherPrimariesSameType(List<Affiliation__c> affls, DmlWrapper dmlWrapper) {
        Set<ID> newPrimaryAffls = new Set<ID>();
        Set<ID> afflContactIDs = new Set<ID>();
        Set<String> afflTypes = new Set<String>();
        List<Affiliation__c> oldPrimaryAffls = new List<Affiliation__c>();

        for (Affiliation__c affl : affls) {
            newPrimaryAffls.add(affl.ID);
            afflContactIDs.add(affl.Contact__c);
            afflTypes.add(affl.Affiliation_Type__c);
        }

        //Get all possible matches
        List<Affiliation__c> otherPrimaryAffls = [
            SELECT ID, Contact__c, Account__c, Affiliation_Type__c, Primary__c
            FROM Affiliation__c
            WHERE
                Affiliation_Type__c IN :afflTypes
                AND Contact__c IN :afflContactIDs
                AND Primary__c = TRUE
                AND ID NOT IN :newPrimaryAffls
        ];
        //Refine the result
        for (Affiliation__c otherPrimaryAffl : otherPrimaryAffls) {
            //Any pre-existing Affl with the same Contact and the same Type as any new Affl should be added to oldPrimaryAffls
            for (Affiliation__c newAffl : affls) {
                if (
                    otherPrimaryAffl.Contact__c == newAffl.Contact__c &&
                    otherPrimaryAffl.Affiliation_Type__c == newAffl.Affiliation_Type__c
                ) {
                    oldPrimaryAffls.add(otherPrimaryAffl);
                    break;
                }
            }
        }

        //If the newly created affiliation is the primary, uncheck other primary affiliations of the same type.
        for (Affiliation__c otherAffl : oldPrimaryAffls) {
            otherAffl.Primary__c = false;
        }
        dmlWrapper.objectsToUpdate.addAll((List<SObject>) oldPrimaryAffls);
        return oldPrimaryAffls;
    }

    /*******************************************************************************************************
     * @description Creates a program enrollment if Auto Enrollment has been set
     * @param affiliation The affiliation to potentially create program enrollment for
     * @param dmlWrapper The DmlWrapper to register the change to
     * @return The program enrollment created
     *******************************************************************************************************/
    @TestVisible
    private Program_Enrollment__c createProgramEnrollmentIfNecessary(
        Affiliation__c affiliation,
        DmlWrapper dmlWrapper
    ) {
        if (affiliation == null || affiliation.Affiliation_Type__c == null) {
            return null;
        }

        Boolean needsProgramEnrollment = AFFL_MultiRecordType_TDTM.afflMapper.needsProgramEnrollment(affiliation);
        UTIL_Debug.debug('****needsProgramEnrollment: ' + needsProgramEnrollment);

        if (needsProgramEnrollment != true) {
            return null;
        }

        Program_Enrollment__c programEnrollment = new Program_Enrollment__c(
            Affiliation__c = affiliation.ID,
            Contact__c = affiliation.Contact__c,
            Account__c = affiliation.Account__c
        );
        dmlWrapper.objectsToInsert.add(programEnrollment);
        return programEnrollment;
    }

    //Recursion Flags
    /*******************************************************************************************************
     * @description Determines whether current context is associated with a before insert recursion.
     *******************************************************************************************************/
    @TestVisible
    private Boolean isBeforeInsertRecursion() {
        return TDTM_ProcessControl.getRecursionFlag(BEFORE_INSERT_RECURSION);
    }

    /*******************************************************************************************************
     * @description Sets the Before Insert recursion flag for AFFL_MultiRecordType_TDTM.
     *******************************************************************************************************/
    @TestVisible
    private void setBeforeInsertRecursion() {
        TDTM_ProcessControl.setRecursionFlag(BEFORE_INSERT_RECURSION, true);
    }

    /*******************************************************************************************************
     * @description Clears the Before Insert recursion flag for AFFL_MultiRecordType_TDTM.
     *******************************************************************************************************/
    @TestVisible
    private void unsetBeforeInsertRecursion() {
        TDTM_ProcessControl.setRecursionFlag(BEFORE_INSERT_RECURSION, false);
    }

    /*******************************************************************************************************
     * @description Determines whether current context is associated with an after insert recursion.
     *******************************************************************************************************/
    @TestVisible
    private Boolean isAfterInsertRecursion() {
        return TDTM_ProcessControl.getRecursionFlag(AFTER_INSERT_RECURSION);
    }

    /*******************************************************************************************************
     * @description Sets the After Insert recursion flag for AFFL_MultiRecordType_TDTM.
     *******************************************************************************************************/
    @TestVisible
    private void setAfterInsertRecursion() {
        TDTM_ProcessControl.setRecursionFlag(AFTER_INSERT_RECURSION, true);
    }

    /*******************************************************************************************************
     * @description Clears the After Insert recursion flag for AFFL_MultiRecordType_TDTM.
     *******************************************************************************************************/
    @TestVisible
    private void unsetAfterInsertRecursion() {
        TDTM_ProcessControl.setRecursionFlag(AFTER_INSERT_RECURSION, false);
    }

    /*******************************************************************************************************
     * @description Determines whether current context is associated with an after update recursion.
     *******************************************************************************************************/
    @TestVisible
    private Boolean isAfterUpdateRecursion() {
        return TDTM_ProcessControl.getRecursionFlag(AFTER_UPDATE_RECURSION);
    }

    /*******************************************************************************************************
     * @description Sets the After Update recursion flag for AFFL_MultiRecordType_TDTM.
     *******************************************************************************************************/
    @TestVisible
    private void setAfterUpdateRecursion() {
        TDTM_ProcessControl.setRecursionFlag(AFTER_UPDATE_RECURSION, true);
    }

    /*******************************************************************************************************
     * @description Clears the After Update recursion flag for AFFL_MultiRecordType_TDTM.
     *******************************************************************************************************/
    @TestVisible
    private void unsetAfterUpdateRecursion() {
        TDTM_ProcessControl.setRecursionFlag(AFTER_UPDATE_RECURSION, false);
    }

    /*******************************************************************************************************
     * @description Determines whether current context is associated with an affiliation made primary
     * recursion
     *******************************************************************************************************/
    @TestVisible
    private Boolean isAffiliationMadePrimaryRecursion() {
        return TDTM_ProcessControl.getRecursionFlag(AFFILIATION_MADE_PRIMARY_RECURSION);
    }

    /*******************************************************************************************************
     * @description Sets the Affiliation Made Primary recursion flag for AFFL_MultiRecordType_TDTM.
     *******************************************************************************************************/
    @TestVisible
    private void setAffiliationMadePrimaryRecursion() {
        TDTM_ProcessControl.setRecursionFlag(AFFILIATION_MADE_PRIMARY_RECURSION, true);
    }

    /*******************************************************************************************************
     * @description Resets the Affiliation Made Primary recursion flag for AFFL_MultiRecordType_TDTM.
     *******************************************************************************************************/
    @TestVisible
    private void resetAffiliationMadePrimaryRecursion() {
        TDTM_ProcessControl.resetRecursionFlag(AFFILIATION_MADE_PRIMARY_RECURSION);
    }

    /*******************************************************************************************************
     * @description Determines whether current context is associated with an affiliation made primary in
     * the contact trigger recursion
     *******************************************************************************************************/
    @TestVisible
    private Boolean isContactPrimaryAffiliationUpdatedRecursion() {
        return TDTM_ProcessControl.getRecursionFlag(CONTACT_PRIMARY_AFFILIATION_UPDATED_RECURSION);
    }
}
