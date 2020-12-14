import { LightningElement, track, wire } from 'lwc';

import getHealthCheckViewModel from '@salesforce/apex/HealthCheckController.getHealthCheckViewModel';

export default class HealthCheck extends LightningElement {
    @track expanded = true;
    @track totalChecks = 0;
    @track passedChecks = 0;
    @track lastRunDate = '';

    handleHealthCheckRun(){
        var currentDate = new Date();
        this.lastRunDate = currentDate.toLocaleDateString() + ' ' + currentDate.toLocaleTimeString();
    }

    @wire(getHealthCheckViewModel)
    healthCheckViewModel({error, data}){
        if (data){
            this.lastRunDate = data.lastRunDate;
        } else if(error){

        }
    }
}