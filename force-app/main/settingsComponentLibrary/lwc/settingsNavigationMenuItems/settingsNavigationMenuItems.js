import { LightningElement, api } from "lwc";

export default class SettingsNavigationMenuItems extends LightningElement {
    @api viewModel;

    get qaLocator() {
        return "settingsNav" + this.viewModel.id;
    }

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
        let menuItemClass = this.viewModel.paddingLeft + " slds-p-bottom_xxx-small slds-truncate";

        if (this.viewModel.isActive) {
            menuItemClass += " nav-is-active";
        }

        return menuItemClass;
    }
}
