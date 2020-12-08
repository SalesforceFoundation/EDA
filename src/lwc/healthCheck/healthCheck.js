import { LightningElement, track, wire } from 'lwc';

import getHealthCheckViewModel from '@salesforce/apex/HealthCheckController.getHealthCheckViewModel';

export default class HealthCheck extends LightningElement {
    @track expanded = true;
    @track totalChecks = 0;
    @track passedChecks = 0;
    @track lastRunDate = '';

    handleHealthCheckRun(){
        this.lastRunDate = new Date().toLocaleDateString("en-US");
        console.log('Health Check complete!');
    }

    @wire(getHealthCheckViewModel)
    healthCheckViewModel({error, data}){
        console.log('Wiring view model');
    }
}