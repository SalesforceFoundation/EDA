import { LightningElement, track, wire } from 'lwc';

import getHealthCheckViewModel from '@salesforce/apex/HealthCheckController.getHealthCheckViewModel';

export default class HealthCheck extends LightningElement {
    @track expanded = true;
    @track totalChecks = 0;
    @track passedChecks = 0;
    @track lastRunDate = '';

    handleHealthCheckRun(){
        console.log('handling health check run');
        // var currentDate = new Date();
        // this.lastRunDate = currentDate.toLocaleDateString() + ' ' + currentDate.toLocaleTimeString();
        // console.log('Health Check complete!');
    }

    @wire(getHealthCheckViewModel)
    healthCheckViewModel({error, data}){
        console.log('Wiring view model');

        if (data){
            let stringified = JSON.stringify(data);
            console.log( 'Stringified is ' + stringified );

            let tempData = JSON.parse( stringified );
            console.log( 'Temp Data is ' + JSON.stringify(tempData) );
            
        } else if(error){
            console.log('Error wiring healthCheckViewModel');
            if ( Array.isArray( error.body ) )
                console.log( 'Error is ' + error.body.map( e => e.message ).join( ', ' ) );
            else if ( typeof error.body.message === 'string' )
                console.log( 'Error is ' + error.body.message );
        }

    }
}