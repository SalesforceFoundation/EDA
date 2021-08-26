import { createElement } from "lwc";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import EducationCloudSettings from "c/EducationCloudSettings";
import getProductRegistrySettingsProductInformationVModels from "@salesforce/apex/EducationCloudSettingsController.getProductRegistrySettingsProductInformationVModels";

// Import mock data for c-edc-settings-product-display
const mockGetProductRegistrySettingsProductInformationVModels = require("./data/getProductRegistrySettingsProductInformationVModels.json");

jest.mock(
    "@salesforce/apex/EducationCloudSettingsController.getProductRegistrySettingsProductInformationVModels",
    () => {
        const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    { virtual: true }
);

describe("c-education-cloud-settings", () => {
    afterEach(() => {
        clearDOM();
    });

    async function flushPromises() {
        return Promise.resolve();
    }

    it("Check if release management tile is visible and navigation target is correct", () => {
        const element = createElement("c-education-cloud-settings", {
            is: EducationCloudSettings,
        });
        document.body.appendChild(element);

        return Promise.resolve().then(async () => {
            const edcReleaseManagementCardLI = element.shadowRoot.querySelector(".edcReleaseManagementCard");
            expect(edcReleaseManagementCardLI).not.toBeNull();
            const releaseManagementCardElement = edcReleaseManagementCardLI.querySelector(
                "c-edc-release-management-card"
            );
            expect(releaseManagementCardElement).not.toBeNull();

            const containerName = releaseManagementCardElement.navigationTarget;
            expect(containerName).not.toBeNull();
            expect(containerName.endsWith("releaseManagementContainer")).toBeTruthy();
        });
    });

    it("Check if EDC Settings Product Display is shown and it has the parameter data", async () => {
        const element = createElement("c-education-cloud-settings", {
            is: EducationCloudSettings,
        });

        document.body.appendChild(element);
        getProductRegistrySettingsProductInformationVModels.emit(
            mockGetProductRegistrySettingsProductInformationVModels
        );

        await flushPromises();

        const edcSettingsProductCardElement = element.shadowRoot.querySelector("c-edc-settings-product-display");
        expect(edcSettingsProductCardElement).not.toBeNull();
        const productRegistryVModels = edcSettingsProductCardElement.productRegistryVModels;
        expect(productRegistryVModels).not.toBeNull();
        expect(productRegistryVModels.length).toBe(2);

        productRegistryVModels.forEach((productRegistry) => {
            const action = productRegistry.action;
            const namespace = productRegistry.namespace;
            const classname = productRegistry.classname;
            const apiVersion = productRegistry.apiVersion;

            if (action === "testAction1") {
                expect(namespace).toBe("testNamespace1");
                expect(classname).toBe("testClassname1");
                expect(apiVersion).toBe(1);
                return;
            }
            if (action === "testAction2") {
                expect(namespace).toBe("testNamespace2");
                expect(classname).toBe("testClassname2");
                expect(apiVersion).toBe(2);
                return;
            }
        });
    });

    it("Check if EDC Settings Product Display shows an error when an error ocurred", async () => {
        const mockError = {
            message: "error message",
        };
        const element = createElement("c-education-cloud-settings", {
            is: EducationCloudSettings,
        });

        document.body.appendChild(element);

        // Mock handler for toast event
        const toastHandler = jest.fn();

        // Add event listener to catch toast event
        element.addEventListener(ShowToastEventName, toastHandler);

        // Emit error from @wire
        getProductRegistrySettingsProductInformationVModels.error(mockError, 400);

        await flushPromises();

        const edcSettingsProductCardElement = element.shadowRoot.querySelector("c-edc-settings-product-display");
        expect(edcSettingsProductCardElement).not.toBeNull();
        const productRegistryVModels = edcSettingsProductCardElement.productRegistryVModels;
        expect(productRegistryVModels).toBeNull;

        expect(toastHandler).toHaveBeenCalled();
        expect(toastHandler.mock.calls[0][0].detail.title).toBe("Error");
        expect(toastHandler.mock.calls[0][0].detail.message).toBe(mockError.message);
    });

    it("Check if the edcToolsCard section is shown correctly", () => {
        const element = createElement("c-education-cloud-settings", {
            is: EducationCloudSettings,
        });
        document.body.appendChild(element);

        return Promise.resolve().then(async () => {
            const edcToolsCardLI = element.shadowRoot.querySelector(".edcToolsCard");
            expect(edcToolsCardLI).not.toBeNull();
            const edcToolsCardElement = edcToolsCardLI.querySelector("c-edc-settings-card");
            expect(edcToolsCardElement).not.toBeNull();

            const containerName = edcToolsCardElement.navigationTarget;
            expect(containerName).not.toBeNull();
            expect(containerName.endsWith("HealthCheckContainer")).toBeTruthy();
        });
    });
});
