import { createElement } from 'lwc';
import SingleLookup from 'c/singleLookup';
import SingleLookupOption from "../../singleLookupOption/singleLookupOption";

const ICON_VM = {
    alternativeText: "An error utility",
    icon: "utility:error",
    label: "title1",
    value: "1"
}

const AVATAR_VM = {
    alternativeText: "An error utility",
    icon: "utility:error",
    initials: "AA",
    imageUrl: "https://www.salesforce.com",
    label: "Adam Advisor",
    meta: "meta1",
    value: "00500000012300a",
    active: false
}

const LABEL = 'My Lookup Field';
const REMOVE_LABEL = 'Remove Me';
const PLACEHOLDER = 'Search here';

const OPTIONS_EMPTY = [];
const OPTIONS_TWO = [ICON_VM, AVATAR_VM];

jest.useFakeTimers();

describe('c-single-lookup', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    function flushPromises() {
        // eslint-disable-next-line no-undef
        return new Promise(resolve => setImmediate(resolve));
    }

    //INITIAL LOAD

    it('renders in an empty state with no value', () => {
        const element = createElement('c-single-lookup', {
            is: SingleLookup
        });
        element.label = LABEL;
        element.required = true;
        element.placeholder = PLACEHOLDER;
        element.removeLabel = REMOVE_LABEL;
        document.body.appendChild(element);

        return Promise.resolve()
            .then(() => {
                expect(element).toBeAccessible();
                //rendered: label, input, decorative search icon
                const formLabel = element.shadowRoot.querySelector('label');
                const requiredLabel = '*'+LABEL;
                expect(formLabel.textContent).toBe(requiredLabel);

                const input = element.shadowRoot.querySelector('input');
                expect(input.placeholder).toEqual(PLACEHOLDER);
                const lookupIcon = element.shadowRoot.querySelector('.slds-input__icon_right');
                expect(lookupIcon).not.toBeNull();

                const listbox = element.shadowRoot.querySelector('.slds-dropdown');
                expect(listbox).not.toBeNull();

                //not rendered: avatar, close button, search line
                const avatar = element.shadowRoot.querySelector('lightning-avatar');
                expect(avatar).toBeNull();
                const closeButton = element.shadowRoot.querySelector('button');
                expect(closeButton).toBeNull();
                const searchLine = element.shadowRoot.querySelector('.showSearchLine');
                expect(searchLine).toBeNull();
            });
    });

    it('renders in a populated state with a selected value', () => {
        const element = createElement('c-single-lookup', {
            is: SingleLookup
        });
        element.label = LABEL;
        element.required = false;
        element.placeholder = PLACEHOLDER;
        element.removeLabel = REMOVE_LABEL;
        element.value = AVATAR_VM;
        document.body.appendChild(element);

        return Promise.resolve()
            .then(() => {
                expect(element).toBeAccessible();
                //rendered: label, avatar, close button
                const formLabel = element.shadowRoot.querySelector('label');
                expect(formLabel.textContent).toBe(LABEL);

                const avatar = element.shadowRoot.querySelector('lightning-avatar');
                expect(avatar).not.toBeNull();

                const closeButton = element.shadowRoot.querySelector('button');
                expect(closeButton.title).toEqual(REMOVE_LABEL);

                //not rendered: search, dropdown
                const searchIcon = element.shadowRoot.querySelector('.searchIcon');
                expect(searchIcon).toBeNull();
                const searchBox = element.shadowRoot.querySelector('.slds-dropdown');
                expect(searchBox).toBeNull();
            });
    });

    //UI INTERACTION

    it('clicking clear button removes the selected option', () => {
        const element = createElement('c-single-lookup', {
            is: SingleLookup
        });
        element.label = LABEL;
        element.required = false;
        element.placeholder = PLACEHOLDER;
        element.removeLabel = REMOVE_LABEL;
        element.value = AVATAR_VM;
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('inputchange', handler);

        return Promise.resolve()
            .then(() => {
                const avatarOnLoad = element.shadowRoot.querySelector('lightning-avatar');
                expect(avatarOnLoad).not.toBeNull();
                const closeButton = element.shadowRoot.querySelector('button');
                closeButton.click();
            }).then(() => {
                const avatarAfterClear = element.shadowRoot.querySelector('lightning-avatar');
                expect(avatarAfterClear).toBeNull();
                const closeButton = element.shadowRoot.querySelector('button');
                expect(closeButton).toBeNull();
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail.value).toBeFalsy();
            });
    });

    it('supports keyboard navigation', () => {
        const element = createElement('c-single-lookup', {
            is: SingleLookup
        });
        document.body.appendChild(element);
        element.setOptions(OPTIONS_TWO);
        const handler = jest.fn();
        element.addEventListener('inputchange', handler);
        const input = element.shadowRoot.querySelector('input');

        return Promise.resolve()
            .then(() => {
                const options = element.shadowRoot.querySelectorAll('c-single-lookup-option');
                expect(options).toHaveLength(2);
                input.focus();
                input.dispatchEvent(new KeyboardEvent('keydown', {keyCode: 40}));
            }).then(() => {
                //expect the first element to be selected
                input.dispatchEvent(new KeyboardEvent('keydown', {keyCode: 40}));
            }).then(() => {
                //expect the second element to be selected
                input.dispatchEvent(new KeyboardEvent('keydown', {keyCode: 40}));
            }).then(() => {
                //expect to loop and be on the 1st option
                input.dispatchEvent(new KeyboardEvent('keydown', {keyCode: 38}));
            }).then(() => {
                //hit enter key to select 2nd option (finally!)
                input.dispatchEvent(new KeyboardEvent('keydown', {keyCode: 13}));
            }).then(() => {
                //options are no longer visible - value has been selected
                const options = element.shadowRoot.querySelectorAll('c-single-lookup-option');
                expect(options).toHaveLength(0);
                const avatar = element.shadowRoot.querySelector('lightning-avatar');
                expect(avatar).not.toBeNull();
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail.value).toEqual(OPTIONS_TWO[1]);
            });
    });

    //EVENT INTERACTION
    it('searches based on input text and returns NO results',() => {
        const element = createElement('c-single-lookup', {
            is: SingleLookup
        });
        document.body.appendChild(element);
        const handler = jest.fn();
        element.addEventListener('search', handler);

        return Promise.resolve()
            .then(() => {
                const input = element.shadowRoot.querySelector('input');
                input.value = 'abcd';
                input.dispatchEvent(new CustomEvent('input'));
                jest.runOnlyPendingTimers();
            }).then(() => {
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail.inputValue).toBe('abcd');
            }).then(() => {
                element.setOptions(OPTIONS_EMPTY);
            }).then(() => {
                //input text is retained and no options are visible
                const searchLine = element.shadowRoot.querySelector('.slds-listbox__option-text');
                expect(searchLine.textContent).toEqual('abcd');
                const options = element.shadowRoot.querySelectorAll('c-single-lookup-option');
                expect(options).toHaveLength(0);
            });
    });

    it('searches based on input text and returns results',() => {
        const element = createElement('c-single-lookup', {
            is: SingleLookup
        });
        document.body.appendChild(element);
        const handler = jest.fn();
        element.addEventListener('search', handler);

        return Promise.resolve()
            .then(() => {
                const input = element.shadowRoot.querySelector('input');
                input.value = 'Advisor';
                input.dispatchEvent(new CustomEvent('input'));
                jest.runOnlyPendingTimers();
            }).then(() => {
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail.inputValue).toBe('Advisor');
            }).then(() => {
                element.setOptions(OPTIONS_TWO);
            }).then(() => {
                //input text is retained and no options are visible
                expect(element).toBeAccessible();
                const searchLine = element.shadowRoot.querySelector('.slds-listbox__option-text');
                expect(searchLine.textContent).toEqual('Advisor');
                const options = element.shadowRoot.querySelectorAll('c-single-lookup-option');
                expect(options).toHaveLength(2);
            });
    });

    //END-TO-END
    it('highlights active option when selected by child component', () => {
        const element = createElement('c-single-lookup', {
            is: SingleLookup
        });
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('inputchange', handler);

        return Promise.resolve()
            .then(() => {
                const input = element.shadowRoot.querySelector('input');
                input.value = 'Advisor';
                input.dispatchEvent(new CustomEvent('input'));
                jest.runOnlyPendingTimers();
            }).then(() => {
                element.setOptions(OPTIONS_TWO);
            }).then(() => {
                const options = element.shadowRoot.querySelectorAll('c-single-lookup-option');
                expect(options).toHaveLength(2);
                options[0].dispatchEvent(new CustomEvent('optionview', {detail: 0}));
            }).then(() => {
                //options are still visible (styling is in the child component)
                const options = element.shadowRoot.querySelectorAll('c-single-lookup-option');
                expect(options).toHaveLength(2);
            });
    });

    it('fires change event and clears options when option is selected/confirmed by child', () => {
        const element = createElement('c-single-lookup', {
            is: SingleLookup
        });
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('inputchange', handler);

        return Promise.resolve()
            .then(() => {
                //typing in field
                const input = element.shadowRoot.querySelector('input');
                input.value = 'Advisor';
                input.dispatchEvent(new CustomEvent('input'));
                jest.runOnlyPendingTimers();
            }).then(() => {
                //simulate typing in field
                element.setOptions(OPTIONS_TWO);
            }).then(() => {
                const options = element.shadowRoot.querySelectorAll('c-single-lookup-option');
                expect(options).toHaveLength(2);
                options[1].dispatchEvent(new CustomEvent('optionconfirm', {detail: 1}));
            }).then(() => {
                //options are no longer visible
                const options = element.shadowRoot.querySelectorAll('c-single-lookup-option');
                expect(options).toHaveLength(0);
            }).then(() => {
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail.value).toEqual(OPTIONS_TWO[1]);
            });
    });

});