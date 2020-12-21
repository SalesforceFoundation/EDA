import { LightningElement, api, track } from 'lwc';

export default class HealthCheckDisplay extends LightningElement {
    @api healthCheckDefinitionsList;
    @track displayHealthCheckDefinition = false;
    @track healthCheckGroupCount = 0;

    handleHealthCheckGroupLoaded(){
        console.log('Health Check Group loaded!');
        this.healthCheckDefinitionsList++;
    }
}