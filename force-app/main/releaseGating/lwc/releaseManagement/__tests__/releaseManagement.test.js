import { createElement } from "lwc";
import ReleaseManagement from "c/releaseManagement";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import { getNavigateCalledWith } from "lightning/navigation";
import getProductRegistryReleaseGateVModels from "@salesforce/apex/ReleaseGateController.getProductRegistryReleaseGateVModels";

const PRODUCT_REGISTRIES = [
    {
        action: "Release Gating",
        apiVersion: 52,
        classname: "EDADemoReleaseGate",
        name: "EDADemoReleaseGate",
    },
];

// Mock labels
const stgReleaseManagementTitle = "stgReleaseManagementTitle";
jest.mock(
    "@salesforce/label/c.stgReleaseManagementTitle",
    () => {
        return { default: stgReleaseManagementTitle };
    },
    { virtual: true }
);
const stgToastError = "stgToastError";
jest.mock(
    "@salesforce/label/c.stgToastError",
    () => {
        return { default: stgToastError };
    },
    { virtual: true }
);

// Mock Apex wire adapters
jest.mock(
    "@salesforce/apex/ReleaseGateController.getProductRegistryReleaseGateVModels",
    () => {
        const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    { virtual: true }
);

describe("c-release-management", () => {
    afterEach(() => {
        clearDOM();
    });

    it("Check if component is rendered correctly on successful response", () => {
        const element = createElement("c-release-management", {
            is: ReleaseManagement,
        });
        document.body.appendChild(element);
        getProductRegistryReleaseGateVModels.emit(PRODUCT_REGISTRIES);

        return Promise.resolve().then(async () => {
            await expect(element).toBeAccessible();

            const releaseGates = element.shadowRoot.querySelectorAll("c-release-gates");
            expect(releaseGates).not.toBeNull();
            expect(releaseGates.length).toBe(1);

            const releaseManagementTitle = element.shadowRoot.querySelector(".releaseManagementTitle");
            expect(releaseManagementTitle).not.toBeNull();
            expect(releaseManagementTitle.textContent).toBe(stgReleaseManagementTitle);
        });
    });

    it("Check if component is handling error response", () => {
        const element = createElement("c-release-management", {
            is: ReleaseManagement,
        });
        document.body.appendChild(element);
        // Mock handler for toast event
        const toastHandler = jest.fn();
        element.addEventListener(ShowToastEventName, toastHandler);

        getProductRegistryReleaseGateVModels.error();

        return Promise.resolve().then(async () => {
            await expect(element).toBeAccessible();

            expect(toastHandler).toHaveBeenCalled();
            expect(toastHandler.mock.calls[0][0].detail.title).toBe(stgToastError);
            expect(toastHandler.mock.calls[0][0].detail.variant).toBe("error");
        });
    });

    it("Check if navigation to settings page is correct", () => {
        const element = createElement("c-release-management", {
            is: ReleaseManagement,
        });
        document.body.appendChild(element);
        getProductRegistryReleaseGateVModels.emit(PRODUCT_REGISTRIES);

        return Promise.resolve().then(async () => {
            const edcNavLink = element.shadowRoot.querySelector(".edcNavLink");
            expect(edcNavLink).not.toBeNull();
            edcNavLink.click();
            const { pageReference } = getNavigateCalledWith();
            expect(pageReference.type).toBe("standard__component");
            expect(pageReference.attributes.componentName).toContain("EducationCloudSettingsContainer");
        });
    });
});
