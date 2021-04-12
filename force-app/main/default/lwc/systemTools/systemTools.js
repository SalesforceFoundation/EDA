import { LightningElement, wire, track } from "lwc";
import { refreshApex } from "@salesforce/apex";

import stgSystemToolsTitle from "@salesforce/label/c.stgSystemToolsTitle";

export default class systemTools extends LightningElement {
    labelReference = {
        stgSystemToolsTitle: stgSystemToolsTitle,
    };

    // handleRefreshAdministrativeAccountNamesClick(event) {
    //     const eventDetail = event.detail;
    //     this.dispatchSettingsModalEvent(eventDetail);
    // }

    // dispatchSettingsModalEvent(eventDetail) {
    //     this.dispatchEvent(
    //         new CustomEvent("settingsmodalevent", {
    //             detail: event.detail,
    //             bubbles: true,
    //             composed: true,
    //         })
    //     );
    // }
}
