import { LightningElement, api } from "lwc";
//custom labels
import stgBtnAddMapping from "@salesforce/label/c.stgBtnAddMapping";

export default class EdaSettingsTable extends LightningElement {
    @api tableTitle;
    @api tableDescription;

    labelReference = {
        newButtonLabel: stgBtnAddMapping,
    };

    handleNewRowClick(event) {
        console.log("handleNewRowClick");
    }

    handleRowAction(event) {
        console.log("handleRowAction");
    }
}
