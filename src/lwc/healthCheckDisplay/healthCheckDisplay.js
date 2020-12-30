import { LightningElement, api, track } from 'lwc';

import stgLoadingSpinnerText from '@salesforce/label/c.stgLoadingSpinnerText';

export default class HealthCheckDisplay extends LightningElement {
    @api healthCheckDefinitionsList;
    
    @track loadedHealthCheckDefCount = 0;
    @track displayHealthCheckGroup = false; 
    
    LabelReference = {
        spinnerLoadingAltText: stgLoadingSpinnerText
    }
    
    handleHealthCheckGroupLoaded(){
        this.loadedHealthCheckDefCount++;
       
        if (this.loadedHealthCheckDefCount == this.healthCheckDefinitionsList.length){
            this.displayHealthCheckGroup = true;
        } 
    }
}