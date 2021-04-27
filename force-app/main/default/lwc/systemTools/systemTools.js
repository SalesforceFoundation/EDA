import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import stgSystemToolsTitle from "@salesforce/label/c.stgSystemToolsTitle";
import stgBtnRefreshHouseholdNames from "@salesforce/label/c.stgBtnRefreshHouseholdNames";
import stgRefreshHHAcctNameTitle from "@salesforce/label/c.stgRefreshHHAcctNameTitle";
import stgRefreshHHAcctNameDesc from "@salesforce/label/c.stgRefreshHHAcctNameDesc";
import stgRefreshHouseholdNamesSuccessToast from "@salesforce/label/c.stgRefreshHouseholdNamesSuccessToast";
import BatchJobRunningProblem from "@salesforce/label/c.BatchJobRunningProblem";
import stgTellMeMoreLink from "@salesforce/label/c.stgTellMeMoreLink";

import runRefreshHouseholdAccountNamingJob from "@salesforce/apex/AccountNamingBatchController.runRefreshHouseholdAccountNamingJob";

export default class systemTools extends LightningElement {
    labelReference = {
        stgSystemToolsTitle: stgSystemToolsTitle,
        stgBtnRefreshHouseholdNames: stgBtnRefreshHouseholdNames,
        stgRefreshHHAcctNameTitle: stgRefreshHHAcctNameTitle,
        stgRefreshHHAcctNameDesc: stgRefreshHHAcctNameDesc,
        stgRefreshHouseholdNamesSuccessToast: stgRefreshHouseholdNamesSuccessToast,
        BatchJobRunningProblem: BatchJobRunningProblem,
        tellMeMoreLink: stgTellMeMoreLink,
    };

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

    showToast(toastType, toastTitle, toastMessage) {
        const showToastEvent = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastType,
            mode: "dismissable",
        });
        this.dispatchEvent(showToastEvent);
    }

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
}
