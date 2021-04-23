import { LightningElement, api } from "lwc";
//custom labels
import stgBtnAddMapping from "@salesforce/label/c.stgBtnAddMapping";

export default class EdaSettingsTable extends LightningElement {
    @api tabletitle;
    @api tabledescription;
    @api tabledata;
    @api tablecolumns;

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
