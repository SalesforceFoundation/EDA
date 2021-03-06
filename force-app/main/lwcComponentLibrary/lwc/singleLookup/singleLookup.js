import { LightningElement, api, track } from "lwc";

const INPUT_DELAY = 150;

const INPUT_CLASS = "slds-input slds-combobox__input";
const COMBOBOX_CLASS = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
const CONTAINER_CLASS = "slds-combobox_container";
const COMBOBOX_FORM_ELEMENT_CLASS = "slds-combobox__form-element slds-input-has-icon";
const DATA_QA_LOCATOR = "combobox ";

const KEY_ENTER = 13;
const KEY_ESCAPE = 27;
const KEY_UP = 38;
const KEY_DOWN = 40;
export default class SingleLookup extends LightningElement {
    focused = false;
    inputValue = "";
    optionIndex = -1;
    blurLock = false;
    valueLoaded = false;

    @api required;
    @api label;
    @api removeLabel;
    @api placeholder;
    @api value;
    @api disabled;
    @track options = [];
    @track inputDelayTimeout = 0;

    @api setOptions(optionsToSet) {
        this.options = optionsToSet;
        this.clearCurrentOption();
        this.value = undefined;

        if (!this.options) {
            return;
        }

        for (let i = 0; i < this.options.length; i++) {
            this.options[i].index = i;
        }
    }

    @api setValue(valueToSet) {
        this.value = valueToSet;

        if (!this.value) {
            this.inputValue = undefined;
        } else {
            this.inputValue = this.value.label;
        }
    }

    get isExpanded() {
        if (!this.focused || !this.options || !!this.value) {
            return false;
        }

        return true;
    }

    get qaLocator() {
        if (this.label) {
            return DATA_QA_LOCATOR + this.label;
        } else {
            return DATA_QA_LOCATOR;
        }
    }

    get showClearSelection() {
        return !!this.value && !this.disabled;
    }

    get showOptions() {
        return !!this.inputValue && !this.value;
    }

    get showResults() {
        return this.inputValue && !this.value;
    }

    get comboboxClass() {
        if (!this.focused) {
            return COMBOBOX_CLASS;
        }

        return COMBOBOX_CLASS + " slds-is-open";
    }

    get inputClass() {
        if (this.focused && this.value) {
            return INPUT_CLASS + " slds-has-focus slds-combobox__input-value ";
        } else if (this.focused) {
            return INPUT_CLASS + " slds-has-focus";
        } else if (this.value) {
            return INPUT_CLASS + " slds-combobox__input-value";
        }

        return INPUT_CLASS;
    }

    get containerClass() {
        if (!this.value) {
            return CONTAINER_CLASS;
        }
        return CONTAINER_CLASS + " slds-has-selection";
    }

    get comboboxFormElementClass() {
        if (!this.value) {
            return COMBOBOX_FORM_ELEMENT_CLASS + " slds-input-has-icon_right";
        }
        return COMBOBOX_FORM_ELEMENT_CLASS + " slds-input-has-icon_left-right";
    }

    handleBlur() {
        if (this.blurLock) {
            return;
        }
        this.focused = false;
    }

    handleFocus() {
        this.focused = true;
        this.clearCurrentOption();
    }

    handleInput(event) {
        window.clearTimeout(this.inputDelayTimeout);
        this.inputValue = event.target.value;

        if (!this.inputValue) {
            this.inputValue = "";
        }

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.inputDelayTimeout = setTimeout(() => {
            if (!this.inputValue) {
                this.clearOptions();
                this.clearCurrentOption();
                return;
            }

            this.dispatchSearchEvent(this.inputValue);
            //mutability is a good thing
            this.setOptions(JSON.parse(JSON.stringify(this.options)));
        }, INPUT_DELAY);
    }

