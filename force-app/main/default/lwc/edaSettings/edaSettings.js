<<<<<<< HEAD
import { LightningElement, api } from "lwc";
=======
import { LightningElement, api, wire } from "lwc";
import stgErrorInsufficientAccess from "@salesforce/label/c.stgErrorInsufficientAccess";
import checkAccessForCurrentUser from "@salesforce/apex/EDASettingsController.checkAccessForCurrentUser";

>>>>>>> feature/232__edaSettingsPermission
export default class EDASettings extends LightningElement {
    @api pageReference;

    labelReference = {
        settingsNavigation: "Navigation Pane Here",
<<<<<<< HEAD
    };

    settingsPageToDisplay = {
        accountModelSettings: true,
    };

    changePageToDisplay(pageName) {
        let settingsPageDisplay = {};
        settingsPageDisplay[pageName.toLowerCase()] = true;

        settingsPageToDisplay = settingsPageDisplay;
    }
=======
        settingsPage: "Settings Page Here",
        stgErrorInsufficientAccess,
    };

    currentUserHasAccess = false;
    //@wire(checkAccessForCurrentUser) currentUserHasAccess;
>>>>>>> feature/232__edaSettingsPermission
}
