import { LightningElement, api } from 'lwc';
export default class EDASettings extends LightningElement {
    @api pageReference;

    labelReference = {
        settingsNavigation: 'Navigation Pane Here',
        settingsPage: 'Settings Page Here'
    }

    settingsPageToDisplay = {
        accountModelSettings: true
    };

    changePageToDisplay(pageName) {
        for (let settingPageName in this.settingsPageToDisplay) {
            if (settingPageName.toLocaleLowerCase() === pageName.toLocaleLowerCase()) {
                this.settingsPageToDisplay[settingPageName] = true;
            } else {
                this.settingsPageToDisplay[settingPageName] = false;
            }
        }
    }
}
