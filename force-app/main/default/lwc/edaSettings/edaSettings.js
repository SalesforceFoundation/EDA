import { LightningElement, api } from "lwc";
export default class EDASettings extends LightningElement {
    @api pageReference;

    labelReference = {
        settingsNavigation: "Navigation Pane Here",
    };

    settingsPageToDisplay = {
        accountModelSettings: true,
    };

    handleSettingsNavigation(event) {
        this.changePageToDisplay(event.detail.pageName);
    }

    changePageToDisplay(pageName) {
        let settingsPageDisplay = {};
        settingsPageDisplay[pageName.toLowerCase()] = true;

        this.settingsPageToDisplay = settingsPageDisplay;
    }
}
