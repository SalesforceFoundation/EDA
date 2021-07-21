import { createElement } from "lwc";
import EdcReleaseManagementCard from "c/edcReleaseManagementCard";

const ReleaseManagementTitleLabel = "ReleaseManagementTitleLabel is set";
const ReleaseManagementButtonLabel = "ReleaseManagementButtonLabel is set";
const ReleaseManagementButtonTitle = "ReleaseManagementButtonTitle is set";

jest.mock(
    "@salesforce/label/c.stgReleaseManagementTitle",
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

describe("c-edc-release-management-card", () => {
    afterEach(() => {
        clearDOM();
    });

    it("Check if the component is accessible and the labels are correct", () => {
        const element = createElement("c-edc-release-management-card", {
            is: EdcReleaseManagementCard,
        });
        document.body.appendChild(element);

        return Promise.resolve().then(async () => {
            await expect(element).toBeAccessible();

            const headingSpan = element.shadowRoot.querySelector("span.slds-text-heading_small");
            expect(headingSpan).not.toBeNull();
            expect(headingSpan.textContent).toBe(ReleaseManagementTitleLabel);

            const btnGoToReleaseManagement = element.shadowRoot.querySelector(".btnGoToReleaseManagement");
            expect(btnGoToReleaseManagement).not.toBeNull();
            expect(btnGoToReleaseManagement.title).toBe(ReleaseManagementButtonTitle);
            expect(btnGoToReleaseManagement.label).toBe(ReleaseManagementButtonLabel);
        });
    });
});
