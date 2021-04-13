import { LightningElement, wire, track } from "lwc";
import { refreshApex } from "@salesforce/apex";

import stgSystemToolsTitle from "@salesforce/label/c.stgSystemToolsTitle";
import stgBtnRefreshHouseholdNames from "@salesforce/label/c.stgBtnRefreshHouseholdNames";
import stgRefreshHHAcctNameTitle from "@salesforce/label/c.stgRefreshHHAcctNameTitle";
import stgRefreshHHAcctNameDesc from "@salesforce/label/c.stgRefreshHHAcctNameDesc";

export default class systemTools extends LightningElement {
    labelReference = {
        stgSystemToolsTitle: stgSystemToolsTitle,
        stgBtnRefreshHouseholdNames: stgBtnRefreshHouseholdNames,
        stgRefreshHHAcctNameTitle: stgRefreshHHAcctNameTitle,
        stgRefreshHHAcctNameDesc: stgRefreshHHAcctNameDesc,
    };

    handleRefreshHHNamesBtnClick(event) {
        const eventDetail = event.detail;
        this.dispatchSettingsBatchJobModalEvent(eventDetail);
    }

    dispatchSettingsBatchJobModalEvent(eventDetail) {
        this.dispatchEvent(
            new CustomEvent("settingsbatchjobmodalrequestevent", {
                detail: event.detail,
                bubbles: true,
                composed: true,
            })
        );
    }
}
