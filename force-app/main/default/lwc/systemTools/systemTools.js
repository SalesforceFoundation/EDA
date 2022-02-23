import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// Controllers
import runRefreshHouseholdAccountNamingJob from "@salesforce/apex/AccountNamingBatchController.runRefreshHouseholdAccountNamingJob";
import runRefreshAdministrativeAccountNamingJob from "@salesforce/apex/AccountNamingBatchController.runRefreshAdministrativeAccountNamingJob";
import runEthnicityAndRaceBackfillJob from "@salesforce/apex/VersionCleanupBatchJobController.runEthnicityAndRaceBackfillJob";
import runCourseConnectionBackfillJob from "@salesforce/apex/VersionCleanupBatchJobController.runCourseConnectionBackfillJob";
import runCourseDescriptionCopyBatchJob from "@salesforce/apex/VersionCleanupBatchJobController.runCourseDescriptionCopyBatchJob";

// System Settings Labels
import stgSystemToolsNav from "@salesforce/label/c.stgSystemToolsNav";

// TellMeMore custom labels
import stgTellMeMoreLink from "@salesforce/label/c.stgTellMeMoreLink";

// BatchJob custom labels
import BatchJobRunningProblem from "@salesforce/label/c.BatchJobRunningProblem";

// Household Naming custom labels
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

// Preferred Email and Phone clean up Lables
import stgPreferredEmailDataCleanup from "@salesforce/label/c.stgPreferredEmailDataCleanup";
import stgRunCleanUpEnableFirstTime from "@salesforce/label/c.stgRunCleanUpEnableFirstTime";
import stgRunCleanUp from "@salesforce/label/c.stgRunCleanUp";
import stgRunCleanUpA11y from "@salesforce/label/c.stgRunCleanUpA11y";
import stgPreferredPhoneEmailSuccessToast from "@salesforce/label/c.stgPreferredPhoneEmailSuccessToast";
import runPreferredPhoneAndEmailCleanupJob from "@salesforce/apex/PreferredPhoneEmailBatchController.runPreferredPhoneAndEmailCleanupJob";

// Ethnicitity and RaceBackfill labels
import stgEthnicityRaceBackfillContacts from "@salesforce/label/c.stgEthnicityRaceBackfillContacts";
import stgHelpEthnicityRaceBackfill from "@salesforce/label/c.stgHelpEthnicityRaceBackfill";
import stgBtnUpdate from "@salesforce/label/c.stgBtnUpdate";
import stgEthnicityRaceBackfillSuccessToast from "@salesforce/label/c.stgEthnicityRaceBackfillSuccessToast";
import stgBtnRefreshEthnicityDataA11y from "@salesforce/label/c.stgBtnRefreshEthnicityDataA11y";

// Course Connection backfill labels
import stgTitleCourseConnectionBackfill from "@salesforce/label/c.stgTitleCourseConnectionBackfill";
import stgHelpCourseConnectionBackfill from "@salesforce/label/c.stgHelpCourseConnectionBackfill";
import stgBtnRunCourseConnBackfillA11y from "@salesforce/label/c.stgBtnRunCourseConnBackfillA11y";
import stgCourseConnBackFillSuccess from "@salesforce/label/c.stgCourseConnBackFillSuccess";

// Course Description Data Migration labels
import stgTitleCoursesDescriptionDataMigration from "@salesforce/label/c.stgTitleCoursesDescriptionDataMigration";
import stgHelpCoursesDataMigration from "@salesforce/label/c.stgHelpCoursesDataMigration";
import stgBtnRunCopy from "@salesforce/label/c.stgBtnRunCopy";
import stgBtnRunCopyA11y from "@salesforce/label/c.stgBtnRunCopyA11y";
import stgCourseDataMigrationModalTitle from "@salesforce/label/c.stgCourseDataMigrationModalTitle";
import stgCourseDataMigrationModalBody from "@salesforce/label/c.stgCourseDataMigrationModalBody";
import stgHelpCopyQueuedEmailSent from "@salesforce/label/c.stgHelpCopyQueuedEmailSent";

