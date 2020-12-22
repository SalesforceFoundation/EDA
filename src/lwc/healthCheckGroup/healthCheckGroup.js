import { LightningElement, track, wire } from 'lwc';
import getViewModel from '@salesforce/apex/HealthCheckController.getHealthCheckViewModel';

export default class HealthCheckGroup extends LightningElement {
    @track isDisplayGroup = true;
    @track isExpanded = true;
    @track dataLoad;
    @track gridData;
    @track grigExpandedRows;

    handleDataLoad(){}

    collapseGroup(){
        console.log('collapse group clicked');
    }

    expandGroup(){
        console.log('expand group clicked');
    }

    labelReference = {
        statusColumnHeader: 'Status'
    }

    @wire(getViewModel)
    treeData({ error, data }) {
        console.log( 'Inside wire' );
        if ( data ) {
            let stringified = JSON.stringify(data);
            console.log( 'Stringified is ' + stringified );
            let tempData = JSON.parse( stringified );
            console.log( 'Temp Data is ' + JSON.stringify(tempData) );

            this.totalChecks = tempData.totalChecks;
            this.passedChecks = tempData.passedChecks;

            let tempArray = [].concat(tempData.healthCheckItems);
            console.log( 'Array is ' + JSON.stringify( tempData ) );
            this.processChildren(tempArray);
            console.log( 'Modified Array is ' + JSON.stringify( tempArray ) );
            this.gridData = tempArray;
            this.gridExpandedRows = tempData.expandedRows;

            // first healthcheckgrouploaded event
            this.dispatchEvent(new CustomEvent('healthcheckgrouploaded'));

        } else if ( error ) {
         
            if ( Array.isArray( error.body ) )
                console.log( 'Error is ' + error.body.map( e => e.message ).join( ', ' ) );
            else if ( typeof error.body.message === 'string' )
                console.log( 'Error is ' + error.body.message );
        }
    }

    // definition of columns for the tree grid
    gridColumns = [
        {
            type: 'text',
            fieldName: 'status',
            label: this.labelReference.statusColumnHeader,
        },
        {
            type: 'text',
            fieldName: 'setting',
            label: 'Setting',
        },
        {
            type: 'text',
            fieldName: 'description',
            label: 'Description',
        },
        {
            type: 'text',
            fieldName: 'recommendedFix',
            label: 'Recommended Fix',
        },
    ];
}