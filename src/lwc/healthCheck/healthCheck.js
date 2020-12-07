import { LightningElement, track, wire } from 'lwc';

export default class HealthCheck extends LightningElement {
    @track expanded = true;
    @track totalChecks = 0;
    @track passedChecks = 0;

    labelReference = {
        edaSetup: 'EDA Setup',
        healthCheckTitle: 'Health Check',
        runHealthCheckButton: 'Run Health Check',
        passedChecks: 'Checks Passed: {0}/{1}',
        statusColumnHeader: 'Status',
        settingColumnHeader: 'Setting',
        descriptionColumnHeader: 'Description',
        recommendedFixColumnHeader: 'Recommended Fix',
    }
}