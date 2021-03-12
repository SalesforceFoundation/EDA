import { LightningElement, api } from "lwc";

export default class EdaSettingsNavigationSection extends LightningElement {
    @api viewModel;

    get hasMenuItems() {
        return !!this.viewModel.menuItems;
    }

    get menuItemsViewModel() {
        let menuItemsViewModel = {
            page: this.viewModel.page,
            isActive: this.viewModel.isActive,
            leftPadding: "slds-p-left_xx-large",
        };

        let formattedMenuItems = [];

        this.viewModel.menuItems.forEach((menuItem) => {
            let formattedMenuItem = {
                label: menuItem.label,
                sectionKey: menuItem.sectionKey,
                page: this.viewModel.page,
            };
            formattedMenuItems.push(formattedMenuItem);
        });

        menuItemsViewModel.menuItems = formattedMenuItems;

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
