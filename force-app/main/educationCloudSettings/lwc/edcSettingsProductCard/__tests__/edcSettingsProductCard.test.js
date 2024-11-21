import { createElement } from "lwc";
import EdcSettingsProductCard from "c/EdcSettingsProductCard";
import { getNavigateCalledWith } from "lightning/navigation";
import getEDCSettingsProductVModel from "@salesforce/apex/EducationCloudSettingsController.getEDCSettingsProductVModel";

// Import mock data for edcSettingsProductCard
const mockGetEDCSettingsProductVModel = require("./data/getEDCSettingsProductVModel.json");
const settingsButtonLabel = "settingsButtonLabel";
const documentationButtonLabel = "documentationButtonLabel";
const trailheadButtonLabel = "trailheadButtonLabel";

jest.mock(
    "@salesforce/label/c.stgBtnSettings",
    () => {
        return { default: settingsButtonLabel };
    },
    { virtual: true }
);
jest.mock(
    "@salesforce/label/c.stgBtnDocumentation",
    () => {
        return { default: documentationButtonLabel };
    },
    { virtual: true }
);
jest.mock(
    "@salesforce/label/c.stgBtnTrailhead",
    () => {
        return { default: trailheadButtonLabel };
    },
    { virtual: true }
);
jest.mock(
    "@salesforce/apex/EducationCloudSettingsController.getEDCSettingsProductVModel",
    () => {
        const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    { virtual: true }
);

describe("c-edc-settings-product-card", () => {
    afterEach(() => {
        clearDOM();
    });

    async function flushPromises() {
        return Promise.resolve();
    }

    it("Check if EDC Settings Product Card is shown and it has the parameter data", async () => {
        // Assign mock value for resolved Apex promise
        getEDCSettingsProductVModel.mockResolvedValue(mockGetEDCSettingsProductVModel);

        const element = createElement("c-edc-settings-product-card", {
            is: EdcSettingsProductCard,
        });

        element.productRegistry = {
            classname: "testClassName",
            namespace: "testNamespace",
            apiVersion: 2.0,
        };
        element.displayProductCards = true;

        document.body.appendChild(element);

        await flushPromises();

        //Assert the data is populated correctly on the product card
        const productTitleSpan = element.shadowRoot.querySelector(".productTitle");
        expect(productTitleSpan).not.toBeNull();
        expect(productTitleSpan.textContent).toBe("testName");

        const productIcon = element.shadowRoot.querySelector(".productIcon");
        expect(productIcon).not.toBeNull();
        expect(productIcon.initials).toBe("testInitials");
        expect(productIcon.fallbackIconName).toBe("testIcon");

        const productDescriptionSpan = element.shadowRoot.querySelector(".productDescription");
        expect(productDescriptionSpan).not.toBeNull();
        expect(productDescriptionSpan.textContent).toBe("testDescription");

        const btnSettingsComponent = element.shadowRoot.querySelector(".btnSettingsComponent");
        expect(btnSettingsComponent).not.toBeNull();
        expect(btnSettingsComponent.title).toBe("testSettingsButtonA11y");
        expect(btnSettingsComponent.label).toBe(settingsButtonLabel);
    });

    it("Check the button btnSettingsComponent works and navigates correctly", async () => {
        // Assign mock value for resolved Apex promise
        getEDCSettingsProductVModel.mockResolvedValue(mockGetEDCSettingsProductVModel);

        const element = createElement("c-edc-settings-product-card", {
            is: EdcSettingsProductCard,
        });

        element.productRegistry = {
            classname: "testClassName",
            namespace: "testNamespace",
            apiVersion: 2.0,
        };
        element.displayProductCards = true;

        document.body.appendChild(element);

        await flushPromises();

        const btnSettingsComponent = element.shadowRoot.querySelector(".btnSettingsComponent");
        expect(btnSettingsComponent).not.toBeNull();
        btnSettingsComponent.click();
        const { pageReference } = getNavigateCalledWith();

        //Get the details
        expect(pageReference.type).toBe("standard__component");
        expect(pageReference.attributes.componentName).toBe("testSettingsComponent");
    });

    it("Check the button btnTrailheadUrl works and navigates correctly", async () => {
        // Assign mock value for resolved Apex promise
        getEDCSettingsProductVModel.mockResolvedValue(mockGetEDCSettingsProductVModel);

        const element = createElement("c-edc-settings-product-card", {
            is: EdcSettingsProductCard,
        });

        element.productRegistry = {
            classname: "testClassName",
            namespace: "testNamespace",
            apiVersion: 2.0,
        };
        element.displayProductCards = true;

        document.body.appendChild(element);

        await flushPromises();
    });
});
