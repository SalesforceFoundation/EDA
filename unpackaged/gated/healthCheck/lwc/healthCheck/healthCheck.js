import { LightningElement, track, wire } from 'lwc';

import getHealthCheckViewModel from '@salesforce/apex/HealthCheckController.getHealthCheckViewModel';
import updateHealthCheckLastRunDate from '@salesforce/apex/HealthCheckController.updateHealthCheckLastRunDate';

export default class HealthCheck extends LightningElement {
    @track expanded = true;
    @track totalChecks = 0;
    @track passedChecks = 0;
    @track lastRunDate = '';
    @track displayHealthCheck = false;

    handleHealthCheckRun(){
        updateHealthCheckLastRunDate()
            .then(result => {
                console.log('result', result);
                this.lastRunDate = result;
                this.displayHealthCheck = true;
            })
            .catch(error => {
                console.log('error updating last run date');
            })
    }

    @wire(getHealthCheckViewModel)
    healthCheckViewModel({error, data}){
        if (data){
            this.lastRunDate = data.lastRunDate;
        } else if(error){
            console.log('error retrieving health check view model');
        }
    }
}