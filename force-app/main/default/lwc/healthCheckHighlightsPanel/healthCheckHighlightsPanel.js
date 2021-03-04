import { LightningElement } from 'lwc';

// import custom labels
import stgEDASetupTitle from '@salesforce/label/c.stgEDASetupTitle';
import stgHealthCheckTitle from '@salesforce/label/c.stgHealthCheckTitle';

export default class HealthCheckHighlightsPanel extends LightningElement {
    labelReference = {
        stgEDASetupTitle, 
        stgHealthCheckTitle    
    }
}