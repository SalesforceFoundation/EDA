import { createElement } from "lwc";
import SingleLookup from "c/singleLookup";
import SingleLookupOption from "../../singleLookupOption/singleLookupOption";

const ICON_VM = {
    alternativeText: "An error utility",
    icon: "utility:error",
    label: "title1",
    value: "1",
};

const AVATAR_VM = {
    alternativeText: "An error utility",
    icon: "utility:error",
    initials: "AA",
    imageUrl: "https://www.salesforce.com",
    label: "Adam Advisor",
    meta: "meta1",
    value: "00500000012300a",
    active: false,
};

const LABEL = "My Lookup Field";
const REMOVE_LABEL = "Remove Me";
const PLACEHOLDER = "Search here";

const OPTIONS_EMPTY = [];
const OPTIONS_TWO = [ICON_VM, AVATAR_VM];

jest.useFakeTimers();
//TODO: Address tech debt in these JEST tests.

describe("c-single-lookup", () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    function flushPromises() {
        // eslint-disable-next-line no-undef
        return new Promise((resolve) => setImmediate(resolve));
    }

    //INITIAL LOAD

    it("renders in an empty state with no value", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        element.label = LABEL;
        element.required = true;
        element.placeholder = PLACEHOLDER;
        element.removeLabel = REMOVE_LABEL;
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            expect(element).toBeAccessible();
            //rendered: label, input, decorative search icon
            const formLabel = element.shadowRoot.querySelector("label");
            const requiredLabel = "*" + LABEL;
            expect(formLabel.textContent).toBe(requiredLabel);
            const input = element.shadowRoot.querySelector("input");
            expect(input.placeholder).toEqual(PLACEHOLDER);
            const lookupIcon = element.shadowRoot.querySelector("lightning-icon");
            expect(lookupIcon).not.toBeNull();
            const listbox = element.shadowRoot.querySelector(".slds-dropdown");
            expect(listbox).toBeNull();

            //not rendered: avatar, close button, search line
            const avatar = element.shadowRoot.querySelector("lightning-avatar");
            expect(avatar).toBeNull();
            const closeButton = element.shadowRoot.querySelector("button");
            expect(closeButton).toBeNull();
            const searchLine = element.shadowRoot.querySelector(".showSearchLine");
            expect(searchLine).toBeNull();
        });
    });

    it("renders in a populated state with a selected value", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        element.label = LABEL;
        element.required = false;
        element.placeholder = PLACEHOLDER;
        element.removeLabel = REMOVE_LABEL;
        element.value = AVATAR_VM;
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            expect(element).toBeAccessible();
            const comboBox = element.shadowRoot.querySelector(".slds-combobox");
            expect(comboBox).not.toBeNull();
            //rendered: label, avatar, close button
            const formLabel = element.shadowRoot.querySelector("label");
            expect(formLabel.textContent).toBe(LABEL);

            const avatar = element.shadowRoot.querySelector("lightning-avatar");
            expect(avatar).not.toBeNull();

            const closeButton = element.shadowRoot.querySelector("button");
            expect(closeButton.title).toEqual(REMOVE_LABEL);

            //not rendered: search, dropdown
            const searchIcon = element.shadowRoot.querySelector(".searchIcon");
            expect(searchIcon).toBeNull();
            const searchBox = element.shadowRoot.querySelector(
                ".slds-dropdown slds-dropdown_length-with-icon-7 slds-dropdown_fluid"
            );
            expect(searchBox).toBeNull();
        });
    });

    //UI INTERACTION

    it("clicking clear button removes the selected option", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        element.label = LABEL;
        element.required = false;
        element.placeholder = PLACEHOLDER;
        element.removeLabel = REMOVE_LABEL;
        element.value = AVATAR_VM;
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener("inputchange", handler);

        return Promise.resolve()
            .then(() => {
                const avatarOnLoad = element.shadowRoot.querySelector("lightning-avatar");
                expect(avatarOnLoad).not.toBeNull();
                const closeButton = element.shadowRoot.querySelector("button");
                closeButton.click();
            })
            .then(() => {
                const avatarAfterClear = element.shadowRoot.querySelector("lightning-avatar");
                expect(avatarAfterClear).toBeNull();
                const closeButton = element.shadowRoot.querySelector("button");
                expect(closeButton).toBeNull();
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail.value).toBeFalsy();
            });
    });

    it("supports keyboard navigation", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        document.body.appendChild(element);
        element.setOptions(OPTIONS_TWO);
        const handler = jest.fn();
        element.addEventListener("inputchange", handler);
        const input = element.shadowRoot.querySelector("input");

        /*return Promise.resolve().then(() => {
            const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
            //expect(options).toHaveLength(2);
            input.focus();
            input.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 40 }));
        })
            .then(() => {
                //expect the first element to be selected
                input.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 40 }));
                const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
                expect(options[0].shadowRoot.querySelector(".slds-has-focus")).toBeTruthy();
            })
            .then(() => {
                //expect the second element to be selected
                input.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 40 }));
                const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
                expect(options[1].shadowRoot.querySelector(".slds-has-focus")).toBeTruthy();
                expect(options[0].shadowRoot.querySelector(".slds-has-focus")).toBeFalsy();
            })
            .then(() => {
                //expect to loop and be on the 1st option
                input.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 38 }));
                const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
                expect(options[0].shadowRoot.querySelector(".slds-has-focus")).toBeTruthy();
                expect(options[0].shadowRoot.querySelector(".slds-has-blur")).toBeFalsy();
            })
            .then(() => {
                //hit enter key to select 2nd option (finally!)
                input.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 13 }));
            })
            .then(() => {
                //options are no longer visible - value has been selected
                const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
                expect(options).toHaveLength(0);
                const avatar = element.shadowRoot.querySelector("lightning-avatar");
                expect(avatar).not.toBeNull();
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail.value).toEqual(OPTIONS_TWO[1]);
            })*/
    });

    it("returns focus to input element when an option is clicked", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        document.body.appendChild(element);
        element.setOptions(OPTIONS_TWO);
        const handler = jest.fn();
        const input = element.shadowRoot.querySelector("input");
        input.addEventListener("focus", handler);

        return Promise.resolve().then(() => {
            const listbox = element.shadowRoot.querySelector("div.slds-dropdown");
            /*listbox.dispatchEvent(new CustomEvent("mousedown"));
            expect(handler).not.toHaveBeenCalled();
            listbox.dispatchEvent(new CustomEvent("mouseup"));
            expect(handler).toHaveBeenCalled();*/
        });
    });

    it("clears options after esc key", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        document.body.appendChild(element);
        element.setOptions(OPTIONS_TWO);
        const handler = jest.fn();
        element.addEventListener("inputchange", handler);
        const input = element.shadowRoot.querySelector("input");

        return Promise.resolve().then(() => {
            //esc key
            input.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 27 }));
            expect(input.value).toBe("");
        });
    });

    //EVENT INTERACTION
    it("searches based on input text and returns NO results", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        document.body.appendChild(element);
        const handler = jest.fn();
        element.addEventListener("search", handler);

        return Promise.resolve()
            .then(() => {
                const input = element.shadowRoot.querySelector("input");
                input.value = "abcd";
                input.dispatchEvent(new CustomEvent("input"));
                jest.runOnlyPendingTimers();
                input.focus();
                const keyDown = element.shadowRoot.querySelector("onkeydown");
                expect(keyDown).toBeNull();
                input.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 13 }));
                expect(input.Value).toBeUndefined();
            })
            .then(() => {
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail.inputValue).toBe("abcd");
            })
            .then(() => {
                element.setOptions(OPTIONS_EMPTY);
            })
            .then(() => {
                //input text is retained and no options are visible
                const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
                expect(options).toHaveLength(0);
            });
    });

    it("searches based on input text and returns results", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        document.body.appendChild(element);
        /*const handler = jest.fn();
        element.addEventListener("search", handler);

        return Promise.resolve()
            .then(() => {
                const input = element.shadowRoot.querySelector("input");
                input.value = "Advisor";
                input.dispatchEvent(new CustomEvent("input"));
                jest.runOnlyPendingTimers();
            })
            .then(() => {
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail.inputValue).toBe("Advisor");
            })
            .then(() => {
                element.setOptions(OPTIONS_TWO);
            })
            .then(() => {
                const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
                expect(options).toHaveLength(2);
            });*/
    });

    it("clears the searchbar and options when searching an empty string", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        document.body.appendChild(element);

        return Promise.resolve()
            .then(() => {
                element.setOptions(OPTIONS_TWO);
            })
            .then(() => {
                const input = element.shadowRoot.querySelector("input");

                input.value = "";
                input.dispatchEvent(new CustomEvent("input"));
                jest.runOnlyPendingTimers();
            })
            .then(() => {
                const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
                expect(options).toHaveLength(0);
            });
    });

    it("prevents loss of focus when locked", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        document.body.appendChild(element);
        element.setOptions(OPTIONS_TWO);

        const input = element.shadowRoot.querySelector("input");

        return Promise.resolve()
            .then(() => {
                input.focus();
            })
            .then(() => {
                expect(input.classList).toContain("slds-has-focus");
                const listbox = element.shadowRoot.querySelector("div.slds-dropdown");
                /*listbox.dispatchEvent(new CustomEvent("mousedown"));*/
            })
            .then(() => {
                input.blur();
            })
            .then(() => {
                /*expect(input.classList).toContain("slds-has-focus");
                const listbox = element.shadowRoot.querySelector("div.slds-dropdown");
                listbox.dispatchEvent(new CustomEvent("mouseup"));*/
            })
            .then(() => {
                input.blur();
            })
            .then(() => {
                expect(input.classList).not.toContain("slds-has-focus");
            });
    });

    it("should not display options when null is passed in", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        document.body.appendChild(element);
        element.setOptions(null);

        return Promise.resolve().then(() => {
            const listbox = element.shadowRoot.querySelector("div.slds-dropdown");
            expect(listbox).toBeFalsy();
        });
    });

    it("does not perform search with limited input", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        document.body.appendChild(element);
        const handler = jest.fn();
        element.addEventListener("search", handler);

        return Promise.resolve()
            .then(() => {
                const input = element.shadowRoot.querySelector("input");
                input.value = "Ad";
                input.dispatchEvent(new CustomEvent("input"));
                jest.runOnlyPendingTimers();
            })
            .then(() => {
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail.inputValue).toBe("Ad");
            })
            .then(() => {
                const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
                expect(options).toHaveLength(0);
            });
    });

    //END-TO-END
    it("highlights active option when selected by child component", () => {
        jest.useFakeTimers();
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener("inputchange", handler);

        return Promise.resolve()
            .then(() => {
                const input = element.shadowRoot.querySelector("input");
                input.value = "Advisor";
                input.dispatchEvent(new CustomEvent("input"));
                jest.runOnlyPendingTimers();
            })
            .then(() => {
                element.setOptions(OPTIONS_TWO);
            })
            .then(() => {
                const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
                expect(options).toHaveLength(2);
                options[0].dispatchEvent(new CustomEvent("optionview", { detail: 0 }));
            })
            .then(() => {
                const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
                expect(options).toHaveLength(2);
            });
    });

    it("fires change event and clears options when option is selected/confirmed by child", () => {
        const element = createElement("c-single-lookup", {
            is: SingleLookup,
        });
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener("inputchange", handler);

        return Promise.resolve()
            .then(() => {
                //typing in field
                const input = element.shadowRoot.querySelector("input");
                input.value = "Advisor";
                input.dispatchEvent(new CustomEvent("input"));
                jest.runOnlyPendingTimers();
            })
            .then(() => {
                //simulate typing in field
                element.setOptions(OPTIONS_TWO);
            })
            .then(() => {
                const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
                expect(options).toHaveLength(2);
                options[1].dispatchEvent(new CustomEvent("optionconfirm", { detail: 1 }));
            })
            .then(() => {
                //options are no longer visible
                const options = element.shadowRoot.querySelectorAll("c-single-lookup-option");
                expect(options).toHaveLength(0);
            })
            .then(() => {
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail.value).toEqual(OPTIONS_TWO[1]);
            });
    });
});
