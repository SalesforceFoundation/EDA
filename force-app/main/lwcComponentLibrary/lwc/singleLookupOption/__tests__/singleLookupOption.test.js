import { createElement } from 'lwc';
import SingleLookupOption from 'c/singleLookupOption';

const iconViewModel = {
    alternativeText: "An error utility",
    icon: "utility:error",
    label: "title1",
    value: "1",
    index: "0"
}

const avatarViewModel = {
    alternativeText: "An error utility",
    icon: "utility:error",
    initials: "t1",
    imageUrl: "https://www.salesforce.com",
    label: "title1",
    meta: "meta1",
    value: "1",
    index: "0",
    active: false
}

describe('c-single-lookup-option', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders an icon if there is no available image url', () => {
        const element = createElement('c-single-lookup-option', {
            is: SingleLookupOption
        });
        element.viewModel = iconViewModel;
        document.body.appendChild(element);

        return Promise.resolve()
            .then(() => {
                expect(element).toBeAccessible();
                //rendered
                const icon = element.shadowRoot.querySelector('lightning-icon');
                expect(icon).not.toBeNull();
                const labelSpan = element.shadowRoot.querySelector('.slds-listbox__option-text');
                expect(labelSpan.textContent).toBe(iconViewModel.label);

                //not rendered
                const avatar = element.shadowRoot.querySelector('lightning-avatar');
                expect(avatar).toBeNull();
                const meta = element.shadowRoot.querySelector('.slds-listbox__option-meta');
                expect(meta).toBeNull();
            });
    });

    it('renders an avatar if there is an image url', () => {
        const element = createElement('c-single-lookup-option', {
            is: SingleLookupOption
        });
        element.viewModel = avatarViewModel;
        document.body.appendChild(element);
        return Promise.resolve()
            .then(() => {
                //all rendered
                expect(element).toBeAccessible();
                const icon = element.shadowRoot.querySelector('lightning-icon');
                expect(icon).toBeNull();
                const labelSpan = element.shadowRoot.querySelector('.slds-listbox__option-text');
                expect(labelSpan.textContent).toBe(avatarViewModel.label);
                const avatar = element.shadowRoot.querySelector('lightning-avatar');
                expect(avatar).not.toBeNull();
                const meta = element.shadowRoot.querySelector('.slds-listbox__option-meta');
                expect(meta.textContent).toBe(avatarViewModel.meta);
            });
    });

    it('toggles focus class', () => {
        const element = createElement('c-single-lookup-option', {
            is: SingleLookupOption
        });
        element.viewModel = avatarViewModel;
        document.body.appendChild(element);
        return Promise.resolve()
            .then(() => {
                const item = element.shadowRoot.querySelector('div');
                expect(item.className).not.toContain('slds-has-focus')
                avatarViewModel.active = true;
                element.viewModel = avatarViewModel;
            }).then(() => {
                const item = element.shadowRoot.querySelector('div');
                expect(item.className).toContain('slds-has-focus');
            });
    });

    it('sends event after click', () => {
        const element = createElement('c-single-lookup-option', {
            is: SingleLookupOption
        });
        element.viewModel = avatarViewModel;
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('optionconfirm', handler);

        return Promise.resolve()
            .then(() => {
                const item = element.shadowRoot.querySelector('div');
                item.click();
            }).then(() => {
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail).toBe(avatarViewModel.index);
            });
    });

    it('sends event after mouseover', () => {
        const element = createElement('c-single-lookup-option', {
            is: SingleLookupOption
        });
        element.viewModel = avatarViewModel;
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('optionview', handler);

        return Promise.resolve()
            .then(() => {
                let mouseOverEvent = new CustomEvent('mouseover',{
                    bubbles: true
                });
                const item = element.shadowRoot.querySelector('div');
                item.dispatchEvent(mouseOverEvent);
            }).then(() => {
                expect(handler).toHaveBeenCalledTimes(1);
                expect(handler.mock.calls[0][0].detail).toBe(avatarViewModel.index);
            });
    });

});