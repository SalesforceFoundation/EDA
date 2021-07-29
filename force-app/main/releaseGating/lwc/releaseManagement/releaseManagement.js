import { LightningElement } from "lwc";
//Release Management Labels
import stgReleaseManagementTitle from "@salesforce/label/c.stgReleaseManagementTitle";

export default class EdcReleaseManagement extends LightningElement {
    labelReference = {
        releaseManagementTitle: stgReleaseManagementTitle,
    };
}