    handleKeydown(event) {
        if (!this.options) {
            return;
        }

        switch (event.keyCode) {
            case KEY_ENTER:
                event.preventDefault();
                this.confirmSelection(this.optionIndex);
                break;
            case KEY_ESCAPE:
                event.preventDefault();
                this.blurLock = false;
                this.clearOptions();
                this.clearValues();
                this.resetFocus();
                break;
            case KEY_UP:
                event.preventDefault();
                this.selectOptionUp();
                break;
            case KEY_DOWN:
                event.preventDefault();
                this.selectOptionDown();
                break;
        }
    }

    handleMouseDown(event) {
        this.blurLock = true;
    }

    handleMouseUp(event) {
        this.blurLock = false;
        this.template.querySelector("input").focus();
    }

    handleOptionConfirm(event) {
        this.confirmSelection(event.detail);
    }

    handleOptionSelection(event) {
        this.setCurrentOption(event.detail);
    }

    handleRemoveButtonClick(event) {
        this.clearOptions();
        this.clearValues();
        this.clearCurrentOption();
        this.dispatchChangeEvent();
        this.removeInputReadOnly();
        this.resetFocus();
    }

    resetFocus() {
        //reset focus back to the input field for better accessibility
        let inputField = this.template.querySelector("input");
        if (inputField) {
            inputField.focus();
        }
    }

    selectOptionDown() {
        if (this.optionIndex >= this.options.length - 1) {
            this.setCurrentOption(0);
            return;
        }

        this.setCurrentOption(this.optionIndex + 1);
    }

    selectOptionUp() {
        if (this.optionIndex <= 0) {
            this.setCurrentOption(this.options.length - 1);
            return;
        }

        this.setCurrentOption(this.optionIndex - 1);
    }

    confirmSelection(confirmOption) {
        if (confirmOption < 0) {
            return;
        }

        this.value = this.options[confirmOption];
        this.inputValue = this.options[confirmOption].label;
        this.setInputReadOnly();
        this.dispatchChangeEvent();
    }

    clearValues() {
        this.value = undefined;
        this.inputValue = "";
    }

    clearOptions() {
        this.options = [];
    }

    clearCurrentOption() {
        this.optionIndex = -1;
        this.removeActiveDescendant();
    }

    setCurrentOption(optionIndex) {
        this.deactivateCurrentOption();
        this.optionIndex = optionIndex;
        this.activateCurrentOption();
    }

    activateCurrentOption() {
        if (this.optionIndex >= 0) {
            this.options[this.optionIndex].active = true;
            this.setActiveDescendent();
        }
    }

    deactivateCurrentOption() {
        if (this.optionIndex >= 0) {
            this.options[this.optionIndex].active = undefined;
        }
    }

    setActiveDescendent() {
        const lookupOptions = this.template.querySelectorAll("c-single-lookup-option");
        const lookupOptionId = lookupOptions[this.optionIndex].getLookupId();

        const inputElement = this.template.querySelector("input");
        inputElement.setAttribute("aria-activedescendant", lookupOptionId);
    }

    removeActiveDescendant() {
        const inputElement = this.template.querySelector("input");
        inputElement.removeAttribute("aria-activedescendant");
    }

    setInputReadOnly() {
        const inputElement = this.template.querySelector("input");
        inputElement.setAttribute("readonly", "");
    }

    removeInputReadOnly() {
        const inputElement = this.template.querySelector("input");
        inputElement.removeAttribute("readonly", "");
    }

    dispatchSearchEvent(inputValue) {
        const searchEvent = new CustomEvent("search", {
            detail: { inputValue },
        });
        this.dispatchEvent(searchEvent);
    }

    dispatchChangeEvent() {
        const changeEvent = new CustomEvent("inputchange", {
            detail: { value: this.value ? this.value : "" },
        });
        this.dispatchEvent(changeEvent);
    }

    connectedCallback() {
        if (this.valueLoaded || !this.value) {
            return;
        }

        this.inputValue = this.value.label;
        this.valueLoaded = true;
    }
}
