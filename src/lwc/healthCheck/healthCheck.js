import { LightningElement, track, wire } from 'lwc';

//import getViewModel from '@salesforce/apex/HealthCheckController.getViewModel';

export default class HealthCheck extends LightningElement {
    @track expanded = true;
    @track totalChecks = 0;
    @track passedChecks = 0;
    @track lastRunDate = '';

    handleHealthCheckRun(){
        this.lastRunDate = new Date().toLocaleDateString("en-US");
        console.log('Health Check complete!');
    }

    // @wire(getViewModel)
    // healthCheckViewModel({error, data}){
    //     console.log('Wiring view model');
    // }
}