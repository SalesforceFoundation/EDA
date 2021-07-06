/*
    Copyright (c) 2021, Salesforce.org
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
 * @date 2021
 * @group Affiliations
 * @group-content ../../ApexDocContent/Affiliations.htm
 * @description Test setup factory for affiliation tests due to complexity
 */
@isTest
public class AffiliationTestSetupFactory_TEST {
    /**************************************************************************
     * SETUP
     **************************************************************************/

    /**************************************************************************
     * @description Sets up hierarchy settings and affiliation mappings for
     * tests using record type name and contact field api name
     * @return The affiliation mapping wrappers set up for the tests.
     **************************************************************************/
    public static List<AffiliationMappingWrapper> setupMappingsByDevNameAndApiName() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.getAfflMappingWrapperByDevNameAndApiName();

        return AffiliationTestSetupFactory_TEST.commonSetup(affiliationMappingWrapperList);
    }

    /**************************************************************************
     * @description Sets up hierarchy settings and affiliation mappings for
     * tests using record type name and contact field label
     * @return The affiliation mapping wrappers set up for the tests.
     **************************************************************************/
    public static List<AffiliationMappingWrapper> setupMappingsByDevNameAndLabel() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.getAfflMappingWrapperByDevNameAndLabel();

        return AffiliationTestSetupFactory_TEST.commonSetup(affiliationMappingWrapperList);
    }

    /**************************************************************************
     * @description Sets up hierarchy settings and affiliation mappings for
     * tests using record type name and contact field api name
     * @return The affiliation mapping wrappers set up for the tests.
     **************************************************************************/
    public static List<AffiliationMappingWrapper> setupMappingsByNameAndApiName() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.getAfflMappingWrapperByNameAndApiName();

        return AffiliationTestSetupFactory_TEST.commonSetup(affiliationMappingWrapperList);
    }

    /**************************************************************************
     * @description Sets up hierarchy settings and affiliation mappings for
     * tests using record type name and contact field label
     * @return The affiliation mapping wrappers set up for the tests.
     **************************************************************************/
    public static List<AffiliationMappingWrapper> setupMappingsByNameAndLabel() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.getAfflMappingWrapperByNameAndLabel();

        return AffiliationTestSetupFactory_TEST.commonSetup(affiliationMappingWrapperList);
    }

    /**************************************************************************
     * @description Sets up hierarchy settings and affiliation mappings for
     * tests using provided affiliation wrapper mappings common to all setup
     * scenarios
     * @param affiliationMappingWrapperList The wrapper mappings to set up
     * the test with
     * @return The affiliation mapping wrappers set up for the tests.
     **************************************************************************/
    public static List<AffiliationMappingWrapper> commonSetup(
        List<AffiliationMappingWrapper> affiliationMappingWrapperList
    ) {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = affiliationMappingWrapperList[0].getAccountRecordTypeId())
        );

        affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.populateRecordTypeNamesForWrappers(
            affiliationMappingWrapperList
        );

        insert AffiliationTestSetupFactory_TEST.createAffiliationMappings(affiliationMappingWrapperList);

        return affiliationMappingWrapperList;
    }

    /**************************************************************************
     * @description Gets the account record type developer name to contact field
     * api name wrappers for test setup and sets old id values for backward
     * compatibility
     * @return the list of account record type to contact label pairings to use
     * for further setup with the intended record type id for the account
     * processor as the first element.
     **************************************************************************/
    private static List<AfflMappingWrapperByDevNameAndApiName> getAfflMappingWrapperByDevNameAndApiName() {
        List<AfflMappingWrapperByDevNameAndApiName> wrapperList = new List<AfflMappingWrapperByDevNameAndApiName>();

        List<String> contactPrimaryAffiliationFieldApiNameList = AffiliationTestSetupFactory_TEST.getContactPrimaryAffiliationFieldApiNames();

        wrapperList.add(
            new AfflMappingWrapperByDevNameAndApiName(
                UTIL_Describe.getCustomHHAccRecTypeID(),
                contactPrimaryAffiliationFieldApiNameList[0]
            )
        );

        wrapperList.add(
            new AfflMappingWrapperByDevNameAndApiName(
                UTIL_Describe_API.getBizAccRecTypeID(),
                contactPrimaryAffiliationFieldApiNameList[1]
            )
        );

        return wrapperList;
    }

    /**************************************************************************
     * @description Gets the account record type developer name to contact label
     * wrappers for test setup and sets old id values for backward compatibility
     * @return the list of account record type to contact label pairings to use
     * for further setup with the intended record type id for the account
     * processor ashe first element.
     **************************************************************************/
    private static List<AfflMappingWrapperByDevNameAndLabel> getAfflMappingWrapperByDevNameAndLabel() {
        List<AfflMappingWrapperByDevNameAndLabel> wrapperList = new List<AfflMappingWrapperByDevNameAndLabel>();

        List<String> contactPrimaryAffiliationFieldNameList = AffiliationTestSetupFactory_TEST.getContactPrimaryAffiliationFieldLabels();

        wrapperList.add(
            new AfflMappingWrapperByDevNameAndLabel(
                UTIL_Describe.getCustomHHAccRecTypeID(),
                contactPrimaryAffiliationFieldNameList[0]
            )
        );

        wrapperList.add(
            new AfflMappingWrapperByDevNameAndLabel(
                UTIL_Describe_API.getBizAccRecTypeID(),
                contactPrimaryAffiliationFieldNameList[1]
            )
        );

        return wrapperList;
    }

    /**************************************************************************
     * @description Gets the account record type name to contact field api name
     * wrappers for test setup and sets old id values for backward compatibility
     * @return the list of account record type to contact label pairings to use
     * for further setup with the intended record type id for the account
     * processor as the first element.
     **************************************************************************/
    public static List<AfflMappingWrapperByNameAndApiName> getAfflMappingWrapperByNameAndApiName() {
        List<AfflMappingWrapperByNameAndApiName> wrapperList = new List<AfflMappingWrapperByNameAndApiName>();

        List<String> contactPrimaryAffiliationFieldApiNameList = AffiliationTestSetupFactory_TEST.getContactPrimaryAffiliationFieldApiNames();

        wrapperList.add(
            new AfflMappingWrapperByNameAndApiName(
                UTIL_Describe.getCustomHHAccRecTypeID(),
                contactPrimaryAffiliationFieldApiNameList[0]
            )
        );

        wrapperList.add(
            new AfflMappingWrapperByNameAndApiName(
                UTIL_Describe_API.getBizAccRecTypeID(),
                contactPrimaryAffiliationFieldApiNameList[1]
            )
        );

        return wrapperList;
    }

    /**************************************************************************
     * @description Gets the account record type name to contact label wrappers
     * for test setup and sets old id values for backward compatibility
     * @return the list of account record type to contact label pairings to use
     * for further setup with the intended record type id for the account
     * processor ashe first element.
     **************************************************************************/
    public static List<AfflMappingWrapperByNameAndLabel> getAfflMappingWrapperByNameAndLabel() {
        List<AfflMappingWrapperByNameAndLabel> wrapperList = new List<AfflMappingWrapperByNameAndLabel>();

        List<String> contactPrimaryAffiliationFieldNameList = AffiliationTestSetupFactory_TEST.getContactPrimaryAffiliationFieldLabels();

        wrapperList.add(
            new AfflMappingWrapperByNameAndLabel(
                UTIL_Describe.getCustomHHAccRecTypeID(),
                contactPrimaryAffiliationFieldNameList[0]
            )
        );

        wrapperList.add(
            new AfflMappingWrapperByNameAndLabel(
                UTIL_Describe_API.getBizAccRecTypeID(),
                contactPrimaryAffiliationFieldNameList[1]
            )
        );

        return wrapperList;
    }

    /**************************************************************************
     * @description Initializes the mappings based on the affiliation mapping
     * wrappers passed to it
     * @param affiliationMappingWrapperList The list of account record type ids to get
     * mappings for.
     * @return The List of Affiliation Mappings to insert.
     **************************************************************************/
    public static List<AffiliationMappingWrapper> populateRecordTypeNamesForWrappers(
        List<AffiliationMappingWrapper> affiliationMappingWrapperList
    ) {
        System.assertEquals(
            false,
            affiliationMappingWrapperList.size() < 2,
            '2 Account Record Types were not found for affiliation mappings'
        );

        Map<Id, Schema.RecordTypeInfo> accountRecordTypeInfosByIds = AffiliationTestSetupFactory_TEST.getIdToAccountRecordTypesMap();

        for (AffiliationMappingWrapper affiliationMappingWrapper : affiliationMappingWrapperList) {
            affiliationMappingWrapper.setRecordTypeNamesFromId(accountRecordTypeInfosByIds);
        }

        return affiliationMappingWrapperList;
    }

    /**************************************************************************
     * @description Get record type infos for an account
     * @return The List of Affiliation Mappings to insert.
     **************************************************************************/
    private static Map<Id, Schema.RecordTypeInfo> getIdToAccountRecordTypesMap() {
        Schema.DescribeSObjectResult accountDescribe = UTIL_Describe.getObjectDescribe('Account');

        return accountDescribe.getRecordTypeInfosByID();
    }

    /**************************************************************************
     * @description Creates affiliation mappings from wrappers, setting the
     * related mapping to the wrapper for later reference
     * @param affiliationMappingWrapperList The list of mapping wrappers to
     * create mappings for
     * @return The affiliation mappings created
     **************************************************************************/
    private static List<Affl_Mappings__c> createAffiliationMappings(
        List<AffiliationMappingWrapper> affiliationMappingWrapperList
    ) {
        List<Affl_Mappings__c> affiliationMappingSettings = new List<Affl_Mappings__c>();

        for (AffiliationMappingWrapper affiliationMappingWrapper : affiliationMappingWrapperList) {
            affiliationMappingWrapper.setAffiliationMapping();
            affiliationMappingSettings.add(affiliationMappingWrapper.getAffiliationMapping());
        }

        return affiliationMappingSettings;
    }

    /**************************************************************************
     * UTILITIES
     **************************************************************************/

    /**************************************************************************
     * @description Gets the contact primary affiliation field labels with the
     * household field as the first index and the business organization field
     * as the second index
     * @return the list of contact primary affiliation field labels
     **************************************************************************/
    public static List<String> getContactPrimaryAffiliationFieldLabels() {
        List<String> fieldLabelList = new List<String>();

        fieldLabelList.add(AffiliationTestSetupFactory_TEST.getHouseholdFieldLabel());
        fieldLabelList.add(AffiliationTestSetupFactory_TEST.getBusinessOrganizationFieldLabel());

        return fieldLabelList;
    }

    /**************************************************************************
     * @description Gets the contact primary affiliation field label for
     * Business Organization
     * @return the contact primary affiliation field labels for Business
     * Organization
     **************************************************************************/
    public static String getBusinessOrganizationFieldLabel() {
        return 'Primary Business Organization';
    }

    /**************************************************************************
     * @description Gets the contact primary affiliation field labels for
     * Household
     * @return the contact primary affiliation field labels for Household
     **************************************************************************/
    public static String getHouseholdFieldLabel() {
        return 'Primary Household';
    }

    /**************************************************************************
     * @description Gets the contact primary affiliation namespaced api names
     * with the household field as the first index and the business
     * organization field as the second index
     * @return the list of contact primary affiliation local field names
     **************************************************************************/
    public static List<String> getContactPrimaryAffiliationFieldApiNames() {
        List<String> fieldApiNameList = new List<String>();

        fieldApiNameList.add(AffiliationTestSetupFactory_TEST.getHouseholdFieldApiName());
        fieldApiNameList.add(AffiliationTestSetupFactory_TEST.getBusinessOrganizationFieldApiName());

        return fieldApiNameList;
    }

    /**************************************************************************
     * @description Gets the contact primary affiliation field api name for
     * Business Organization
     * @return the contact primary affiliation field api name for Business
     * Organization
     **************************************************************************/
    public static String getBusinessOrganizationFieldApiName() {
        return UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c');
    }

    /**************************************************************************
     * @description Gets the contact primary affiliation field api name for
     * Household
     * @return the contact primary affiliation field api name for Household
     **************************************************************************/
    private static String getHouseholdFieldApiName() {
        return UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c');
    }

    /**************************************************************************
     * @description Enables affiliation record type enforcement to true,
     * assuming settings have been initialized. Leverages caching of the
     * settings.
     **************************************************************************/
    public static void enableAffiliationRecordTypeEnforcement() {
        UTIL_CustomSettings_API.getSettings().Affiliation_Record_Type_Enforced__c = true;
    }
    /**************************************************************************
     * INNER CLASS MODELS
     **************************************************************************/

    public abstract class AffiliationMappingWrapper {
        Id accountRecordTypeId;
        String accountRecordTypeDeveloperName;
        String accountRecordTypeName;
        Affl_Mappings__c affiliationMapping;
        String contactFieldApiName;
        String contactFieldLabel;

        /**************************************************************************
         * @description Gets the account record type Id for the mapping
         * @return The account record type Id for the mapping
         **************************************************************************/
        public Id getAccountRecordTypeId() {
            return this.accountRecordTypeId;
        }

        /**************************************************************************
         * @description Gets the underlying affiliation mapping
         * @return The underlying affiliation mapping
         **************************************************************************/
        public Affl_Mappings__c getAffiliationMapping() {
            return this.affiliationMapping;
        }

        /**************************************************************************
         * @description Gets the account record type developer name for the mapping
         * @return The account record type developer name for the mapping
         **************************************************************************/
        public String getAccountRecordTypeDeveloperName() {
            return this.accountRecordTypeDeveloperName;
        }

        /**************************************************************************
         * @description Gets the account record type name for the mapping
         * @return The account record type name for the mapping
         **************************************************************************/
        public String getAccountRecordTypeName() {
            return this.accountRecordTypeName;
        }

        /**************************************************************************
         * @description Sets the account record type name for the mapping
         * @param accountRecordTypeName the new account record type name for the
         * mapping
         **************************************************************************/
        public void setAccountRecordTypeName(String accountRecordTypeName) {
            this.accountRecordTypeName = accountRecordTypeName;
        }

        /**************************************************************************
         * @description Gets the contact field label for the mapping
         * @return The contact field label for the mapping
         **************************************************************************/
        public String getContactFieldLabel() {
            return this.contactFieldLabel;
        }

        /**************************************************************************
         * @description Sets the record name from its id and the map of account
         * record type infos
         **************************************************************************/
        public void setRecordTypeNamesFromId(Map<Id, Schema.RecordTypeInfo> accountRecordTypeInfosByIds) {
            if (String.isBlank(this.getAccountRecordTypeId())) {
                return;
            }

            this.accountRecordTypeName = accountRecordTypeInfosByIds.get(this.accountRecordTypeId).getName();
            this.accountRecordTypeDeveloperName = accountRecordTypeInfosByIds.get(this.accountRecordTypeId)
                .getDeveloperName();
        }

        public virtual void setAffiliationMapping() {
        }
    }

    private class AfflMappingWrapperByDevNameAndApiName extends AffiliationMappingWrapper {
        /**************************************************************************
         * @description Creates a mapping wrapper using contact field api name,
         * account record type developer name, and account record type Id
         * @param accountRecordTypeId The record type id to use for the
         * mapping
         * @param contactFieldApiName The api name of the contact field to use for
         * the mapping
         **************************************************************************/
        public AfflMappingWrapperByDevNameAndApiName(Id accountRecordTypeId, String contactFieldApiName) {
            this.accountRecordTypeId = accountRecordTypeId;
            this.contactFieldApiName = contactFieldApiName;
        }
        /**************************************************************************
         * @description Sets the wrapper's mapping to one created by account name
         * and contact field label.
         **************************************************************************/
        public override void setAffiliationMapping() {
            this.affiliationMapping = new Affl_Mappings__c(
                Name = this.accountRecordTypeName,
                Account_Record_Type__c = this.accountRecordTypeDeveloperName,
                Primary_Affl_Field__c = this.contactFieldApiName
            );
        }
    }

    private class AfflMappingWrapperByDevNameAndLabel extends AffiliationMappingWrapper {
        /**************************************************************************
         * @description Creates a mapping wrapper using contact field label, account
         * record type developer name, and account record type Id
         * @param accountRecordTypeId The record type id to use for the
         * mapping
         * @param contactFieldLabel The label of the contact field to use for the
         * mapping
         **************************************************************************/
        public AfflMappingWrapperByDevNameAndLabel(Id accountRecordTypeId, String contactFieldLabel) {
            this.accountRecordTypeId = accountRecordTypeId;
            this.contactFieldLabel = contactFieldLabel;
        }
        /**************************************************************************
         * @description Sets the wrapper's mapping to one created by account name
         * and contact field label.
         **************************************************************************/
        public override void setAffiliationMapping() {
            this.affiliationMapping = new Affl_Mappings__c(
                Name = this.accountRecordTypeName,
                Account_Record_Type__c = this.accountRecordTypeDeveloperName,
                Primary_Affl_Field__c = this.contactFieldLabel
            );
        }
    }

    public class AfflMappingWrapperByNameAndApiName extends AffiliationMappingWrapper {
        /**************************************************************************
         * @description Creates a mapping wrapper using contact field api name,
         * account record type name, and account record type Id
         * @param accountRecordTypeId The record type id to use for the
         * mapping
         * @param contactFieldApiName The api name of the contact field to use for
         * the mapping
         **************************************************************************/
        public AfflMappingWrapperByNameAndApiName(Id accountRecordTypeId, String contactFieldApiName) {
            this.accountRecordTypeId = accountRecordTypeId;
            this.contactFieldApiName = contactFieldApiName;
        }
        /**************************************************************************
         * @description Sets the wrapper's mapping to one created by account name
         * and contact field label.
         **************************************************************************/
        public override void setAffiliationMapping() {
            this.affiliationMapping = new Affl_Mappings__c(
                Name = this.accountRecordTypeName,
                Account_Record_Type__c = this.accountRecordTypeName,
                Primary_Affl_Field__c = this.contactFieldApiName
            );
        }
    }

    public class AfflMappingWrapperByNameAndLabel extends AffiliationMappingWrapper {
        /**************************************************************************
         * @description Creates a mapping wrapper using contact field label, account
         * record type name, and account record type Id
         * @param accountRecordTypeId The record type id to use for the
         * mapping
         * @param contactFieldLabel The label of the contact field to use for the
         * mapping
         **************************************************************************/
        public AfflMappingWrapperByNameAndLabel(Id accountRecordTypeId, String contactFieldLabel) {
            this.accountRecordTypeId = accountRecordTypeId;
            this.contactFieldLabel = contactFieldLabel;
        }
        /**************************************************************************
         * @description Sets the wrapper's mapping to one created by account name
         * and contact field label.
         **************************************************************************/
        public override void setAffiliationMapping() {
            this.affiliationMapping = new Affl_Mappings__c(
                Name = this.accountRecordTypeName,
                Account_Record_Type__c = this.accountRecordTypeName,
                Primary_Affl_Field__c = this.contactFieldLabel
            );
        }
    }
}
