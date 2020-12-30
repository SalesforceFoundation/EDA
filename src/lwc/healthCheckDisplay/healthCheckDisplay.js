import { LightningElement, api, track } from 'lwc';

export default class HealthCheckDisplay extends LightningElement {
    @api healthCheckDefinitionsList;
    
    @track loadedHealthCheckDefCount = 0;
    @track isDisplayHealthCheckGroup = false; // determines whether a healthcheckgroup card is displayed

    LabelReference = {
        spinnerLoadingAltText: 'Loading...'
    }
    
    handleHealthCheckGroupLoaded(){
        this.loadedHealthCheckDefCount++;
       
        if (this.loadedHealthCheckDefCount == this.healthCheckDefinitionsList.length){
            this.isDisplayHealthCheckGroup = true;
        } 
    }
}