import { LightningElement, api } from 'lwc';

// import custom labels
import stgEDASettingsHealthCheckTitle from '@salesforce/label/c.stgEDASettingsHealthCheckTitle';
import stgHealthCheckDescription from '@salesforce/label/c.stgHealthCheckDescription';
import stgHealthCheckLastRun from '@salesforce/label/c.stgHealthCheckLastRun';
import stgRunHealthCheckButton from '@salesforce/label/c.stgRunHealthCheckButton';

export default class HealthCheckActionCard extends LightningElement {
    @api runDate;

    labelReference = {
        stgEDASettingsHealthCheckTitle,
        stgHealthCheckDescription,
        stgHealthCheckLastRun,
        stgRunHealthCheckButton
    }

    get lastRunDate() {
        if (this.runDate){
            return this.labelReference.stgHealthCheckLastRun.replace(
                '{0}', this.runDate
            );
        }
    }

    runHealthCheck(event){
        this.dispatchEvent(new CustomEvent('run'));
    }
}