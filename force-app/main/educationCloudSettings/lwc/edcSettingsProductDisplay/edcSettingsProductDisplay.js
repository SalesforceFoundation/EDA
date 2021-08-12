import { LightningElement, api, track } from 'lwc';
import stgHealthCheckLoadingIndicator from "@salesforce/label/c.stgHealthCheckLoadingIndicator";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class EdcSettingsProductDisplay extends LightningElement {
    @api productRegistryVModels;

    @track loadedSettingsProductCount = 0;
    @track displaySettingsProduct = false;
    errorList = [];

    LabelReference = {
        spinnerLoadingAltText: stgHealthCheckLoadingIndicator,
    };

    handleSettingsProductLoaded(evt) {
        this.loadedSettingsProductCount++;
        this.areAllProductsLoaded();
    }

    handleSettingsProductError(evt){
        const errorMessage = evt.detail.errorMessage;
        this.errorList.push(errorMessage);
        this.loadedSettingsProductCount++;
        this.areAllProductsLoaded();
    }

    areAllProductsLoaded(){
        if (this.loadedSettingsProductCount !== this.productRegistryVModels.length) {
            return;
        }
        
        this.displaySettingsProduct = true;
        if (this.errorList && this.errorList.length > 0){
            this.errorList.forEach(error => {
                this.createShowToast(error);
            });
        }
    }

    connectedCallback(){
        if (this.productRegistryVModels.length == 0) {
            this.displaySettingsProduct = true;
        }
    }

    createShowToast(errorMessage) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: errorMessage,
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }
}