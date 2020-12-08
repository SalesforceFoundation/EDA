import { LightningElement, track, wire } from 'lwc';

export default class HealthCheck extends LightningElement {
    @track expanded = true;
    @track totalChecks = 0;
    @track passedChecks = 0;

    lastRunDate = new Date().toLocaleDateString("en-US"); // hardcoded for now

    handleHealthCheckComplete(){
        console.log('Health Check complete!');
    }
}