/*
    Copyright (c) 2020, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
* @date 2020
* @group 
* @group-content ../../ApexDocContent/Contacts.htm
* @description Service class for CON_PrimaryAffls_TDTM. Returns Affiliations to insert and update for the List of Contacts.
*/
public virtual with sharing class SRVC_Contact_PrimaryAffiliations {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static SRVC_Contact_PrimaryAffiliations instance;

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of SRVC_Contact_PrimaryAffiliations.
    ******************************************************************************/
    public static SRVC_Contact_PrimaryAffiliations getInstance() {
        if (instance == null) {
            instance = new SRVC_Contact_PrimaryAffiliations();
        }

        return instance;
    }

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected SRVC_Contact_PrimaryAffiliations() {}

    /*****************************************************************************
    * @description Returns negated AFFL_MultiRecordType_TDTM_afflMadePrimary flag 
    * to determine if Affiliations need to be created when Contact is updated
    *****************************************************************************/
    @TestVisible
    private boolean shouldCreateAffiliationsForUpdate() {
        return !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary);
    }

    /************************************************************************
    * @description Returns a list of Affiliations to create for the Contacts
    * @Param contactList List of Contacts to create Affiliations for
    * @Param afflMappingsModelsList List of Primary Affiliations Models
    ************************************************************************/
    public List<Affiliation__c> getAffiliationsToCreate(List<Contact> contactList, List<MODL_PrimaryAfflMapper> afflMappingsModelsList) {
        List<Affiliation__c> affiliationsToCreateList = new List<Affiliation__c>();
        for (Contact eachContact: contactList) {
            List<Affiliation__c> affiliationsToCreateForEachContactList = this.getAffiliationsToCreateForContact(eachContact, afflMappingsModelsList);
            affiliationsToCreateList.addAll(affiliationsToCreateForEachContactList);
        }
        return affiliationsToCreateList;
    }

    /************************************************************************
    * @description Returns a list of Affiliations to create for each Contact
    * @Param contact Contact to create Affiliations for
    * @Param afflMappingsModelsList List of Primary Affiliations Models
    ************************************************************************/
    @TestVisible
    private List<Affiliation__c> getAffiliationsToCreateForContact(Contact contact, List<MODL_PrimaryAfflMapper> afflMappingsModelsList) {
        List<Affiliation__c> affiliationsToCreateForEachContactList = new List<Affiliation__c>();
        try {
            for (MODL_PrimaryAfflMapper eachModel: afflMappingsModelsList) {
                if (contact.get(eachModel.getContactFieldApiName()) == null) {
                    continue;
                }

                if (eachModel.getIsValid() == false){
                    contact.addError(Label.afflAccoutMappingError);
                    throw new ERR_ExceptionHandler.AffAccountRecordTypeMappingsException(Label.afflAccoutMappingError);
                }

                Affiliation__c afflToCreate;
                
                try {
                    afflToCreate = new Affiliation__c(Contact__c = contact.ID, Account__c = (Id)contact.get(eachModel.getContactFieldApiName()), Primary__c = true);
                } catch (System.TypeException typeExc) {
                    Contact.addError(typeExc.getMessage());
                    throw new ERR_ExceptionHandler.AffAccountRecordTypeMappingsException(Label.afflAccoutMappingError);
                } catch (System.StringException stringExc) {
                    Contact.addError(stringExc.getMessage());
                    throw new ERR_ExceptionHandler.AffAccountRecordTypeMappingsException(Label.afflAccoutMappingError);
                }
                affiliationsToCreateForEachContactList.add(afflToCreate);
            }
        } catch (ERR_ExceptionHandler.AffAccountRecordTypeMappingsException error) {
            return new List<Affiliation__c>();
        }

        return affiliationsToCreateForEachContactList;
    }

    /************************************************************************
    * @description Returns a list of Affiliations to create for each Contact
    * @Param newContactsById New Contacts with Id as key
    * @Param oldContactsById Old Contacts with Id as key
    * @Param afflMappingsModelsList List of Primary Affiliations Models
    ************************************************************************/
    public AffiliationsToInsertAndUpdate getAffiliationsToCreateOrUpdate(Map<Id, Contact> newContactsById, Map<Id, Contact> oldContactsById, List<MODL_PrimaryAfflMapper> afflMappingsModelsList) {

        List<Affiliation__c> afflToBeAddedList = new List<Affiliation__c>();
        Map<Id, Set<Id>> accountIdsSetByContactId = new Map<Id, Set<Id>>();
        Set<Id> accountIdSet = new Set<Id>();
        Boolean shouldCreateAffiliatons = this.shouldCreateAffiliationsForUpdate();

        for (Contact newContact: newContactsById.values()) {
            AffiliationsToProcess afflsToProcess;
            Set<Id> accIdSet;

            if (shouldCreateAffiliatons == true) {
                afflsToProcess = this.getAffiliationsToCreateOrUpdateForContact(newContact, oldContactsById.get(newContact.Id), afflMappingsModelsList);
                afflToBeAddedList.addAll(afflsToProcess.getAffiliationListToInsertClone());
                accIdSet = afflsToProcess.getAccountIdSet();
            } else {
                accIdSet = this.getAffiliationsToUpdateForContact(newContact, oldContactsById.get(newContact.Id), afflMappingsModelsList);
            }

            if (accIdSet.isEmpty() == false) {
                accountIdsSetByContactId.put(newContact.Id, accIdSet);
                accountIdSet.addAll(accIdSet);
            }
        }

        List<Affiliation__c> affiliationsToUpdateList = this.getAffiliationsToUpdate(accountIdsSetByContactId, accountIdSet);

        AffiliationsToInsertAndUpdate afflsToInsertAndUpdate = new AffiliationsToInsertAndUpdate(afflToBeAddedList, affiliationsToUpdateList);
        return afflsToInsertAndUpdate;

    }

    /************************************************************************
    * @description Returns a list of Affiliations to create for each Contact
    * @Param newContact The contact to create Affiliations for
    * oldContact The contact before update
    * @Param afflMappingsModelsList List of Primary Affiliations Models
    ************************************************************************/
    @TestVisible 
    Private AffiliationsToProcess getAffiliationsToCreateOrUpdateForContact(Contact newContact, Contact oldContact, List<MODL_PrimaryAfflMapper> afflMappingsModelsList) {

        List<Affiliation__c> affiliationsToCreateForEachContactList = new List<Affiliation__c>();
        Set<Id> accountIds = new Set<Id>();

        try{
            for (MODL_PrimaryAfflMapper eachModel: afflMappingsModelsList) {

                if (newContact.get(eachModel.getContactFieldApiName()) == oldContact.get(eachModel.getContactFieldApiName())) {
                    continue;
                }

                if (newContact.get(eachModel.getContactFieldApiName()) != null) {
                    if (eachModel.getIsValid() == false){
                        newContact.addError(Label.afflAccoutMappingError);
                        throw new ERR_ExceptionHandler.AffAccountRecordTypeMappingsException(Label.afflAccoutMappingError);
                    }

                    Affiliation__c afflToCreate;

                    try {
                        afflToCreate = new Affiliation__c(Contact__c = newContact.ID, Account__c = (Id)newContact.get(eachModel.getContactFieldApiName()), Primary__c = true);
                    } catch (System.TypeException typeExc) {
                        newContact.addError(typeExc.getMessage());
                        throw new ERR_ExceptionHandler.AffAccountRecordTypeMappingsException(Label.afflAccoutMappingError);
                    } catch (System.StringException stringExc) {
                        newContact.addError(stringExc.getMessage());
                        throw new ERR_ExceptionHandler.AffAccountRecordTypeMappingsException(Label.afflAccoutMappingError);
                    }
                    affiliationsToCreateForEachContactList.add(afflToCreate);
                }

                if (oldContact.get(eachModel.getContactFieldApiName()) != null) {
                     accountIds.add((Id)oldContact.get(eachModel.getContactFieldApiName()));
                }
            }
        } catch (ERR_ExceptionHandler.AffAccountRecordTypeMappingsException error) {
           AffiliationsToProcess AfflsToProcess = new AffiliationsToProcess();
           return AfflsToProcess;
        }

        AffiliationsToProcess AfflsToProcess = new AffiliationsToProcess(affiliationsToCreateForEachContactList, accountIds);
        return AfflsToProcess;
    }

    /************************************************************************
    * @description Returns a list of Affiliations to update for each Contact
    * @Param newContact The contact to update Affiliations for
    * @Param newContact The contact to before update
    * @Param accountIds Set of accountIds of the affiliaitons to be updated
    ************************************************************************/
    @TestVisible 
    Private Set<Id> getAffiliationsToUpdateForContact(Contact newContact, Contact oldContact, List<MODL_PrimaryAfflMapper> afflMappingsModelsList) {

        List<Affiliation__c> affiliationsToCreateForEachContactList = new List<Affiliation__c>();
        Set<Id> accountIds = new Set<Id>();

        for (MODL_PrimaryAfflMapper eachModel: afflMappingsModelsList) {

            if (newContact.get(eachModel.getContactFieldApiName()) == oldContact.get(eachModel.getContactFieldApiName())) {
                continue;
            }

            if (oldContact.get(eachModel.getContactFieldApiName()) != null) {
                accountIds.add((Id)oldContact.get(eachModel.getContactFieldApiName()));
            }
        }

        return accountIds;
    }

    /***************************************************************************
    * @description Returns a list of Affiliations to be updated
    * @Param contactIdsByAccountIdSets A map of all Accounts Ids by ContactId
    * @Param accountIdSetToFilter Set of Ids to find affiliations to update for
    ****************************************************************************/
    @TestVisible 
    Private List<Affiliation__c> getAffiliationsToUpdate(Map<Id, Set<Id>> accountIdsByContactIdSets, Set<Id> accountIdSetToFilter) {

        List<Affiliation__c> afflsToMakeNonPrimary = new List<Affiliation__c>();

        //Get all possible affiliations from the accountIdsByContactIdSets
        List<Affiliation__c> affiliationsToUpdate = [SELECT Id,
                                                     Contact__c,
                                                     Account__c
                                                     FROM Affiliation__c
                                                     WHERE Contact__c IN :accountIdsByContactIdSets.keySet()
                                                     AND Primary__c = true
                                                     AND Account__c IN :accountIdSetToFilter];

        //Refine the search - accountIdsByContactIdSets should contain only the Acc IDs of those key Affl lookups that have been modified.
        for (Affiliation__c eachAffiliationToUpdate : affiliationsToUpdate) {
            Set<ID> contactAccIDs = accountIdsByContactIdSets.get(eachAffiliationToUpdate.Contact__c);
            for (ID changedAccID : contactAccIDs) {
                if (eachAffiliationToUpdate.Account__c == changedAccID) {
                    eachAffiliationToUpdate.Primary__c = false;
                    afflsToMakeNonPrimary.add(eachAffiliationToUpdate);
                }
            }
        }
        return afflsToMakeNonPrimary;
    }

    /************************************************************************************************************
    * @description Value object specifying a list of new Affiliation records to be inserted 
    * and a list of existing Affiliation records to be updated.
    ************************************************************************************************************/
    public class AffiliationsToInsertAndUpdate {

        private final List<Affiliation__c> affiliationsToInsertList;
        private final List<Affiliation__c> affiliationsToUpdateList;

        public AffiliationsToInsertAndUpdate(List<Affiliation__c> affiliationsToInsertList, List<Affiliation__c> affiliationsToUpdateList){
            this.affiliationsToInsertList = affiliationsToInsertList;
            this.affiliationsToUpdateList = affiliationsToUpdateList;
        }

        public List<Affiliation__c> getAffiliationListToInsertClone() {
            return affiliationsToInsertList.clone();
        }

        public List<Affiliation__c> getAffiliationListToUpdateClone() {
            return affiliationsToUpdateList.clone();
        }
        
    }

    /************************************************************************************************************
    * @description Value object specifying a list of new Affiliation records to be inserted 
    * and a list of existing Affiliation records to be updated.
    ************************************************************************************************************/
    public class AffiliationsToProcess {

        @testVisible
        private List<Affiliation__c> affiliationsToInsertList;

        @testVisible
        private Set<Id> accountIdSet;

        public AffiliationsToProcess(){
            affiliationsToInsertList = new List<Affiliation__c>();
            accountIdSet = new Set<Id>();
        }

        public AffiliationsToProcess(List<Affiliation__c> affiliationsToInsertList, Set<Id> accountIdSet){
            this.affiliationsToInsertList = affiliationsToInsertList;
            this.accountIdSet = accountIdSet;
        }

        public List<Affiliation__c> getAffiliationListToInsertClone() {
            return affiliationsToInsertList.clone();
        }

        public Set<Id> getAccountIdSet() {
            return accountIdSet.clone();
        }
    }
}
