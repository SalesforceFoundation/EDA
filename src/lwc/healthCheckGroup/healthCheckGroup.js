import { LightningElement, track, wire, api } from 'lwc';

import stgHealthChecksAllPassed from '@salesforce/label/c.stgHealthChecksAllPassed';
import stgHealthChecksNotAllPassed from '@salesforce/label/c.stgHealthChecksNotAllPassed';
import stgHealthCheckStatus from '@salesforce/label/c.stgHealthCheckStatus';
import stgHealthCheckSetting from '@salesforce/label/c.stgHealthCheckSetting';
import stgHealthCheckResultsDescription from '@salesforce/label/c.stgHealthCheckResultsDescription';
import stgHealthCheckRecoFix from '@salesforce/label/c.stgHealthCheckRecoFix';
import stgHealthCheckRunError from '@salesforce/label/c.stgHealthCheckRunError';
import stgHealthCheckResultsExpand from '@salesforce/label/c.stgHealthCheckResultsExpand';
import stgHealthCheckResultsCollapse from '@salesforce/label/c.stgHealthCheckResultsCollapse';

import getHealthCheckGroupViewModel from '@salesforce/apex/HealthCheckGroupController.getHealthCheckGroupViewModel';

export default class HealthCheckGroup extends LightningElement {
    @api isDisplayGroup;
    @api healthCheckDefinition;

    @track healthCheckItemList;
    @track expandedRowsList;
    @track totalChecks = 0;
    @track passedChecks = 0;
    @track isExpanded;
    
    labelReference = {
        stgHealthChecksAllPassed,
        stgHealthChecksNotAllPassed,
        stgHealthCheckStatus,
        stgHealthCheckSetting,
        stgHealthCheckResultsDescription,
        stgHealthCheckRecoFix,
        stgHealthCheckRunError,
        stgHealthCheckResultsExpand,
        stgHealthCheckResultsCollapse
    }

    iconReference = {
        expandedIcon: 'utility:chevrondown',
        collapsedIcon: 'utility:chevronright',
        errorIcon: 'utility:error',
        successIcon: 'utility:success',
    }

    get healthCheckResultsId(){
        let tempString = this.healthCheckDefinition.name + 'Results';
        return tempString.split(" ").join("");
    }

    get collapsableIcon() {
        if (this.isExpanded){
            return this.iconReference.expandedIcon;
        }

        return this.iconReference.collapsedIcon;        
    }

    get collapsableIconAltText(){
        if (this.isExpanded){
            return this.labelReference.stgHealthCheckResultsCollapse;
        }
        
        return this.labelReference.stgHealthCheckResultsExpand;
    }

    get statusIcon() {
        if (this.isAllSuccessStatus()){
            return this.iconReference.successIcon;
        }

        return this.iconReference.errorIcon;        
    } 

    get statusIconVariant() {
        if (this.isAllSuccessStatus()) {
            return 'success';
        }

        return 'error';
    }

    get passedChecksDisplay() {
        if (this.passedChecks == this.totalChecks){
            return this.labelReference.stgHealthChecksAllPassed;
        }

        return this.labelReference.stgHealthChecksNotAllPassed.replace(
            '{0}', this.passedChecks
        ).replace(
            '{1}',this.totalChecks
        );
    }

    isAllSuccessStatus(){
        if (this.passedChecks == this.totalChecks){
            return true;
        }

        return false;
    }

    toggleExpanded() {
        this.isExpanded = !this.isExpanded; 
    }

    @wire(
        getHealthCheckGroupViewModel, 
        {
            name: '$healthCheckDefinition.name', 
            className: '$healthCheckDefinition.className', 
            namespace: '$healthCheckDefinition.namespace'
        })
    treeData({ error, data }) {
        if ( data ) {
            let stringified = JSON.stringify(data);            
            let tempData = JSON.parse( stringified );

            this.totalChecks = tempData.totalChecks;
            this.passedChecks = tempData.passedChecks;

            this.isExpanded = !(this.isAllSuccessStatus());

            this.healthCheckGroupName = tempData.label;

            let tempArray = [].concat(tempData.healthCheckItemList);            
            this.processChildren(tempArray);

            this.healthCheckItemList = tempArray;
            this.expandedRowsList = tempData.expandedRows;

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
            if(healthCheckItemArray[ i ][ 'healthCheckItemList' ]) {
                
                if(healthCheckItemArray[ i ][ 'healthCheckItemList' ].length > 0) {
                    healthCheckItemArray[ i ]._children = healthCheckItemArray[ i ][ 'healthCheckItemList' ];
                    this.processChildren(healthCheckItemArray[ i ]._children);
                }

                delete healthCheckItemArray[ i ].healthCheckItemList;
            }
        }
    }

    // definition of columns for the tree grid
    gridColumns = [
        {
            type: 'text',
            fieldName: 'statusLabel',
            label: this.labelReference.stgHealthCheckStatus,
        },
        {
            type: 'text',
            fieldName: 'setting',
            label: this.labelReference.stgHealthCheckSetting,
        },
        {
            type: 'text',
            fieldName: 'description',
            label: this.labelReference.stgHealthCheckResultsDescription,
        },
        {
            type: 'text',
            fieldName: 'recommendedFix',
            label: this.labelReference.stgHealthCheckRecoFix,
        },
    ];
}
