import { LightningElement, api } from "lwc";

export default class EdaSettingsNavigationSection extends LightningElement {
    @api viewModel;

    handleNavigationClick(event) {
        this.dispatchSettingsNavigationEvent();
    }

    dispatchSettingsNavigationEvent(pageName) {
        const settingsNavigationDetail = {
            pageName: viewModel.pageName,
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
