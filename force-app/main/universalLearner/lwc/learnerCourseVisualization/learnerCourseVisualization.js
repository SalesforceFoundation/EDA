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
            let fieldToDisplay = { fieldKey: fieldDefinition.source + fieldDefinition.fieldName };
            console.log("Field To Display is: " + fieldToDisplay.fieldKey);
            switch (fieldToDisplay.source) {
                //Handle achievements
                case "achievement": {
                    fieldToDisplay.fieldLabel = this.schemaLabels.achievement[fieldToDisplay];
                    fieldToDisplay.fieldValue = this.learnerCourseViewModel.assertion.achievement[fieldToDisplay];
                    break;
                }
                //Handle assertions
                case "assertion": {
                    fieldToDisplay.fieldLabel = this.schemaLabels.assertion[fieldToDisplay];
                    fieldToDisplay.fieldValue = this.learnerCourseViewModel.assertion[fieldToDisplay];
                    break;
                }
                //Handle custom fields
                case "custom": {
                    fieldToDisplay.fieldLabel = this.schemaLabels.custom[fieldToDisplay];
                    fieldToDisplay.fieldValue = this.learnerCourseViewModel[fieldToDisplay];
                    break;
                }
            }
            if (fieldToDisplay.fieldValue === undefined) {
                console.log("Skipping. Field Value undefined for: " + fieldToDisplay.fieldKey);
                return;
            }
            console.log("Pushing. Field is: " + JSON.stringify(fieldToDisplay));

            fieldsToDisplayArray.push(fieldToDisplay);
        });

        return fieldsToDisplayArray;
    }
}
