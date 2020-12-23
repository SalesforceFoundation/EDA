import { LightningElement, track, wire, api } from 'lwc';
import getHealthCheckGroupViewModel from '@salesforce/apex/HealthCheckGroupController.getHealthCheckGroupViewModel';

export default class HealthCheckGroup extends LightningElement {
    @api isDisplayGroup = false;
    // @api isDisplayHealthCheckGroup = false;

    @track isExpanded = true;
    @track dataLoad;
    @track gridData;
    @track gridExpandedRows;

    @track groupName = 'all success';
    @track groupClassName = 'EDAHealthCheckGroupAPIService';
    @track groupNamespace = 'hed';

    handleDataLoad(){}

    labelReference = {
        edaSetup: 'EDA Setup',
        healthCheckTitle: 'Health Check',
        edaSettingsHealthCheckTitle: 'EDA Settings Health Check',
        healthCheckDescription: 'EDA Settings Health Check verifies that all of your EDA Settings are valid and not misconfigured. If any setting configuration is not valid, EDA Settings Health Check will tell you the setting, give a description of which setting is invalid, and how to fix it.',
        runHealthCheckButton: 'Run Health Check',
        healthCheckLastRun: 'Last run {0}',
        passedChecks: 'Checks Passed: {0} of {1}',
        statusColumnHeader: 'Status',
        settingColumnHeader: 'Setting',
        descriptionColumnHeader: 'Description',
        recommendedFixColumnHeader: 'Recommended Fix',
    }

    iconReference = {
        expandedIcon: 'utility:chevrondown',
        collapsedIcon: 'utility:chevronright',
    }

    collapseGroup(){
        console.log('collapse group clicked');
    }

    expandGroup(){
        console.log('expand group clicked');
    }

    labelReference = {
        statusColumnHeader: 'Status'
    }

    @wire(
        getHealthCheckGroupViewModel, 
        {
            name: '$groupName', 
            className: '$groupClassName', 
            namespace: '$groupNamespace'
        })
    treeData({ error, data }) {
        console.log( 'Inside wire' );
        if ( data ) {
            let stringified = JSON.stringify(data);
            console.log( 'Stringified is ' + stringified );
            
            let tempData = JSON.parse( stringified );
            console.log( 'Temp Data is ' + JSON.stringify(tempData) );

            this.totalChecks = tempData.totalChecks;
            this.passedChecks = tempData.passedChecks;

            let tempArray = [].concat(tempData.healthCheckItemList);
            console.log( 'Array is ' + JSON.stringify( tempData ) );
            
            this.processChildren(tempArray);
            console.log( 'Modified Array is ' + JSON.stringify( tempArray ) );

            this.gridData = tempArray;
            this.gridExpandedRows = tempData.expandedRows;

            // first healthcheckgrouploaded event
            console.log('sending group loaded event');
            this.dispatchEvent(new CustomEvent('healthcheckgrouploaded'));

        } else if ( error ) {
            if ( Array.isArray( error.body ) )
                console.log( 'Error is ' + error.body.map( e => e.message ).join( ', ' ) );
            else if ( typeof error.body.message === 'string' )
                console.log( 'Error is ' + error.body.message );
        }
    }

    processChildren(healthCheckItemArray) {
        if (!healthCheckItemArray) {
            return;
        }

        for ( let i = 0; i < healthCheckItemArray.length; i++ ) {

            if(healthCheckItemArray[ i ][ 'healthCheckItems' ]) {
                healthCheckItemArray[ i ]._children = healthCheckItemArray[ i ][ 'healthCheckItems' ];
                this.processChildren(healthCheckItemArray[ i ]._children);
                delete healthCheckItemArray[ i ].healthCheckItems;
            }
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

    get collapsableIcon() {
        if(this.expanded) {
            return this.iconReference.expandedIcon;
        }

        return this.iconReference.collapsedIcon;
    }

    get notExpanded() {
        return !this.expanded;
    }

    get passedChecksDisplay() {
        return this.labelReference.passedChecks;
        // return this.labelReference.passedChecks.replace(
        //     '{0}', this.passedChecks
        // ).replace(
        //     '{1}',this.totalChecks
        // );
    }

    toggleExpanded() {
        this.expanded = !this.expanded;
    }
}