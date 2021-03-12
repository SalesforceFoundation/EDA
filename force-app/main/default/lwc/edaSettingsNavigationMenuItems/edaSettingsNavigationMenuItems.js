import { LightningElement, api } from "lwc";

export default class EdaSettingsMenuItems extends LightningElement {
    @api viewModel;

    handleNavigationClick() {
        this.dispatchSettingsNavigationEvent();
    }

    dispatchSettingsNavigationEvent() {
        const settingsNavigationDetail = {
            pageName: this.viewModel.page,
        };
        this.dispatchEvent(
            new CustomEvent("settingsnavigation", {
                detail: settingsNavigationDetail,
                bubbles: true,
                composed: true,
            })
        );
    }

    get menuItemClass() {
        let menuItemClass = this.viewModel.leftPadding + " slds-p-bottom_xxx-small slds-truncate";

        if (this.viewModel.isActive) {
            menuItemClass += " eda-nav-is-active";
        }

        return menuItemClass;
    }
}
