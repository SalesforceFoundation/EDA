import { LightningElement, api } from 'lwc';

export default class HealthCheckActionCard extends LightningElement {
    @api runDate;

    labelReference = {
        runHealthCheckButton: 'Run Health Check',
        healthCheckLastRun: 'Last run {0}',
    }

    get lastRunDate() {
        return this.labelReference.healthCheckLastRun.replace(
            '{0}', runDate
        );
    }
}