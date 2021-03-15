import { LightningElement, api } from "lwc";

export default class EdaSettingsNavigationSection extends LightningElement {
    @api viewModel;

    get qaLocator() {
        return "edaSettingsNav" + this.viewModel.id;
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
                qaLocator: "edaSettingsNav" + menuItem.id,
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
