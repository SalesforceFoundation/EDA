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
        let settingsPageDisplay = {};
        settingsPageDisplay[pageName.toLowerCase()] = true;
        
        settingsPageToDisplay = settingsPageDisplay;
    }
}
