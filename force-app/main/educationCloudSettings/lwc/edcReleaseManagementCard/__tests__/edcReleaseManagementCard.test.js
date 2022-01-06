import { createElement } from "lwc";
import EdcReleaseManagementCard from "c/edcReleaseManagementCard";
import getProductRegistryReleaseGateVModels from "@salesforce/apex/ReleaseGateController.getProductRegistryReleaseGateVModels";
import getReleaseGateVModel from "@salesforce/apex/ReleaseGateController.getReleaseGateVModel";
import { getNavigateCalledWith } from "lightning/navigation";

const ReleaseManagementTitleLabel = "ReleaseManagementTitleLabel is set";
const ReleaseManagementButtonLabel = "ReleaseManagementButtonLabel is set";
const ReleaseManagementButtonTitle = "ReleaseManagementButtonTitle is set";
const ReleaseGateProgressIncompleteLabel = "stgReleaseGateProgressIndicatorIncomplete";
const ReleaseGateProgressCompleteLabel = "stgReleaseGateProgressIndicatorComplete";

const PRODUCT_REGISTRIES = require("./data/productRegistry.json");
const RELEASE_GATES = require("./data/releaseGates.json");
const RELEASE_GATES_ACTIVE = require("./data/releaseGatesActive.json");

jest.mock(
    "@salesforce/apex/ReleaseGateController.getProductRegistryReleaseGateVModels",
    () => {
        return {
            default: jest.fn(),
        };
    },
    { virtual: true }
);
jest.mock(
    "@salesforce/apex/ReleaseGateController.getReleaseGateVModel",
    () => {
        return {
            default: jest.fn(),
        };
    },
    { virtual: true }
);

jest.mock(
    "@salesforce/label/c.stgReleaseManagementCardTitle",
    () => {
        return { default: ReleaseManagementTitleLabel };
    },
    { virtual: true }
);
jest.mock(
    "@salesforce/label/c.stgBtnReleaseManagement",
    () => {
        return { default: ReleaseManagementButtonLabel };
    },
    { virtual: true }
);
jest.mock(
    "@salesforce/label/c.stgBtnReleaseManagementA11y",
    () => {
        return { default: ReleaseManagementButtonTitle };
    },
    { virtual: true }
);
jest.mock(
    "@salesforce/label/c.stgReleaseGateProgressIndicatorIncomplete",
    () => {
        return { default: ReleaseGateProgressIncompleteLabel };
    },
    { virtual: true }
);
jest.mock(
    "@salesforce/label/c.stgReleaseGateProgressIndicatorComplete",
    () => {
        return { default: ReleaseGateProgressCompleteLabel };
    },
    { virtual: true }
);

