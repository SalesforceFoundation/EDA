import { createElement } from "lwc";
import EducationCloudSettings from "c/educationCloudSettings";

describe("c-education-cloud-settings", () => {
    afterEach(() => {
        clearDOM();
    });

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
            expect(containerName.endsWith("edcReleaseManagementContainer")).toBeTruthy();
        });
    });
});
