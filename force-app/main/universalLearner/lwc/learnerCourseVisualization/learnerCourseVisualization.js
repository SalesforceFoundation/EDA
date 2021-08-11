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

    get fieldsToDisplay() {
        let fieldsToDisplayArray = [];

        fieldDefinitions.forEach((fieldDefinition) => {
            let fieldToDisplay = { fieldKey: fieldDefinition.source + fieldDefinition.fieldName };
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
                return;
            }

            fieldsToDisplayArray.push(fieldToDisplay);
        });

        return fieldsToDisplayArray;
    }
}
