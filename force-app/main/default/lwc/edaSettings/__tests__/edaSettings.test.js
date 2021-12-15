import { createElement } from "lwc";

import edaSettings from "c/edaSettings";
import checkAccessForCurrentUser from "@salesforce/apex/EDASettingsController.checkAccessForCurrentUser";

jest.mock(
    "@salesforce/apex/EDASettingsController.checkAccessForCurrentUser",
    () => {
        const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    { virtual: true }
);

describe("c-eda-settings", () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it("should dynamically render insufficient access error", async () => {
        const element = createElement("c-eda-settings", {
            is: edaSettings,
        });

        checkAccessForCurrentUser.emit(true);

        document.body.appendChild(element);

        return Promise.resolve()
            .then(() => {
                const errorMessage = element.shadowRoot.querySelector(
                    '[data-testid="eda-settings-error-insufficient-access"]'
                );
                expect(errorMessage).toBeNull();
            })
            .then(() => {
                checkAccessForCurrentUser.emit(false);
            })
            .then(async () => {
                const errorMessage = element.shadowRoot.querySelector(
                    '[data-testid="eda-settings-error-insufficient-access"]'
                );
                expect(errorMessage.textContent).toBe("c.stgErrorInsufficientAccess");
            });
    });
});
