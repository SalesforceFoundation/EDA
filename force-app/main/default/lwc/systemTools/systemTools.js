import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import stgSystemToolsNav from "@salesforce/label/c.stgSystemToolsNav";
import stgBtnRefreshHouseholdNames from "@salesforce/label/c.stgBtnRefreshHouseholdNames";
import stgBtnRefreshHouseholdNamesA11y from "@salesforce/label/c.stgBtnRefreshHouseholdNamesA11y";
import stgRefreshHHAcctNameTitle from "@salesforce/label/c.stgRefreshHHAcctNameTitle";
import stgRefreshHHAcctNameDesc from "@salesforce/label/c.stgRefreshHHAcctNameDesc";
import stgRefreshHouseholdNamesSuccessToast from "@salesforce/label/c.stgRefreshHouseholdNamesSuccessToast";

// Administrative Naming custom labels
import stgRefreshAdminAcctNameTitle from "@salesforce/label/c.stgRefreshAdminAcctNameTitle";
import stgRefreshAdminAcctNameDesc from "@salesforce/label/c.stgRefreshAdminAcctNameDesc";
import stgBtnRefreshAdminNames from "@salesforce/label/c.stgBtnRefreshAdminNames";
import stgBtnRefreshAdminNamesA11y from "@salesforce/label/c.stgBtnRefreshAdminNamesA11y";
import stgRefreshAdminNamesSuccessToast from "@salesforce/label/c.stgRefreshAdminNamesSuccessToast";

// BatchJob Naming custom labels
import BatchJobRunningProblem from "@salesforce/label/c.BatchJobRunningProblem";

// TellMeMore custom labels
import stgTellMeMoreLink from "@salesforce/label/c.stgTellMeMoreLink";

// Preferred Email and Phone clean up Lables
import stgPreferredEmailDataCleanup from "@salesforce/label/c.stgPreferredEmailDataCleanup";
import stgRunCleanUpEnableFirstTime from "@salesforce/label/c.stgRunCleanUpEnableFirstTime";
import stgRunCleanUp from "@salesforce/label/c.stgRunCleanUp";
import stgPreferredPhoneEmailSuccessToast from "@salesforce/label/c.stgPreferredPhoneEmailSuccessToast";

import runRefreshHouseholdAccountNamingJob from "@salesforce/apex/AccountNamingBatchController.runRefreshHouseholdAccountNamingJob";
import runRefreshAdministrativeAccountNamingJob from "@salesforce/apex/AccountNamingBatchController.runRefreshAdministrativeAccountNamingJob";
import runPreferredPhoneAndEmailCleanupJob from "@salesforce/apex/PreferredPhoneEmailBatchController.runPreferredPhoneAndEmailCleanupJob";

export default class systemTools extends LightningElement {
    labelReference = {
        stgSystemToolsTitle: stgSystemToolsNav,
        stgBtnRefreshHouseholdNames: stgBtnRefreshHouseholdNames,
        stgBtnRefreshHouseholdNamesA11y: stgBtnRefreshHouseholdNamesA11y,
        stgRefreshHHAcctNameTitle: stgRefreshHHAcctNameTitle,
        stgRefreshHHAcctNameDesc: stgRefreshHHAcctNameDesc,
        stgRefreshHouseholdNamesSuccessToast: stgRefreshHouseholdNamesSuccessToast,
        stgRefreshAdminAcctNameTitle: stgRefreshAdminAcctNameTitle,
        stgRefreshAdminAcctNameDesc: stgRefreshAdminAcctNameDesc,
        stgBtnRefreshAdminNames: stgBtnRefreshAdminNames,
        stgBtnRefreshAdminNamesA11y: stgBtnRefreshAdminNamesA11y,
        stgRefreshAdminNamesSuccessToast: stgRefreshAdminNamesSuccessToast,
        BatchJobRunningProblem: BatchJobRunningProblem,
        tellMeMoreLink: stgTellMeMoreLink,
        stgPreferredEmailDataCleanup: stgPreferredEmailDataCleanup,
        stgRunCleanUpEnableFirstTime: stgRunCleanUpEnableFirstTime,
        stgRunCleanUp: stgRunCleanUp,
        stgPreferredPhoneEmailSuccessToast: stgPreferredPhoneEmailSuccessToast,
    };

