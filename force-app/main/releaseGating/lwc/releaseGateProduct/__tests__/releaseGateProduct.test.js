import { createElement } from "lwc";
import ReleaseGateProduct from "c/releaseGateProduct";
import getReleaseGateVModel from "@salesforce/apex/ReleaseGateController.getReleaseGateVModel";

const RELEASE_GATES = require("./data/releaseGates.json");

// Mock getReleaseGateVModel Apex wire adapter
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

describe("c-release-gate-product", () => {
    afterEach(() => {
        clearDOM();
    });

    it("Check if component is created and the data is bound correctly", () => {
        const element = createElement("c-release-gate-product", {
            is: ReleaseGateProduct,
        });
        document.body.appendChild(element);
        const handler = jest.fn();
        element.addEventListener("releasegateloadsuccess", handler);

        getReleaseGateVModel.emit(RELEASE_GATES);
        const releaseProduct = RELEASE_GATES[0];

        return Promise.resolve()
            .then(async () => {
                await expect(element).toBeAccessible();

                const headingSpan = element.shadowRoot.querySelector(".releaseGateProductTitle");
                expect(headingSpan).not.toBeNull();
                expect(headingSpan.textContent).toBe(releaseProduct.product.label);

                const releaseGateItems = element.shadowRoot.querySelectorAll(".releaseGateList");
                expect(releaseGateItems).not.toBeNull();
                expect(releaseGateItems.length).toBe(RELEASE_GATES.length);

                expect(handler).toHaveBeenCalled();
            })
            .then(() => {
                //Testing setReleaseGateStatus
                const releaseGateItems = element.shadowRoot.querySelectorAll("c-release-gate-item");
                expect(releaseGateItems.length).toBe(
                    RELEASE_GATES.reduce((a, b) => {
                        return a + b.gates.length;
                    }, 0)
                );
                expect(releaseGateItems[0].gateStatus).toBe("inactive");
                element.setReleaseGateStatus("SAL", "summer21", "inprogress");
                expect(releaseGateItems[0].gateStatus).toBe("inprogress");
            });
    });

    it("Check if component is handling an error response", () => {
        const element = createElement("c-release-gate-product", {
            is: ReleaseGateProduct,
        });
        document.body.appendChild(element);
        const successhandler = jest.fn();
        element.addEventListener("releasegateloadsuccess", successhandler);
        const errorhandler = jest.fn();
        element.addEventListener("releasegateloaderror", errorhandler);

        getReleaseGateVModel.error();

        return Promise.resolve().then(async () => {
            const headingSpan = element.shadowRoot.querySelector(".releaseGateProductTitle");
            expect(headingSpan).toBeNull();

            const releaseGateItems = element.shadowRoot.querySelectorAll(".releaseGateList");
            expect(releaseGateItems.length).toBe(0);

            expect(errorhandler).toHaveBeenCalled();
            expect(successhandler).not.toHaveBeenCalled();
        });
    });
});
