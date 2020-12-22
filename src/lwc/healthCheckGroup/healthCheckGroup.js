import { LightningElement, track } from 'lwc';

export default class HealthCheckGroup extends LightningElement {
    @track isDisplayGroup = false;
    @track dataLoad;

    handleDataLoad(){}
}