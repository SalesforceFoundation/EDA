import { LightningElement, api, track } from "lwc";

export default class SettingsNavigation extends LightningElement {
    @api viewModel;
    @api activePage;
    @api spinnerLoadingAltText;

    @track parsedViewModel;

    setActivePage(pageName) {
        this.parsedViewModel.activePage = pageName;
        this.parsedViewModel.navigationSections.forEach((navigationSection) => {
            if (navigationSection.page === pageName) {
                navigationSection.isActive = true;
            } else {
                navigationSection.isActive = undefined;
                this.setActiveSubpage(pageName, navigationSection);
            }
        });
    }

    setActiveSubpage(pageName, navigationSection) {
        if (!navigationSection.navigationSubSections) {
            return;
        }

        navigationSection.navigationSubSections.forEach((navigationSubSection) => {
            if (navigationSubSection.page === pageName) {
                navigationSubSection.isActive = true;
            } else {
                navigationSubSection.isActive = undefined;
            }
        });
    }

    renderedCallback() {
        if (!this.parsedViewModel || this.parsedViewModel.activePage !== this.activePage) {
            this.parsedViewModel = JSON.parse(JSON.stringify(this.viewModel));
            this.setActivePage(this.activePage);
        }
    }
}
