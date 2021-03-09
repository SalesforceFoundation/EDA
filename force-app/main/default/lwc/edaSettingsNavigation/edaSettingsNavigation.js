import { LightningElement } from "lwc";

export default class EdaSettingsNavigation extends LightningElement {
    currentPage = "page1";

    edaNavigationViewModel = [
        {
            label: "Account Model",
            page: "accountmodelsettings",
        },
        {
            label: "Contact Information",
            page: "contactinfosettings",
        },
        {
            label: "Addresses",
            page: "addresssettings",
        },
    ];

    handleNavigationClick(event) {
        this.navigateToSettingsPage(event.currentTarget.dataset.pageSelected);
    }

    handleKeyUp(event) {
        console.log(JSON.stringify(event));
        //this.navigateToSettingsPage(event.currentTarget.dataset.pageSelected);
    }

    navigateToSettingsPage(pageName) {
        if (this.currentPage === pageName) {
            return;
        }

        this.currentPage = pageName;

        this.dispatchSettingsNavigationEvent(pageName);
    }

    dispatchSettingsNavigationEvent(pageName) {
        const settingsNavigationDetail = {
            pageName: pageName,
        };
        this.dispatchEvent(
            new CustomEvent("settingsnavigation", {
                detail: settingsNavigationDetail,
            })
        );
    }
}