// Toast labels
import stgSuccess from "@salesforce/label/c.stgSuccess";
import stgToastError from "@salesforce/label/c.stgToastError";

// Links to the articles
const accountNamingArtcile = '<a href="https://powerofus.force.com/EDA-Customize-Admin-and-HH-Acct-Names">';
const prefEmailPhoneArticle = '<a href="https://powerofus.force.com/EDA-Configure-Email-Addresses-for-Contacts">';
const ethinicityAndRaceBackFillArticle = '<a href="https://powerofus.force.com/EDA-Contact">';
const courseConnArticle = '<a href="https://powerofus.force.com/EDA-Course-Connection">';

export default class systemTools extends LightningElement {
    labelReference = {
        stgSystemToolsTitle: stgSystemToolsNav,
        BatchJobRunningProblem: BatchJobRunningProblem,
        tellMeMoreLink: stgTellMeMoreLink,
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
        stgPreferredEmailDataCleanup: stgPreferredEmailDataCleanup,
        stgRunCleanUpEnableFirstTime: stgRunCleanUpEnableFirstTime,
        stgRunCleanUp: stgRunCleanUp,
        stgRunCleanUpA11y: stgRunCleanUpA11y,
        stgPreferredPhoneEmailSuccessToast: stgPreferredPhoneEmailSuccessToast,
        ethnicityAndRaceBackfillTitle: stgEthnicityRaceBackfillContacts,
        ethnicityAndRaceBackfillDescription: stgHelpEthnicityRaceBackfill,
        stgBtnUpdate: stgBtnUpdate,
        ethnicityAndRaceBackfillToast: stgEthnicityRaceBackfillSuccessToast,
        ethnicityAndRaceBackTitleA11y: stgBtnRefreshEthnicityDataA11y,
        courseConnectionBackfillTitle: stgTitleCourseConnectionBackfill,
        courseConnectionBackfillDesc: stgHelpCourseConnectionBackfill,
        courseConnBtnHelpTextForRunA11y: stgBtnRunCourseConnBackfillA11y,
        toastMessageForCourseConnBackFill: stgCourseConnBackFillSuccess,
        courseDescriptionMigrationTitle: stgTitleCoursesDescriptionDataMigration,
        courseDescriptionMigrationHelpText: stgHelpCoursesDataMigration,
        btnLabelForRun: stgBtnRunCopy,
        btnHelpTextForRunA11y: stgBtnRunCopyA11y,
        courseDataMigrationModalTitle: stgCourseDataMigrationModalTitle,
        courseDataMigrationModalBody: stgCourseDataMigrationModalBody,
        toastMessageForDataMigration: stgHelpCopyQueuedEmailSent,
        successToastMesage: stgSuccess,
        errorToastMessge: stgToastError,
    };

    get adminAndHouseholdNamesHyperLink() {
        return accountNamingArtcile + this.labelReference.tellMeMoreLink + "</a>";
    }

    get houseHoldNamesRefreshDesc() {
        return this.labelReference.stgRefreshHHAcctNameDesc + " " + this.adminAndHouseholdNamesHyperLink;
    }

    get adminNamesRefreshDesc() {
        return this.labelReference.stgRefreshAdminAcctNameDesc + " " + this.adminAndHouseholdNamesHyperLink;
    }

    get prefEmailPhoneHyperLink() {
        return prefEmailPhoneArticle + this.labelReference.tellMeMoreLink + "</a>";
    }

    get prefEmailPhoneDesc() {
        return this.labelReference.stgRunCleanUpEnableFirstTime + " " + this.prefEmailPhoneHyperLink;
    }

    get ethnicityAndBackFillHyperLink() {
        return ethinicityAndRaceBackFillArticle + this.labelReference.tellMeMoreLink + "</a>";
    }

    get ethnicityAndBackFillDesc() {
        return this.labelReference.ethnicityAndRaceBackfillDescription + " " + this.ethnicityAndBackFillHyperLink;
    }

    get courseConnBackfillHyperLink() {
        return courseConnArticle + this.labelReference.tellMeMoreLink + "</a>";
    }

