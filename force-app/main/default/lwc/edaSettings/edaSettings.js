import { LightningElement, api } from 'lwc';
export default class EDASettings extends LightningElement {
    @api pageReference;
	LabelReference = {
        settingsNavigation: 'Navigation Pane Here',
        settingsPage: 'Settings Page Here'
    }
}
