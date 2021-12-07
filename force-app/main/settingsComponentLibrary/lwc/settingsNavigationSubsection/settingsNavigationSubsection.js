import { LightningElement, api } from "lwc";

export default class SettingsNavigationSubsection extends LightningElement {
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
            paddingLeft: "slds-var-p-left_x-large",
            menuItems: formattedMenuItems,
        };

        return menuItemsViewModel;
    }

    handleNavigationClick(event) {
        event.preventDefault();
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

    get subsectionHeaderClass() {
        let subsectionHeaderClass = "slds-p-top_xx-small slds-p-bottom_xx-small slds-p-horizontal_medium";

        if (this.viewModel.isActive) {
            subsectionHeaderClass += " nav-is-active";
        }

        return subsectionHeaderClass;
    }
}
