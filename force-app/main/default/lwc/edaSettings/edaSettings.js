import { LightningElement, api, track } from "lwc";
export default class EDASettings extends LightningElement {
    @api pageReference;

    @track settingsPageToDisplay = {
        accountmodelsettings: true,
    };

    handleSettingsNavigation(event) {
        this.changePageToDisplay(event.detail.pageName);
        event.stopPropagation();
    }

    changePageToDisplay(pageName) {
        let settingsPageDisplay = {};
        settingsPageDisplay[pageName.toLowerCase()] = true;

        this.settingsPageToDisplay = settingsPageDisplay;

        this.template.querySelector("c-eda-settings-navigation").setActivePage(pageName);
    }
}
