import { LightningElement } from 'lwc';

// import custom labels
import stgEDASetup from '@salesforce/label/c.stgEDASetup';
import stgSettingsHealthCheckTitle from '@salesforce/label/c.stgSettingsHealthCheckTitle';

export default class HealthCheckHighlightsPanel extends LightningElement {
    labelReference = {
        stgEDASetup, 
        stgSettingsHealthCheckTitle    
    }
}