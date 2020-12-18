import { LightningElement, track, wire } from 'lwc';

import getHealthCheckViewModel from '@salesforce/apex/HealthCheckController.getHealthCheckViewModel';
import updateHealthCheckLastRunDate from '@salesforce/apex/HealthCheckController.updateHealthCheckLastRunDate';

export default class HealthCheck extends LightningElement {
    @track expanded = true;
    @track totalChecks = 0;
    @track passedChecks = 0;
    @track lastRunDate = '';

    handleHealthCheckRun() {
        updateHealthCheckLastRunDate()
        .then(result => {
            this.lastRunDate = result;
        })
    }

    @wire(getHealthCheckViewModel) healthCheckViewModel;

}