import { createElement } from "lwc";
import ReleaseGates from "c/releaseGates";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import getProductRegistryReleaseGateVModels from "@salesforce/apex/ReleaseGateController.getProductRegistryReleaseGateVModels";
import activateReleaseGate from "@salesforce/apex/ReleaseGateController.activateReleaseGate";
import getReleaseGateVModel from "@salesforce/apex/ReleaseGateController.getReleaseGateVModel";

const PRODUCT_REGISTRIES = require("./data/productRegistry.json");
const ACTIVATE_SAVE_MODEL = {
    modalType: "releasegate",
    releaseGateAction: "activate",
    productRegistryName: "EDADemoReleaseGate",
    productName: "SAL",
    productLabel: "Advisor Link",
    releaseGateName: "summer21",
    releaseGateLabel: "Summer '21",
};
const ACTIVATE_RESULT = [
    {
        gateName: "summer21",
        productName: "SAL",
        status: "active",
    },
];
const ACTIVATE_RESULT_ERROR = {
    body: { message: "An internal server error has occurred" },
    ok: false,
    status: 400,
    statusText: "Bad Request",
};

// Mock labels
const stgSuccess = "Success";
jest.mock(
    "@salesforce/label/c.stgSuccess",
    () => {
        return { default: stgSuccess };
    },
    { virtual: true }
);

const stgReleaseGateActivateSuccess = "stgReleaseGateActivateSuccess {0}";
jest.mock(
    "@salesforce/label/c.stgReleaseGateActivateSuccess",
    () => {
        return { default: stgReleaseGateActivateSuccess };
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
jest.mock(
    "@salesforce/apex/ReleaseGateController.activateReleaseGate",
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
        const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    { virtual: true }
);

describe("c-release-gates", () => {
    afterEach(() => {
        clearDOM();
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    it("Check if component is rendered", () => {
        const element = createElement("c-release-gates", {
            is: ReleaseGates,
        });
        document.body.appendChild(element);
        getProductRegistryReleaseGateVModels.emit(PRODUCT_REGISTRIES);

        return Promise.resolve().then(async () => {
            await expect(element).toBeAccessible();

            const releaseGateItems = element.shadowRoot.querySelectorAll("c-release-gate-product");
            expect(releaseGateItems).not.toBeNull();
            expect(releaseGateItems.length).toBe(2);
        });
    });

    it("Check if component is handling product registry errors", () => {
        const element = createElement("c-release-gates", {
            is: ReleaseGates,
        });
        document.body.appendChild(element);
        const errorHandler = jest.fn();
        element.addEventListener("errormessage", errorHandler);

        getProductRegistryReleaseGateVModels.error();

        return Promise.resolve().then(async () => {
            const releaseGateItems = element.shadowRoot.querySelectorAll("c-release-gate-product");
            expect(releaseGateItems).not.toBeNull();
            expect(releaseGateItems.length).toBe(0);

            expect(errorHandler).toHaveBeenCalled();
        });
    });

    it("Check if component is handling getReleaseGateVModel errors", () => {
        const element = createElement("c-release-gates", {
            is: ReleaseGates,
        });
        document.body.appendChild(element);
        const errorMessageHandler = jest.fn();
        element.addEventListener("errormessage", errorMessageHandler);

        getProductRegistryReleaseGateVModels.emit(PRODUCT_REGISTRIES);

        return Promise.resolve()
            .then(async () => {
                await expect(element).toBeAccessible();
                const releaseGateItems = element.shadowRoot.querySelectorAll("c-release-gate-product");
                expect(releaseGateItems).not.toBeNull();
                expect(releaseGateItems.length).toBe(2);
                getReleaseGateVModel.error();
            })
            .then(() => {
                expect(errorMessageHandler).toHaveBeenCalled();
            });
    });

    it("Check if component is handling successful activateReleaseGate", () => {
        const element = createElement("c-release-gates", {
            is: ReleaseGates,
        });
        document.body.appendChild(element);
        const errorMessageHandler = jest.fn();
        element.addEventListener("errormessage", errorMessageHandler);

        // Mock handler for toast event
        const toastHandler = jest.fn();
        element.addEventListener(ShowToastEventName, toastHandler);

        getProductRegistryReleaseGateVModels.emit(PRODUCT_REGISTRIES);

        return Promise.resolve()
            .then(async () => {
                await expect(element).toBeAccessible();
                const releaseGateItems = element.shadowRoot.querySelectorAll("c-release-gate-product");
                expect(releaseGateItems).not.toBeNull();
                expect(releaseGateItems.length).toBe(2);

                activateReleaseGate.mockResolvedValue(ACTIVATE_RESULT);
                element.modalSave(ACTIVATE_SAVE_MODEL);
            })
            .then(() => {
                expect(errorMessageHandler).not.toHaveBeenCalled();
                expect(toastHandler).toHaveBeenCalled();
                expect(toastHandler.mock.calls[0][0].detail.title).toBe(stgSuccess);
                expect(toastHandler.mock.calls[0][0].detail.message).toContain(ACTIVATE_SAVE_MODEL.releaseGateLabel);
            });
    });

    it("Check if component is handling activateReleaseGate error response", () => {
        const element = createElement("c-release-gates", {
            is: ReleaseGates,
        });
        document.body.appendChild(element);
        const errorMessageHandler = jest.fn();
        element.addEventListener("errormessage", errorMessageHandler);

        // Mock handler for toast event
        const toastHandler = jest.fn();
        element.addEventListener(ShowToastEventName, toastHandler);

        getProductRegistryReleaseGateVModels.emit(PRODUCT_REGISTRIES);

        return Promise.resolve()
            .then(async () => {
                const releaseGateItems = element.shadowRoot.querySelectorAll("c-release-gate-product");
                expect(releaseGateItems).not.toBeNull();
                expect(releaseGateItems.length).toBe(2);

                activateReleaseGate.mockRejectedValue(ACTIVATE_RESULT_ERROR);
                element.modalSave(ACTIVATE_SAVE_MODEL);
            })
            .then(() => {
                expect(errorMessageHandler).toHaveBeenCalled();
                expect(toastHandler).not.toHaveBeenCalled();
            });
    });
});
