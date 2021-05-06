import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class EdcSettingsCard extends NavigationMixin(LightningElement) {
    //Body
    @api title;
    @api description;
    //Links
    @api buttonLabel;
    @api buttonTitle;
    @api navigationType;
    @api navigationTarget;

    handleNavigationClick(event) {
        event.preventDefault();
        event.stopPropagation();
        switch (this.navigationType) {
            case "standard__component":
                this.navigateToComponent();
                return;
            case "standard__webPage":
                this.navigateToWebPage();
                return;
        }
        return;
    }

    navigateToComponent() {
        const pageReference = {
            type: "standard__component",
            attributes: {
                componentName: this.navigationTarget,
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }

    navigateToWebPage() {
        const pageReference = {
            type: "standard__webPage",
            attributes: {
                url: this.navigationTarget,
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }
}
