import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import stgSystemToolsNav from "@salesforce/label/c.stgSystemToolsNav";
import stgBtnRefreshHouseholdNames from "@salesforce/label/c.stgBtnRefreshHouseholdNames";
import stgRefreshHHAcctNameTitle from "@salesforce/label/c.stgRefreshHHAcctNameTitle";
import stgRefreshHHAcctNameDesc from "@salesforce/label/c.stgRefreshHHAcctNameDesc";
import stgRefreshHouseholdNamesSuccessToast from "@salesforce/label/c.stgRefreshHouseholdNamesSuccessToast";
import BatchJobRunningProblem from "@salesforce/label/c.BatchJobRunningProblem";
import stgTellMeMoreLink from "@salesforce/label/c.stgTellMeMoreLink";

// Preferred Email and Phone clean up Lables
import stgPreferredEmailDataCleanup from "@salesforce/label/c.stgPreferredEmailDataCleanup";
import stgRunCleanUpEnableFirstTime from "@salesforce/label/c.stgRunCleanUpEnableFirstTime";
import stgRunCleanUp from "@salesforce/label/c.stgRunCleanUp";
import stgPreferredPhoneEmailSuccessToast from "@salesforce/label/c.stgPreferredPhoneEmailSuccessToast";

import runRefreshHouseholdAccountNamingJob from "@salesforce/apex/AccountNamingBatchController.runRefreshHouseholdAccountNamingJob";
import runPreferredPhoneAndEmailCleanupJob from "@salesforce/apex/PreferredPhoneEmailBatchController.runPreferredPhoneAndEmailCleanupJob";

export default class systemTools extends LightningElement {
    labelReference = {
        stgSystemToolsTitle: stgSystemToolsNav,
        stgBtnRefreshHouseholdNames: stgBtnRefreshHouseholdNames,
        stgRefreshHHAcctNameTitle: stgRefreshHHAcctNameTitle,
        stgRefreshHHAcctNameDesc: stgRefreshHHAcctNameDesc,
        stgRefreshHouseholdNamesSuccessToast: stgRefreshHouseholdNamesSuccessToast,
        BatchJobRunningProblem: BatchJobRunningProblem,
        tellMeMoreLink: stgTellMeMoreLink,
        stgPreferredEmailDataCleanup: stgPreferredEmailDataCleanup,
        stgRunCleanUpEnableFirstTime: stgRunCleanUpEnableFirstTime,
        stgRunCleanUp: stgRunCleanUp,
        stgPreferredPhoneEmailSuccessToast: stgPreferredPhoneEmailSuccessToast,
    };

    get houseHoldNamesHyperLink() {
        return (
            '<a href="https://powerofus.force.com/s/article/EDA-Customize-Admin-and-HH-Acct-Names">' +
            this.labelReference.tellMeMoreLink +
            "</a>"
        );
    }

    get houseHoldNamesRefreshDesc() {
        return this.labelReference.stgRefreshHHAcctNameDesc + " " + this.houseHoldNamesHyperLink;
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
            case "ACCT_HouseholdNameRefresh_BATCH":
                this.runHouseHoldNamingRefreshBatch();
                break;
            case "CON_EMAIL_BATCH":
                this.runPreferredEmailPhoneCleanUpBatch();
                break;
        }
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