    get adminAndHouseholdNamesHyperLink() {
        return (
            '<a href="https://powerofus.force.com/s/article/EDA-Customize-Admin-and-HH-Acct-Names">' +
            this.labelReference.tellMeMoreLink +
            "</a>"
        );
    }

    get houseHoldNamesRefreshDesc() {
        return this.labelReference.stgRefreshHHAcctNameDesc + " " + this.adminAndHouseholdNamesHyperLink;
    }

    get adminNamesRefreshDesc() {
        return this.labelReference.stgRefreshAdminAcctNameDesc + " " + this.adminAndHouseholdNamesHyperLink;
    }

    get prefEmailPhoneHyperLink() {
        return (
            '<a href="https://powerofus.force.com/s/article/EDA-Configure-Email-Addresses-for-Contacts">' +
            this.labelReference.tellMeMoreLink +
            "</a>"
        );
    }

    get prefEmailPhoneDesc() {
        return this.labelReference.stgRunCleanUpEnableFirstTime + " " + this.prefEmailPhoneHyperLink;
    }

    hasRendered;

    renderedCallback() {
        if (this.hasRendered) {
            return;
        }

        this.hasRendered = true;
        this.setPageFocus();
    }

    setPageFocus() {
        this.template.querySelector(".eda-system-tools-title").focus();
    }

    @api
    handleSaveCanvasRender() {
        this.setPageFocus();
    }

    handleRefreshAdminNamesBtnClick(event) {
        const eventDetail = event.detail;
        const batchJobToRun = "ACCT_AdministrativeNameRefresh_BATCH";
        this.dispatchSettingsBatchJobModalEvent(eventDetail, batchJobToRun);
    }

    handleRefreshHHNamesBtnClick(event) {
        const eventDetail = event.detail;
        const batchJobToRun = "ACCT_HouseholdNameRefresh_BATCH";
        this.dispatchSettingsBatchJobModalEvent(eventDetail, batchJobToRun);
    }

    handlePrefEmailPhoneCleanUp(event) {
        const eventDetail = event.detail;
        const batchJobToRun = "CON_EMAIL_BATCH";
        this.dispatchSettingsBatchJobModalEvent(eventDetail, batchJobToRun);
    }

    dispatchSettingsBatchJobModalEvent(eventDetail, batchJobToRun) {
        const settingsBatchJobDetail = {
            eventDetail: eventDetail,
            batchJobToRun: batchJobToRun,
        };
        this.dispatchEvent(
            new CustomEvent("settingsbatchjobmodalrequest", {
                detail: settingsBatchJobDetail,
                bubbles: true,
                composed: true,
            })
        );
    }

    @api modalConfirm(saveModel) {
        switch (saveModel.batchJobToRun) {
            case "ACCT_AdministrativeNameRefresh_BATCH":
                this.runAdministrativeNamingRefreshBatch();
                break;
            case "ACCT_HouseholdNameRefresh_BATCH":
                this.runHouseHoldNamingRefreshBatch();
                break;
            case "CON_EMAIL_BATCH":
                this.runPreferredEmailPhoneCleanUpBatch();
                break;
        }
    }

    runAdministrativeNamingRefreshBatch() {
        runRefreshAdministrativeAccountNamingJob()
            .then((result) => {
                this.showToast("success", "Success", this.labelReference.stgRefreshAdminNamesSuccessToast);
            })

            .catch((error) => {
                this.showToast("error", "Error", this.labelReference.BatchJobRunningProblem);
            });
    }

    runHouseHoldNamingRefreshBatch() {
        runRefreshHouseholdAccountNamingJob()
            .then((result) => {
                this.showToast("success", "Success", this.labelReference.stgRefreshHouseholdNamesSuccessToast);
            })

            .catch((error) => {
                this.showToast("error", "Error", this.labelReference.BatchJobRunningProblem);
            });
    }

    runPreferredEmailPhoneCleanUpBatch() {
        runPreferredPhoneAndEmailCleanupJob()
            .then((result) => {
                this.showToast("success", "Success", this.labelReference.stgPreferredPhoneEmailSuccessToast);
            })

            .catch((error) => {
                this.showToast("error", "Error", this.labelReference.BatchJobRunningProblem);
            });
    }

    showToast(toastType, toastTitle, toastMessage) {
        const showToastEvent = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastType,
            mode: "dismissable",
        });
        this.dispatchEvent(showToastEvent);
    }
}
