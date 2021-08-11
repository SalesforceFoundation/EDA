import { createElement } from "lwc";
import { registerApexTestWireAdapter } from "@salesforce/sfdx-lwc-jest";

import applicationSettings from "c/applicationSettings";

import getApplicationSettingsVModel from "@salesforce/apex/ApplicationSettingsController.getApplicationSettingsVModel";

const getApplicationSettingsModel = registerApexTestWireAdapter(getApplicationSettingsVModel);

describe("c-application-settings", () => {
    let element;
    beforeEach(() => {
        element = createElement("c-application-settings", {
            is: applicationSettings,
        });
        document.body.appendChild(element);
    });
    afterEach(() => {
        global.clearDOM();
        jest.clearAllMocks();
    });

    describe("On initial load", () => {
        it("should not display a toggle before model loads", () => {
            return Promise.resolve().then(() => {
                const toggle = element.shadowRoot.querySelector("c-settings-row-input");
                expect(toggle).toBeNull();
            });
        });

        it("should show a checked toggle", () => {
            getApplicationSettingsModel.emit({ enableApplicationWindowValidation: true });

            return Promise.resolve().then(() => {
                const toggle = element.shadowRoot.querySelector("c-settings-row-input");
                expect(toggle.value).toBe(true);
            });
        });

        it("should show an unchecked toggle", () => {
            getApplicationSettingsModel.emit({ enableApplicationWindowValidation: false });

            return Promise.resolve().then(() => {
                const toggle = element.shadowRoot.querySelector("c-settings-row-input");
                expect(toggle.value).toBe(false);
            });
        });

        it("should show a disabled toggle", () => {
            getApplicationSettingsModel.emit({ enableApplicationWindowValidation: true });

            return Promise.resolve().then(() => {
                const toggle = element.shadowRoot.querySelector("c-settings-row-input");
                expect(toggle.disabled).toBe(true);
            });
        });
    });

    describe("When clicking the edit/cancel buttons", () => {
        let saveCanvas;
        beforeEach(() => {
            getApplicationSettingsModel.emit({ enableApplicationWindowValidation: true });
            saveCanvas = element.shadowRoot.querySelector("c-settings-save-canvas");
        });
        it("should set the component to edit mode", () => {
            saveCanvas.dispatchEvent(new CustomEvent("settingseditmodechange", { detail: false }));

            return Promise.resolve().then(() => {
                const toggle = element.shadowRoot.querySelector("c-settings-row-input");
                expect(toggle.disabled).toBeFalsy();
            });
        });

        it("should set the component to read mode", () => {
            saveCanvas.dispatchEvent(new CustomEvent("settingseditmodechange", { detail: true }));

            return Promise.resolve().then(() => {
                const toggle = element.shadowRoot.querySelector("c-settings-row-input");
                expect(toggle.disabled).toBe(true);
            });
        });
    });

    describe("When clicking the save button", () => {
        let saveCanvas;
        beforeEach(() => {
            getApplicationSettingsModel.emit({ enableApplicationWindowValidation: true });

            saveCanvas = element.shadowRoot.querySelector("c-settings-save-canvas");
        });

        it("should update the canvas wrapper", () => {
            let changeHandlerMock = jest.fn();
            saveCanvas.handleHierarchySettingsChange = changeHandlerMock;

            saveCanvas.dispatchEvent(new CustomEvent("settingseditmodechange", { detail: false }));

            return Promise.resolve()
                .then(() => {
                    const toggle = element.shadowRoot.querySelector("c-settings-row-input");
                    toggle.dispatchEvent(new CustomEvent("settingsinputchange", { detail: { value: false } }));
                })
                .then(() => {
                    expect(changeHandlerMock).toHaveBeenCalledWith({
                        settingsName: "Application_Window_Validation__c",
                        settingsType: "boolean",
                        settingsValue: false,
                    });
                });
        });
    });

    it("should be accessible", () => {
        return Promise.resolve().then(async () => {
            //TODO: Address underlying A11y issue in Settings Save Canvas focus
            //await expect(element).toBeAccessible();
        });
    });
});
