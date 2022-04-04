import { createElement } from "lwc";
import ReleaseGateItem from "c/releaseGateItem";

const RELEASE_GATES = require("./data/releaseGates.json");
const stgReleaseGateActivate = "stgReleaseGateActivate {0}";
const stgBtnReleaseGateActivate = "stgBtnReleaseGateActivate";
const stgReleaseGateInProgress = "stgReleaseGateInProgress {0}";

jest.mock(
    "@salesforce/label/c.stgReleaseGateActivate",
    () => {
        return { default: stgReleaseGateActivate };
    },
    { virtual: true }
);

jest.mock(
    "@salesforce/label/c.stgBtnReleaseGateActivate",
    () => {
        return { default: stgBtnReleaseGateActivate };
    },
    { virtual: true }
);

jest.mock(
    "@salesforce/label/c.stgReleaseGateInProgress",
    () => {
        return { default: stgReleaseGateInProgress };
    },
    { virtual: true }
);

describe("c-release-gate-item", () => {
    afterEach(() => {
        clearDOM();
    });

    it("Check if the component is accessible and data bindings are valid with INACTIVE gate", () => {
        const element = createElement("c-release-gate-item", {
            is: ReleaseGateItem,
        });
        let gate = RELEASE_GATES[0].gates[0];
        element.product = RELEASE_GATES[0].product;
        element.gate = gate;
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener("releasegatemodalrequest", handler);

        return Promise.resolve()
            .then(async () => {
                await expect(element).toBeAccessible();

                const headingSpan = element.shadowRoot.querySelector(".slds-text-heading_small");
                expect(headingSpan).not.toBeNull();
                expect(headingSpan.textContent).toBe(gate.label);

                const dueDate = element.shadowRoot.querySelector(".dueDateClass");
                expect(dueDate.value).toBe(gate.dueDate);

                const dueDateInfo = element.shadowRoot.querySelector(".dueDateInfo");
                expect(dueDateInfo).not.toBeNull();

                const featureHeader = element.shadowRoot.querySelector(".featureLabel");
                expect(featureHeader.innerHTML).toBe(gate.features[0].label);

                const featureDescription = element.shadowRoot.querySelector(".featureDescription");
                expect(featureDescription.innerHTML).toBe(gate.features[0].description);

                const featureLink = element.shadowRoot.querySelector(".featureLink");
                expect(featureLink.innerHTML).toContain(gate.features[0].helpLinkLabel);

                const btnActivate = element.shadowRoot.querySelector('[data-qa="gateEnableBtn"]');
                expect(btnActivate).not.toBeNull();
                expect(btnActivate.title).toContain(gate.label);
                expect(btnActivate.label).toBe(stgBtnReleaseGateActivate);
                btnActivate.click();
            })
            .then(() => {
                expect(handler).toHaveBeenCalled();
                expect(handler.mock.calls[0][0].detail.releaseGateName).toBe(gate.name);
            });
    });

    it("Check if the component bindings are valid with ACTIVE gate", () => {
        const element = createElement("c-release-gate-item", {
            is: ReleaseGateItem,
        });
        let gate = RELEASE_GATES[0].gates[1];
        element.product = RELEASE_GATES[0].product;
        element.gate = gate;
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener("releasegatemodalrequest", handler);

        return Promise.resolve().then(async () => {
            await expect(element).toBeAccessible();

            const headingSpan = element.shadowRoot.querySelector(".slds-text-heading_small");
            expect(headingSpan).not.toBeNull();
            expect(headingSpan.textContent).toBe(gate.label);

            const activatedOnElement = element.shadowRoot.querySelector(".activatedOnClass");
            expect(activatedOnElement).not.toBeNull();

            const dueDate = element.shadowRoot.querySelector(".dueDateClass");
            expect(dueDate).toBeNull();

            const btnActivate = element.shadowRoot.querySelector('[data-qa="gateEnableBtn"]');
            expect(btnActivate).toBeNull();
        });
    });

    it("Check if the component bindings are valid with DISABLED gate", () => {
        const element = createElement("c-release-gate-item", {
            is: ReleaseGateItem,
        });
        let gate = RELEASE_GATES[1].gates[0];
        element.product = RELEASE_GATES[1].product;
        element.gate = gate;
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener("releasegatemodalrequest", handler);

        return Promise.resolve().then(async () => {
            await expect(element).toBeAccessible();

            const headingSpan = element.shadowRoot.querySelector(".slds-text-heading_small");
            expect(headingSpan).not.toBeNull();
            expect(headingSpan.textContent).toBe(gate.label);

            const gateStatusRow = element.shadowRoot.querySelector('[data-qa="gateStatusRow"]');
            expect(gateStatusRow).toBeNull();

            const btnActivate = element.shadowRoot.querySelector('[data-qa="gateEnableBtn"]');
            expect(btnActivate).toBeNull();
        });
    });

    it("Check if the component bindings are valid with INPROGRESS gate", () => {
        const element = createElement("c-release-gate-item", {
            is: ReleaseGateItem,
        });
        let gate = RELEASE_GATES[1].gates[1];
        element.product = RELEASE_GATES[1].product;
        element.gate = gate;
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener("releasegatemodalrequest", handler);

        return Promise.resolve().then(async () => {
            await expect(element).toBeAccessible();

            const headingSpan = element.shadowRoot.querySelector(".slds-text-heading_small");
            expect(headingSpan).not.toBeNull();
            expect(headingSpan.textContent).toBe(gate.label);

            const gateStatusRow = element.shadowRoot.querySelector('[data-qa="gateStatusRow"]');
            expect(gateStatusRow).not.toBeNull();

            const btnActivate = element.shadowRoot.querySelector('[data-qa="gateEnableBtn"]');
            expect(btnActivate).toBeNull();

            const inProgressStatusText = element.shadowRoot.querySelector('[data-qa="inProgressLabel"]');
            expect(inProgressStatusText).not.toBeNull();
            expect(inProgressStatusText.innerHTML).toContain(gate.label);
        });
    });

    it("Check component state change from INACTIVE to INPROGRESS", () => {
        const element = createElement("c-release-gate-item", {
            is: ReleaseGateItem,
        });
        let gate = RELEASE_GATES[0].gates[0];
        element.product = RELEASE_GATES[0].product;
        element.gate = gate;
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener("releasegatemodalrequest", handler);

        return Promise.resolve()
            .then(async () => {
                await expect(element).toBeAccessible();

                const headingSpan = element.shadowRoot.querySelector(".slds-text-heading_small");
                expect(headingSpan).not.toBeNull();
                expect(headingSpan.textContent).toBe(gate.label);

                const dueDate = element.shadowRoot.querySelector(".dueDateClass");
                expect(dueDate.value).toBe(gate.dueDate);

                const btnActivate = element.shadowRoot.querySelector('[data-qa="gateEnableBtn"]');
                expect(btnActivate).not.toBeNull();
                expect(btnActivate.title).toContain(gate.label);

                element.gateStatus = "inprogress";
                expect(element.gateStatus).toBe("inprogress");
            })
            .then(() => {
                const headingSpan = element.shadowRoot.querySelector(".slds-text-heading_small");
                expect(headingSpan).not.toBeNull();
                expect(headingSpan.textContent).toBe(gate.label);

                const gateStatusRow = element.shadowRoot.querySelector('[data-qa="gateStatusRow"]');
                expect(gateStatusRow).not.toBeNull();

                const btnActivate = element.shadowRoot.querySelector('[data-qa="gateEnableBtn"]');
                expect(btnActivate).toBeNull();

                const inProgressStatusText = element.shadowRoot.querySelector('[data-qa="inProgressLabel"]');
                expect(inProgressStatusText).not.toBeNull();
                expect(inProgressStatusText.innerHTML).toContain(gate.label);
            });
    });

    it("should send event to activate release gate when activated", () => {
        const element = createElement("c-release-gate-item", {
            is: ReleaseGateItem,
        });
        let gate = RELEASE_GATES[0].gates[0];
        element.product = RELEASE_GATES[0].product;
        element.gate = gate;
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener("releasegatemodalrequest", handler);

        return Promise.resolve().then(async () => {
            const btnActivate = element.shadowRoot.querySelector('[data-qa="gateEnableBtn"]');
            expect(btnActivate).not.toBeNull();
            expect(btnActivate.title).toContain(gate.label);
            btnActivate.click();
            expect(handler).toHaveBeenCalled();
            expect(handler.mock.calls[0][0].detail.releaseGateName).toBe(gate.name);
            expect(handler.mock.calls[0][0].detail.releaseGateAction).toBe("activate");
        });
    });
});
