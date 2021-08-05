import { createElement } from "lwc";
import EducationCloudSettings from "c/educationCloudSettings";
import getProductRegistrySettingsProductInformationVModels from "@salesforce/apex/EducationCloudSettingsController.getProductRegistrySettingsProductInformationVModels";

// Import mock data for c-edc-settings-product-display
const mockGetProductRegistrySettingsProductInformationVModels = require("./data/getProductRegistrySettingsProductInformationVModels.json");

jest.mock(
    '@salesforce/apex/EducationCloudSettingsController.getProductRegistrySettingsProductInformationVModels',
    () => {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
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

    it("Check if EDC Settings Product Display is shown and it has the parameter data", async() => {
        const element = createElement("c-education-cloud-settings", {
            is: EducationCloudSettings,
        });

        document.body.appendChild(element);
        getProductRegistrySettingsProductInformationVModels.emit(mockGetProductRegistrySettingsProductInformationVModels);

        await flushPromises();

        const edcSettingsProductCardElement = element.shadowRoot.querySelector(
            "c-edc-settings-product-display"
        );
        expect(edcSettingsProductCardElement).not.toBeNull();
        const productRegistryVModels = edcSettingsProductCardElement.productRegistryVModels;
        expect(productRegistryVModels).not.toBeNull();
        expect(productRegistryVModels.length).toBe(2);

        productRegistryVModels.forEach(productRegistry=> {
            const action = productRegistry.action;
            const namespace = productRegistry.namespace;
            const classname = productRegistry.classname;
            const apiVersion = productRegistry.apiVersion;

            if(action === 'testAction1') {
                expect(namespace).toBe('testNamespace1');
                expect(classname).toBe('testClassname1');
                expect(apiVersion).toBe(1);
                return;
            }
            if(action === 'testAction2') {
                expect(namespace).toBe('testNamespace2');
                expect(classname).toBe('testClassname2');
                expect(apiVersion).toBe(2);
                return;
            }
        });
    });
});
