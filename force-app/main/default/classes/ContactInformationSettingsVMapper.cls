/*
    Copyright (c) 2021, Salesforce.org
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
 * @date 2021
 * @group
 * @group-content ../../ApexDocContent/
 * @description View Mapper class to to generate view models associated with
 * Contact Language functionality.
 */
public virtual with sharing class ContactInformationSettingsVMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static ContactInformationSettingsVMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected ContactInformationSettingsVMapper() {
    }

    /******************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of ContactInformationSettingsVMapper.
     ******************************************************************************/
    public static ContactInformationSettingsVMapper getInstance() {
        if (instance == null) {
            instance = new ContactInformationSettingsVMapper();
        }

        return instance;
    }

    /**********************************************************************************************
     * @description Retrieve a model representing the Contact Language fluency settings specified
     * in Hierarchy Settings and all available active options.
     * @return A ContactLanguageSettingsVModel.
     **********************************************************************************************/
    public virtual ContactLanguageSettingsVModel getContactLanguageSettingsVModel() {
        ContactLanguageSettingsModel contactLanguageSettingsModel = this.locateContactLanguageSettingsService()
            .getContactLanguageSettingsModel();

        Map<String, PicklistEntryModel> allContactLanguageFluencyPicklistEntryModelsByName = this.locatePicklistEntryService()
            .getModelsByNameForSObjectField(Contact_Language__c.SObjectType, Contact_Language__c.Fluency__c);

        Map<String, PicklistEntryModel> activeContactLanguageFluencyPicklistEntryModelsByName = this.locatePicklistEntryService()
            .getActivePicklistEntryModelsByName(allContactLanguageFluencyPicklistEntryModelsByName);

        List<ComboboxValueVModel> contactLanguageFluencyComboboxValueVModelsList = new List<ComboboxValueVModel>();

        for (PicklistEntryModel picklistEntryModel : activeContactLanguageFluencyPicklistEntryModelsByName.values()) {
            contactLanguageFluencyComboboxValueVModelsList.add(
                new ComboboxValueVModel(picklistEntryModel.label, picklistEntryModel.name)
            );
        }

        return new ContactLanguageSettingsVModel(
            new ComboboxVModel(
                contactLanguageSettingsModel.defaultContactLanguageFluency,
                contactLanguageFluencyComboboxValueVModelsList
            )
        );
    }

    /**********************************************************************************************
     * @description Retrieve a model representing the Preferred Contact Information settings specified
     * in Hierarchy Settings and all available phone type options.
     * @return A PreferredContactInfoSettingsVModel.
     **********************************************************************************************/
    public virtual PreferredContactInfoSettingsVModel getPreferredContactInformationSettingsVModel() {
        // get current preferred contact info settings in hierarchy settings
        PreferredContactInfoSettingsModel preferredContactInfoSettingsModel = this.locatePreferredContactInfoSettingsService()
            .getPreferredContactInfoSettingsModel();

        // get all fields from Contact of type "Phone"
        Map<String, SObjectFieldModel> phoneTypeSObjectFieldModelsByFieldName = this.locateSObjectFieldService()
            .getModelsByTypeForSObject(Contact.SObjectType, 'PHONE');

        // exclude "Business Phone" field to preserve existing behavior (API name is Phone, label is Business Phone)
        phoneTypeSObjectFieldModelsByFieldName.remove('Phone');

        List<ComboboxValueVModel> preferredPhoneComboboxValueVModelsList = new List<ComboboxValueVModel>();

        // add --None-- option, maps to a blank value in hierarchy settings field
        preferredPhoneComboboxValueVModelsList.add(new ComboboxValueVModel(label.NoneOption, '""'));

        for (SObjectFieldModel phoneSObjectFieldModel : phoneTypeSObjectFieldModelsByFieldName.values()) {
            preferredPhoneComboboxValueVModelsList.add(
                // value for the combobox option should match the phone field label
                new ComboboxValueVModel(phoneSObjectFieldModel.label, phoneSObjectFieldModel.label)
            );
        }

        return new PreferredContactInfoSettingsVModel(
            preferredContactInfoSettingsModel.requirePreferredEmail,
            preferredContactInfoSettingsModel.enhancedPhoneFunctionality,
            preferredContactInfoSettingsModel.preferredPhoneEnforcement,
            new ComboboxVModel(
                preferredContactInfoSettingsModel.defaultPreferredPhone,
                preferredPhoneComboboxValueVModelsList
            )
        );
    }

    /******************************************************************************
     * @description Retrieve an instance of the PicklistEntryService class.
     * @return An instance of PicklistEntryService.
     ******************************************************************************/
    @TestVisible
    private PicklistEntryService locatePicklistEntryService() {
        return PicklistEntryService.getInstance();
    }

    /******************************************************************************
     * @description Retrieve an instance of the SObjectFieldService class.
     * @return An instance of SObjectFieldService.
     ******************************************************************************/
    @TestVisible
    private SObjectFieldService locateSObjectFieldService() {
        return SObjectFieldService.getInstance();
    }

    /******************************************************************************
     * @description Retrieve an instance of the ContactLanguageSettingsService class.
     * @return An instance of ContactLanguageSettingsService.
     ******************************************************************************/
    @TestVisible
    private ContactLanguageSettingsService locateContactLanguageSettingsService() {
        return ContactLanguageSettingsService.getInstance();
    }

    /******************************************************************************
     * @description Retrieve an instance of the PreferredContactInfoSettingsService class.
     * @return An instance of PreferredContactInfoSettingsService.
     ******************************************************************************/
    @TestVisible
    private PreferredContactInfoSettingsService locatePreferredContactInfoSettingsService() {
        return PreferredContactInfoSettingsService.getInstance();
    }
}
