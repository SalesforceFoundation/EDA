import { LightningElement, api } from "lwc";

export default class LearnerAssertionVisualization extends LightningElement {
    @api fieldDefinitions;
    @api learnerAssertionViewModel;
    @api schemaLabels;

    get fieldsToDisplay() {
        let fieldsToDisplayArray = [];

        this.fieldDefinitions.forEach((fieldDefinition) => {
            //Field key is an obnoxious requirement for loops
            let fieldToDisplay = { fieldKey: fieldDefinition };
            let parsedFieldName = this.parseFieldName(fieldDefinition);

            fieldToDisplay.fieldValue = this.getNestedStringFromViewModel(
                this.learnerAssertionViewModel,
                parsedFieldName
            );

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
}
