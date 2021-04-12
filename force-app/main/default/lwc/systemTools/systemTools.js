import { LightningElement, wire, track } from "lwc";
import { refreshApex } from "@salesforce/apex";

import stgSystemToolsTitle from "@salesforce/label/c.stgSystemToolsTitle";

export default class systemTools extends LightningElement {
    labelReference = {
        stgSystemToolsTitle: stgSystemToolsTitle,
    };
}
