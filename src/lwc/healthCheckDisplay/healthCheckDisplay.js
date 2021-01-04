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

    @api refreshHealthCheck() {
        this.loadedHealthCheckDefCount = 0;
        this.displayHealthCheckGroup = false;

        let healthCheckGroups = this.template.querySelectorAll('c-health-check-group');

        healthCheckGroups.forEach(element => {
            element.refreshHealthCheckGroup();
        });
    }
}