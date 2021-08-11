import { LightningElement, api } from "lwc";

const FIELD_DEFINITIONS = [
    {
        source: "assertion",
        fieldName: "term",
    },
];

export default class LearnerCourseVisualization extends LightningElement {
    @api learnerCourseViewModel;
    @api schemaLabels;

    get vModelDebug() {
        return JSON.stringify(this.learnerCourseViewModel);
    }

    get schemaLabelDebug() {
        return JSON.stringify(this.schemaLabels);
    }

    get fieldsToDisplay() {
        let fieldsToDisplayArray = [];

        FIELD_DEFINITIONS.forEach((fieldDefinition) => {
            let fieldName = fieldDefinition.fieldName;
            //Field key is an obnoxious requirement for loops
            let fieldToDisplay = { fieldKey: fieldDefinition.source + fieldName };
            switch (fieldDefinition.source) {
                //Handle achievements
                case "achievement": {
                    fieldToDisplay.fieldLabel = this.schemaLabels.achievement[fieldName];
                    fieldToDisplay.fieldValue = this.learnerCourseViewModel.assertion.achievement[fieldName];
                    break;
                }
                //Handle assertions
                case "assertion": {
                    fieldToDisplay.fieldLabel = this.schemaLabels.assertion[fieldName];
                    fieldToDisplay.fieldValue = this.learnerCourseViewModel.assertion[fieldName];
                    break;
                }
                //Handle custom fields
                case "custom": {
                    fieldToDisplay.fieldLabel = this.schemaLabels.custom[fieldName];
                    fieldToDisplay.fieldValue = this.learnerCourseViewModel[fieldName];
                    break;
                }
            }
            if (fieldToDisplay.fieldValue === undefined) {
                return;
            }
            fieldsToDisplayArray.push(fieldToDisplay);
        });

        return fieldsToDisplayArray;
    }
}
