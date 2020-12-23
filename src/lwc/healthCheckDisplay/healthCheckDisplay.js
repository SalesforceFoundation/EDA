import { LightningElement, api, track } from 'lwc';

export default class HealthCheckDisplay extends LightningElement {
    //@track isDisplayHealthCheckLWC = false;
    @track isDisplayHealthCheckLWC = true;
    @api healthCheckDefinitionsList = [];
    
    @track loadedHealthCheckDefCount = 0;
    @track healthCheckGroupModelsList;  // list of health check group models
    @track isDisplayHealthCheckGroup = false; // determines whether to show a healthcheckgroup card

    handleHealthCheckGroupLoaded(){
        console.log('Health Check Group loaded!');
        this.loadedHealthCheckDefCount++;
        this.isDisplayHealthCheckGroup = true;

        if (this.loadedHealthCheckDefCount == this.healthCheckDefinitionsList.length){
            this.isDisplayHealthCheckLWC = true;
        }
    }
}