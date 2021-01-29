import { LightningElement, api } from 'lwc';

// import custom labels
import stgHealthCheckTitle from '@salesforce/label/c.stgHealthCheckTitle';
import stgHealthCheckDescription from '@salesforce/label/c.stgHealthCheckDescription';
import stgHealthCheckLastRun from '@salesforce/label/c.stgHealthCheckLastRun';
import stgHealthCheckRunButton from '@salesforce/label/c.stgHealthCheckRunButton';

export default class HealthCheckActionCard extends LightningElement {
    @api runDate;

    labelReference = {
        stgHealthCheckTitle,
        stgHealthCheckDescription,
        stgHealthCheckLastRun,
        stgHealthCheckRunButton
    }

    get lastRunDate() {
        if (this.runDate){
            return this.labelReference.stgHealthCheckLastRun.replace(
                '{0}', this.runDate
            );
        }
    }

    runHealthCheck(event){
        this.dispatchEvent(new CustomEvent('runhealthcheck'));
    }
}