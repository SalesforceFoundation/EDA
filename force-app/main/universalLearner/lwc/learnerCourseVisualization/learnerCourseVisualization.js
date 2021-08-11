import { LightningElement, api } from "lwc";

//Note, this is repeatable, but the future state of individual learner achievements with actions means we want to separate them for now.
const FIELD_DEFINITIONS = [
    "assertion.achievement.humanCode",
    "custom.status",
    "custom.grade",
    "assertion.creditsEarned",
    "assertion.achievement.creditsAvailable",
    "assertion.achievement.fieldOfStudy",
    "assertion.achievement.level",
    "assertion.term",
    "assertion.activityStartDate",
    "assertion.activityEndDate",
    "custom.verificationStatus",
    "custom.verificationDate",
    "assertion.achievement.issuer.name",
    "assertion.achievement.description",
];

const SECTION_CLOSED_CLASS = "slds-accordion__section";
const SECTION_OPEN_CLASS = "slds-accordion__section  slds-is-open";

export default class LearnerCourseVisualization extends LightningElement {
    @api learnerCourseViewModel;
    @api schemaLabels;
    sectionIsOpen = false;

    get sectionIsHidden() {
        if (!this.sectionIsOpen) {
            return true;
        }

        return undefined;
    }

    get sectionClass() {
        if (!this.sectionIsOpen) {
            return SECTION_CLOSED_CLASS;
        }

        return SECTION_OPEN_CLASS;
    }

    get sectionIcon() {
        if (!this.sectionIsOpen) {
            return this.iconReference.collapsedIcon;
        }

        return this.iconReference.expandedIcon;
    }

    get fieldsToDisplay() {
        //Consider moving this to a shared JS library for other components
        let fieldsToDisplayArray = [];

        console.log("Processing field definitions");

        FIELD_DEFINITIONS.forEach((fieldDefinition) => {
            //Field key is an obnoxious requirement for loops
            console.log("Processing field: " + fieldDefinition);
            let fieldToDisplay = { fieldKey: fieldDefinition };
            let parsedFieldName = this.parseFieldName(fieldDefinition);

            fieldToDisplay.fieldValue = this.getNestedStringFromViewModel(this.learnerCourseViewModel, parsedFieldName);

            if (fieldToDisplay.fieldValue === undefined) {
                return;
            }

            fieldToDisplay.fieldLabel = this.getNestedStringFromViewModel(this.schemaLabels, parsedFieldName);
            fieldsToDisplayArray.push(fieldToDisplay);
        });

        return fieldsToDisplayArray;
    }

    parseFieldName(fieldName) {
        if (fieldName.indexOf(".") === -1) {
            return [fieldName];
        }

        return fieldName.split(".");
    }

    getNestedStringFromViewModel(viewModel, fieldNameArray) {
        let nestedValue = viewModel;

        fieldNameArray.forEach((nestedFieldName) => {
            nestedValue = nestedValue[nestedFieldName];
        });

        return nestedValue;
    }

    handleSectionHeaderButtonClick() {
        this.sectionIsOpen = !this.sectionIsOpen;
    }
}
