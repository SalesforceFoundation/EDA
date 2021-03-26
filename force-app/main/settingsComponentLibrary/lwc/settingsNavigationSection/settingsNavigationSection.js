import { LightningElement, api } from "lwc";

export default class SettingsNavigationSection extends LightningElement {
    @api viewModel;

    get ariaCurrent() {
        if (!this.viewModel.isActive) {
            return undefined;
        }

        return "page";
    }

    get qaLocator() {
        return "settingsNav" + this.viewModel.id;
    }

    get hasMenuItems() {
        return !!this.viewModel.menuItems;
    }

    get menuItemsViewModel() {
        let formattedMenuItems = [];

        this.viewModel.menuItems.forEach((menuItem) => {
            let formattedMenuItem = {
                label: menuItem.label,
                id: menuItem.id,
                qaLocator: "settingsNav" + menuItem.id,
            };
            formattedMenuItems.push(formattedMenuItem);
        });

        const menuItemsViewModel = {
            page: this.viewModel.page,
            isActive: this.viewModel.isActive,
            paddingLeft: "slds-p-left_xx-large",
            menuItems: formattedMenuItems,
        };

        return menuItemsViewModel;
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
}
