import { LightningElement, api } from "lwc";

import stgRefreshHouseholdNamesModalBody from "@salesforce/label/c.stgRefreshHouseholdNamesModalBody";

export default class batchJobModalBody extends LightningElement {
    @api
    modalAction;
}