describe("c-edc-release-management-card", () => {
    afterEach(() => {
        clearDOM();
    });

    it("Check if the component is accessible and the labels are correct", () => {
        const element = createElement("c-edc-release-management-card", {
            is: EdcReleaseManagementCard,
        });
        getProductRegistryReleaseGateVModels.mockResolvedValue(PRODUCT_REGISTRIES);
        getReleaseGateVModel.mockResolvedValue(RELEASE_GATES);
        document.body.appendChild(element);

        return Promise.resolve().then(async () => {
            await expect(element).toBeAccessible();

            const headingSpan = element.shadowRoot.querySelector("span.slds-text-heading_small");
            expect(headingSpan).not.toBeNull();
            expect(headingSpan.textContent).toBe(ReleaseManagementTitleLabel);

            const btnGoToReleaseManagement = element.shadowRoot.querySelector('[data-qa="btnGoToReleaseManagement"]');
            expect(btnGoToReleaseManagement).not.toBeNull();
            expect(btnGoToReleaseManagement.title).toBe(ReleaseManagementButtonTitle);
            expect(btnGoToReleaseManagement.label).toBe(ReleaseManagementButtonLabel);
        });
    });
    it("Check if the component renders progress ring and bell icon correctly", () => {
        const element = createElement("c-edc-release-management-card", {
            is: EdcReleaseManagementCard,
        });
        getProductRegistryReleaseGateVModels.mockResolvedValue(PRODUCT_REGISTRIES);
        getReleaseGateVModel.mockResolvedValue(RELEASE_GATES);
        document.body.appendChild(element);

        return Promise.resolve().then(async () => {
            await expect(element).toBeAccessible();

            const divProgressRingContainer = element.shadowRoot.querySelector('div[data-qa="progressRingContainer"]');
            expect(divProgressRingContainer).not.toBeNull();
            const progressRing = element.shadowRoot.querySelector("lightning-progress-ring");
            expect(progressRing).not.toBeNull();
            expect(progressRing.value).toBe((2 / 5) * 100.0); // numActiveGates/numTotalGates*100%
            expect(progressRing.variant).toBe("warning");
            const divBell = element.shadowRoot.querySelector('div[data-qa="notificationBell"]');
            expect(divBell).not.toBeNull();
            const progressRingTextContent = element.shadowRoot.querySelector('[data-qa="progressRingContent"]');
            expect(progressRingTextContent).not.toBeNull();
            expect(progressRingTextContent.textContent).toBe(ReleaseGateProgressIncompleteLabel);
        });
    });
    it("Check if the component renders progress ring correctly when all gates are active", () => {
        const element = createElement("c-edc-release-management-card", {
            is: EdcReleaseManagementCard,
        });
        getProductRegistryReleaseGateVModels.mockResolvedValue(PRODUCT_REGISTRIES);
        getReleaseGateVModel.mockResolvedValue(RELEASE_GATES_ACTIVE);
        document.body.appendChild(element);

        return Promise.resolve().then(async () => {
            await expect(element).toBeAccessible();

            const divProgressRingContainer = element.shadowRoot.querySelector('div[data-qa="progressRingContainer"]');
            expect(divProgressRingContainer).not.toBeNull();
            const progressRing = element.shadowRoot.querySelector("lightning-progress-ring");
            expect(progressRing).not.toBeNull();
            expect(progressRing.value).toBe(100.0);
            expect(progressRing.variant).toBe("base-autocomplete");
            const divBell = element.shadowRoot.querySelector('div[data-qa="notificationBell"]');
            expect(divBell).toBeNull();
            const progressRingTextContent = element.shadowRoot.querySelector('[data-qa="progressRingContent"]');
            expect(progressRingTextContent).not.toBeNull();
            expect(progressRingTextContent.textContent).toBe(ReleaseGateProgressCompleteLabel);
        });
    });

    it("Should navigate to release management component", () => {
        const element = createElement("c-edc-release-management-card", {
            is: EdcReleaseManagementCard,
        });
        getProductRegistryReleaseGateVModels.mockResolvedValue(PRODUCT_REGISTRIES);
        getReleaseGateVModel.mockResolvedValue(RELEASE_GATES);
        element.navigationTarget = "testingReleaseManagementContainer";
        document.body.appendChild(element);

        return Promise.resolve()
            .then(async () => {
                await expect(element).toBeAccessible();

                const headingSpan = element.shadowRoot.querySelector("span.slds-text-heading_small");
                expect(headingSpan).not.toBeNull();
                expect(headingSpan.textContent).toBe(ReleaseManagementTitleLabel);

                const btnGoToReleaseManagement = element.shadowRoot.querySelector(
                    '[data-qa="btnGoToReleaseManagement"]'
                );
                expect(btnGoToReleaseManagement).not.toBeNull();
                btnGoToReleaseManagement.click();
                const { pageReference } = getNavigateCalledWith();

                //Get the details
                expect(pageReference.type).toBe("standard__component");
                expect(pageReference.attributes.componentName).toBe("testingReleaseManagementContainer");
            })
            .then(() => {});
    });
});
