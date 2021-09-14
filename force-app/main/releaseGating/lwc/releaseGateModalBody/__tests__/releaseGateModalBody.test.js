import { createElement } from "lwc";
import ReleaseGateModalBody from "c/releaseGateModalBody";

const stgReleaseGateActivateModalBody = "stgReleaseGateActivateModalBody {0}";
jest.mock(
    "@salesforce/label/c.stgReleaseGateActivateModalBody",
    () => {
        return { default: stgReleaseGateActivateModalBody };
    },
    { virtual: true }
);

describe("c-release-gate-modal-body", () => {
    afterEach(() => {
        clearDOM();
    });

    it("Check if component is rendered correctly in active mode", () => {
        const element = createElement("c-release-gate-modal-body", {
            is: ReleaseGateModalBody,
        });
        element.releaseGateAction = "activate";
        let releaseGateLabel = "Test release gate";
        let productLabel = "Test product";
        element.releaseGateLabel = releaseGateLabel;
        element.productLabel = productLabel;
        document.body.appendChild(element);
        return Promise.resolve().then(async () => {
            await expect(element).toBeAccessible();

            const modalBody = element.shadowRoot.querySelector(".releaseGateModalBody");
            expect(modalBody).not.toBeNull();
            expect(modalBody.textContent).toBe(`stgReleaseGateActivateModalBody ${productLabel} ${releaseGateLabel}`);
        });
    });
});
