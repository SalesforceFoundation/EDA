import { createElement } from "lwc";
import EdcSettingsCard from "c/edcSettingsProductCard";

import getEDCSettingsProductVModel from "@salesforce/apex/EDCSettingsProductCardController.getEDCSettingsProductVModel";

// Import mock data for edcSettingsProductCard
const mockGetEDCSettingsProductVModel = require("./data/getEDCSettingsProductVModel.json");
const settingsButtonLabel = "settingsButtonLabel";
const settingsButtonA11yTitle = "settingsButtonA11y";
const documentationButtonLabel = "documentationButtonLabel";
const documentationButtonA11yTitle = "documentationButtonA11yTitle";
const trailheadButtonLabel = "trailheadButtonLabel";
const trailheadButtonA11yTitle = "trailheadButtonA11yTitle";

jest.mock(
    "@salesforce/label/c.stgBtnSettings",
    () => {
        return { default: settingsButtonLabel };
    },
    { virtual: true }
);
jest.mock(
    "@salesforce/label/c.stgBtnSettingsActionA11y",
    () => {
        return { default: settingsButtonA11yTitle };
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
    "@salesforce/label/c.stgBtnDocumentationActionA11y",
    () => {
        return { default: documentationButtonA11yTitle };
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
    "@salesforce/label/c.stgBtnTrailheadActionA11y",
    () => {
        return { default: trailheadButtonA11yTitle };
    },
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/EDCSettingsProductCardController.getEDCSettingsProductVModel',
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


describe("c-edc-settings-product-card", () => {
    afterEach(() => {
        clearDOM();
    });

    async function flushPromises() {
        return Promise.resolve();
    }

    it("Check if EDC Settings Product Card is shown and it has the parameter data", async() => {

        // Assign mock value for resolved Apex promise
        getEDCSettingsProductVModel.mockResolvedValue(mockGetEDCSettingsProductVModel);

        const element = createElement("c-edc-settings-product-card", {
            is: EdcSettingsCard,
        });

        element.productRegistry = {
            classname: "testClassName",
            namespace: "testNamespace",
            apiVersion: 2.0
        }
        element.isDisplayProduct = true;

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
        expect(btnSettingsComponent.title).toBe(settingsButtonA11yTitle);
        expect(btnSettingsComponent.label).toBe(settingsButtonLabel);

        const btnDocumentationUrl = element.shadowRoot.querySelector(".btnDocumentationUrl");
        expect(btnDocumentationUrl).not.toBeNull();
        expect(btnDocumentationUrl.title).toBe(documentationButtonA11yTitle);
        expect(btnDocumentationUrl.label).toBe(documentationButtonLabel);

        const btnTrailheadUrl = element.shadowRoot.querySelector(".btnTrailheadUrl");
        expect(btnTrailheadUrl).not.toBeNull();
        expect(btnTrailheadUrl.title).toBe(trailheadButtonA11yTitle);
        expect(btnTrailheadUrl.label).toBe(trailheadButtonLabel);
    });
});
