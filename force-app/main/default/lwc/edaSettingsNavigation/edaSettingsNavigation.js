import { LightningElement, api, track } from "lwc";
import stgAccountModelSettingsTitle from "@salesforce/label/c.stgAccountModelSettingsTitle";
import stgAccModelTitle from "@salesforce/label/c.stgAccModelTitle";
import stgAdminAccountRecordType from "@salesforce/label/c.stgAdminAccountRecordType";
import stgAccountRecordTypeSupportsHHAddress from "@salesforce/label/c.stgAccountRecordTypeSupportsHHAddress";
import stgAccoutTypesWithoutContactsDelete from "@salesforce/label/c.stgAccoutTypesWithoutContactsDelete";

import stgContactInformationSettingsTitle from "@salesforce/label/c.stgContactInformationSettingsTitle";
import stgDefaultContactLanguageFluency from "@salesforce/label/c.stgDefaultContactLanguageFluency";
import stgDisablePreferredEmailEnforcement from "@salesforce/label/c.stgDisablePreferredEmailEnforcement";
import stgEnablePreferredPhoneSync from "@salesforce/label/c.stgEnablePreferredPhoneSync";
import stgPreferredPhoneDefault from "@salesforce/label/c.stgPreferredPhoneDefault";

import stgAccountTypesMultiAddressesEnabled from "@salesforce/label/c.stgAccountTypesMultiAddressesEnabled";
import stgAddressSettingsTitle from "@salesforce/label/c.stgAddressSettingsTitle";
import stgContactMultiAddressesEnabled from "@salesforce/label/c.stgContactMultiAddressesEnabled";
import stgHealthCheckLoadingIndicator from "@salesforce/label/c.stgHealthCheckLoadingIndicator";
import stgSimpleAddressChangeUpdate from "@salesforce/label/c.stgSimpleAddressChangeUpdate";
import stgTabAfflMappings from "@salesforce/label/c.stgTabAfflMappings";

import stgAffiliationsSettingsNav from "@salesforce/label/c.stgAffiliationsSettingsNav";
import afflTypeEnforced from "@salesforce/label/c.afflTypeEnforced";

export default class EdaSettingsNavigation extends LightningElement {
    labelReference = {
        spinnerLoadingAltText: stgHealthCheckLoadingIndicator,
        accountModel: {
            accountAutoDeletionModel: stgAccoutTypesWithoutContactsDelete,
            accountModelSettings: stgAccountModelSettingsTitle,
            adminAccountModel: stgAdminAccountRecordType,
            defaultAccountModel: stgAccModelTitle,
            hhAccountModel: stgAccountRecordTypeSupportsHHAddress,
        },
        contactInformation: {
            contactInformation: stgContactInformationSettingsTitle,
            defaultContactLanguageFluency: stgDefaultContactLanguageFluency,
            defaultPreferredPhone: stgPreferredPhoneDefault,
            enhancedPhoneFunctionality: stgEnablePreferredPhoneSync,
            requirePreferredEmail: stgDisablePreferredEmailEnforcement,
        },
        addressSettings: {
            addressAccountRecordTypes: stgAccountTypesMultiAddressesEnabled,
            addressSettings: stgAddressSettingsTitle,
            contactMultipleAddresses: stgContactMultiAddressesEnabled,
            simpleAddressChangeIsUpdate: stgSimpleAddressChangeUpdate,
        },
        affiliationSettings: {
            affiliationMappings: stgTabAfflMappings,
            affiliationSettings: stgAffiliationsSettingsNav,
            enforceRecordTypeValidation: afflTypeEnforced,
        },
    };

    @api activePage;

    @track viewModel = {
        navigationSections: [
            {
                label: "Setup Home",
                page: "setuphome",
                id: "setuphome",
            },
            {
                label: "People and Groups",
                id: "peopleAndGroups",
                navigationSubSections: [
                    {
                        label: this.labelReference.accountModel.accountModelSettings,
                        page: "accountModelSettings",
                        id: "accountModelSettings",
                        menuItems: [
                            { label: this.labelReference.accountModel.defaultAccountModel, id: "defaultAccountModel" },
                            {
                                label: this.labelReference.accountModel.adminAccountModel,
                                id: "adminAccountModel",
                            },
                            { label: this.labelReference.accountModel.hhAccountModel, id: "hhAccountModel" },
                            {
                                label: this.labelReference.accountModel.accountAutoDeletionModel,
                                id: "accountAutoDeletionModel",
                            },
                            { label: "Administrative Account Naming", id: "administrativeAccountNaming" },
                            { label: "Household Account Naming", id: "householdAccountNaming" },
                            { label: "Rename Household Accounts", id: "renameHouseholdAccounts" },
                        ],
                        isActive: true,
                    },
                    {
                        label: this.labelReference.contactInformation.contactInformation,
                        page: "contactInformationSettings",
                        id: "contactInformation",
                        menuItems: [
                            {
                                label: this.labelReference.contactInformation.defaultContactLanguageFluency,
                                id: "defaultContactLanguageFluency",
                            },
                            {
                                label: this.labelReference.contactInformation.requirePreferredEmail,
                                id: "requirePreferredEmail",
                            },
                            {
                                label: this.labelReference.contactInformation.enhancedPhoneFunctionality,
                                id: "enhancedPhoneFunctionality",
                            },
                            {
                                label: this.labelReference.contactInformation.defaultPreferredPhone,
                                id: "defaultPreferredPhone",
                            },
                        ],
                    },
                    {
                        label: this.labelReference.addressSettings.addressSettings,
                        page: "addressSettings",
                        id: "addresses",
                        menuItems: [
                            {
                                label: this.labelReference.addressSettings.contactMultipleAddresses,
                                id: "contactMultipleAddresses",
                            },
                            {
                                label: this.labelReference.addressSettings.simpleAddressChangeIsUpdate,
                                id: "addressAccountRecordTypes",
                            },
                            {
                                label: this.labelReference.addressSettings.addressAccountRecordTypes,
                                id: "simpleAddressChangeIsUpdate",
                            },
                        ],
                    },
                ],
            },
            {
                label: this.labelReference.affiliationSettings.affiliationSettings,
                page: "affiliationSettings",
                id: "affiliations",
                menuItems: [
                    {
                        label: this.labelReference.affiliationSettings.affiliationMappings,
                        id: "enforceRecordTypeValidation",
                    },
                    {
                        label: this.labelReference.affiliationSettings.enforceRecordTypeValidation,
                        id: "affiliationMappings",
                    },
                ],
            },
            {
                label: "Courses and Enrollments",
                id: "coursesAndEnrollments",
            },
            {
                label: "System Tools",
                id: "systemTools",
            },
        ],
    };
}
