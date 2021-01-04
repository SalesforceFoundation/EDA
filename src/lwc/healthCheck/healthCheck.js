import { LightningElement, track, wire } from 'lwc';

import stgHealthCheckErrorLastRunDate from '@salesforce/label/c.stgHealthCheckErrorLastRunDate';

import getHealthCheckViewModel from '@salesforce/apex/HealthCheckController.getHealthCheckViewModel';
import updateHealthCheckLastRunDate from '@salesforce/apex/HealthCheckController.updateHealthCheckLastRunDate';

export default class HealthCheck extends LightningElement {
    @track expanded = true;
    @track totalChecks = 0;
    @track passedChecks = 0;
    @track lastRunDate = '';
    @track displayHealthCheckGroup = false;

    @track healthCheckDefinitionsToDisplayList = [];

    LabelReference = {
        stgHealthCheckErrorLastRunDate
    }

    handleHealthCheckRun(){
        updateHealthCheckLastRunDate()
            .then(result => {
                this.lastRunDate = result;

                if(!this.displayHealthCheckGroup) {
                    this.displayHealthCheckGroup = true;
                    return;
                }

                let healthCheckDisplay = this.template.querySelector('c-health-check-display');
                healthCheckDisplay.refreshHealthCheck();
            })
            .catch(error => {
                this.lastRunDate = this.LabelReference.stgHealthCheckErrorLastRunDate;
            });
    }

    @wire(getHealthCheckViewModel)
    healthCheckViewModel({error, data}){
        if (data){
            this.lastRunDate = data.lastRunDate;                
            this.healthCheckDefinitionsToDisplayList = data.healthCheckDefinitionList;  
        } else if (error){
            //console.log('error retrieving health check view model: ', error);
        }
    }

    get displayHealthCheck(){
        return !(!this.displayHealthCheckGroup || !this.healthCheckDefinitionsToDisplayList);
    }

}
