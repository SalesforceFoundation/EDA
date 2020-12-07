import { LightningElement } from 'lwc';

export default class HealthCheckHighlightsPanel extends LightningElement {
    lastRunDate = new Date().toLocaleDateString("en-US");

    labelReference = {
        edaSettingsHealthCheckTitle: 'EDA Settings Health Check', 
        healthCheckDescription: 'EDA Settings Health Check verifies that all of your EDA Settings are valid and not misconfigured. If any setting configuration is not valid, EDA Settings Health Check will tell you the setting, give a description of which setting is invalid, and how to fix it.'    
    }

    get lastRunDate(){
        return this.lastRunDate;
    }
}