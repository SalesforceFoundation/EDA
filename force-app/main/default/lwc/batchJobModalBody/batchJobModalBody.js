import { LightningElement, api, track, wire } from "lwc";

import stgRefreshHouseholdNamesModalBody from "@salesforce/label/c.stgRefreshHouseholdNamesModalBody";

export default class batchJobModalBody extends LightningElement {
    labelReference = {
        stgRefreshHouseholdNamesModalBody: stgRefreshHouseholdNamesModalBody,
    };
}