    get courseConnBackfillDesc() {
        return this.labelReference.courseConnectionBackfillDesc + " " + this.courseConnBackfillHyperLink;
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

    handleEthnicityAndRaceBackfill(event) {
        const eventDetail = event.detail;
        const batchJobToRun = "CON_EthnicityRace_BATCH";
        this.dispatchSettingsBatchJobModalEvent(eventDetail, batchJobToRun);
    }

    handleCourseConnectionBackFill(event) {
        const eventDetail = event.detail;
        const batchJobToRun = "CCON_ConnectionBackfill_BATCH";
        this.dispatchSettingsBatchJobModalEvent(eventDetail, batchJobToRun);
    }

    handleCourseDataMigration(event) {
        const eventDetail = event.detail;
        const batchJobToRun = "COUR_DescriptionCopy_BATCH";
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
            case "CON_EthnicityRace_BATCH":
                this.runEthnicityAndRaceBackfillBatch();
                break;
            case "CCON_ConnectionBackfill_BATCH":
                this.runCourseConnectionBackFillBatch();
                break;
            case "COUR_DescriptionCopy_BATCH":
                this.runCourseDescriptionCopyBatch();
                break;
        }
    }

    runAdministrativeNamingRefreshBatch() {
        runRefreshAdministrativeAccountNamingJob()
            .then((result) => {
                this.showToast(
                    "success",
                    this.labelReference.successToastMesage,
                    this.labelReference.stgRefreshAdminNamesSuccessToast
                );
            })

            .catch((error) => {
                this.showToast(
                    "error",
                    this.labelReference.errorToastMessge,
                    this.labelReference.BatchJobRunningProblem
                );
            });
    }

    runCourseDescriptionCopyBatch() {
        runCourseDescriptionCopyBatchJob()
            .then((result) => {
                this.showToast(
                    "success",
                    this.labelReference.successToastMesage,
                    this.labelReference.toastMessageForDataMigration
                );
            })

            .catch((error) => {
                this.showToast(
                    "error",
                    this.labelReference.errorToastMessge,
                    this.labelReference.BatchJobRunningProblem
                );
            });
    }

    runHouseHoldNamingRefreshBatch() {
        runRefreshHouseholdAccountNamingJob()
            .then((result) => {
                this.showToast(
                    "success",
                    this.labelReference.successToastMesage,
                    this.labelReference.stgRefreshHouseholdNamesSuccessToast
                );
            })

            .catch((error) => {
                this.showToast(
                    "error",
                    this.labelReference.errorToastMessge,
                    this.labelReference.BatchJobRunningProblem
                );
            });
    }

    runPreferredEmailPhoneCleanUpBatch() {
        runPreferredPhoneAndEmailCleanupJob()
            .then((result) => {
                this.showToast(
                    "success",
                    this.labelReference.successToastMesage,
                    this.labelReference.stgPreferredPhoneEmailSuccessToast
                );
            })

            .catch((error) => {
                this.showToast(
                    "error",
                    this.labelReference.errorToastMessge,
                    this.labelReference.BatchJobRunningProblem
                );
            });
    }

    runEthnicityAndRaceBackfillBatch() {
        runEthnicityAndRaceBackfillJob()
            .then((result) => {
                this.showToast(
                    "success",
                    this.labelReference.successToastMesage,
                    this.labelReference.ethnicityAndRaceBackfillToast
                );
            })

            .catch((error) => {
                this.showToast(
                    "error",
                    this.labelReference.errorToastMessge,
                    this.labelReference.BatchJobRunningProblem
                );
            });
    }

    runCourseConnectionBackFillBatch() {
        runCourseConnectionBackfillJob()
            .then((result) => {
                this.showToast(
                    "success",
                    this.labelReference.successToastMesage,
                    this.labelReference.toastMessageForCourseConnBackFill
                );
            })

            .catch((error) => {
                this.showToast(
                    "error",
                    this.labelReference.errorToastMessge,
                    this.labelReference.BatchJobRunningProblem
                );
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
