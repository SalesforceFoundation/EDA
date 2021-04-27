import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// System Tools custom labels
import stgSystemToolsTitle from "@salesforce/label/c.stgSystemToolsTitle";

// Household Naming custom labels
import stgRefreshHHAcctNameTitle from "@salesforce/label/c.stgRefreshHHAcctNameTitle";
import stgRefreshHHAcctNameDesc from "@salesforce/label/c.stgRefreshHHAcctNameDesc";
import stgBtnRefreshHouseholdNames from "@salesforce/label/c.stgBtnRefreshHouseholdNames";
import stgRefreshHouseholdNamesSuccessToast from "@salesforce/label/c.stgRefreshHouseholdNamesSuccessToast";

// Administrative Naming custom labels
import stgRefreshAdminAcctNameTitle from "@salesforce/label/c.stgRefreshAdminAcctNameTitle";
import stgRefreshAdminAcctNameDesc from "@salesforce/label/c.stgRefreshAdminAcctNameDesc";
import stgBtnRefreshAdminNames from "@salesforce/label/c.stgBtnRefreshAdminNames";
import stgRefreshAdminNamesSuccessToast from "@salesforce/label/c.stgRefreshAdminNamesSuccessToast";

// BatchJob Naming custom labels
import BatchJobRunningProblem from "@salesforce/label/c.BatchJobRunningProblem";

// TellMeMore custom labels
import stgTellMeMoreLink from "@salesforce/label/c.stgTellMeMoreLink";

import runRefreshHouseholdAccountNamingJob from "@salesforce/apex/AccountNamingBatchController.runRefreshHouseholdAccountNamingJob";
import runRefreshAdministrativeAccountNamingJob from "@salesforce/apex/AccountNamingBatchController.runRefreshAdministrativeAccountNamingJob";

export default class systemTools extends LightningElement {
    labelReference = {
        stgSystemToolsTitle: stgSystemToolsTitle,
        stgBtnRefreshHouseholdNames: stgBtnRefreshHouseholdNames,
        stgRefreshHHAcctNameTitle: stgRefreshHHAcctNameTitle,
        stgRefreshHHAcctNameDesc: stgRefreshHHAcctNameDesc,
        stgRefreshHouseholdNamesSuccessToast: stgRefreshHouseholdNamesSuccessToast,
        stgRefreshAdminAcctNameTitle: stgRefreshAdminAcctNameTitle,
        stgRefreshAdminAcctNameDesc: stgRefreshAdminAcctNameDesc,
        stgBtnRefreshAdminNames: stgBtnRefreshAdminNames,
        stgRefreshAdminNamesSuccessToast: stgRefreshAdminNamesSuccessToast,
        BatchJobRunningProblem: BatchJobRunningProblem,
        tellMeMoreLink: stgTellMeMoreLink,
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
