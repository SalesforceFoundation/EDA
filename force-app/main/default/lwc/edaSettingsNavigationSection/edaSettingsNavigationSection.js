import { LightningElement, api } from "lwc";

export default class EdaSettingsNavigationSection extends LightningElement {
    @api viewModel;

    get menuItems() {
        if (!this.viewModel.menuItems) {
            return undefined;
        }

        let formattedMenuItems = [];

        this.viewModel.menuItems.forEach((menuItem) => {
            let formattedMenuItem = {
                label: menuItem.label,
                sectionKey: menuItem.sectionKey,
                page: this.viewModel.page,
            };
            formattedMenuItems.push(formattedMenuItem);
        });

        return formattedMenuItems;
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
        let menuItemClass = "slds-nav-vertical__item slds-p-left_x-large";

        if (this.viewModel.isActive) {
            menuItemClass += " eda-nav-is-active";
        }

        return menuItemClass;
    }

    get menuItemAnchorClass() {
        let menuItemClass = "slds-nav-vertical__item slds-p-left_x-large";

        if (this.viewModel.isActive) {
            menuItemClass += " eda-nav-is-active";
        }

        return menuItemClass;
    }
}
