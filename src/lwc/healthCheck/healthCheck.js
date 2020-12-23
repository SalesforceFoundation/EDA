import { LightningElement, track, wire } from 'lwc';

import getHealthCheckViewModel from '@salesforce/apex/HealthCheckController.getHealthCheckViewModel';
import updateHealthCheckLastRunDate from '@salesforce/apex/HealthCheckController.updateHealthCheckLastRunDate';

export default class HealthCheck extends LightningElement {
    @track expanded = true;
    @track totalChecks = 0;
    @track passedChecks = 0;
    @track lastRunDate = '';

    @track healthCheckDefinitionsToDisplayList = [];

    handleHealthCheckRun(){
        console.log('handling health check run');
        updateHealthCheckLastRunDate()
            .then(result => {
                this.lastRunDate = result;
            })
            .catch(error => {
                console.log('error updating last run date: ', error);
            });
    }

    @wire(getHealthCheckViewModel)
    healthCheckViewModel({error, data}){
        if (data){
            this.lastRunDate = data.lastRunDate;                
            this.healthCheckDefinitionsToDisplayList = data.healthCheckDefinitionList;  
        } else if (error){
            console.log('error retrieving health check view model');
        }
    }

}