public with sharing class CTRL_CustomLabels {

    @AuraEnabled(cacheable=true)
    public static VMDL_CustomLabel getComboBoxLabels(){
        System.debug('MK DEBUG CitizenshipStatusSelectComboboxLabel: ' + Label.CitizenshipStatusSelectComboboxLabel);
        System.debug('MK DEBUG objectSelectComboboxPlaceholder: ' + Label.objectSelectComboboxPlaceholder);
        VMDL_CustomLabel customLabelModel = new VMDL_CustomLabel(Label.CitizenshipStatusSelectComboboxLabel, Label.objectSelectComboboxPlaceholder);
        
        System.debug('MK DEBUG: VMDL_CustomLabel: ' + customLabelModel);

        return customLabelModel;
    }

    public with sharing class VMDL_CustomLabel {
        @AuraEnabled
        public String labelText { get; private set; }

        @AuraEnabled
        public String placeholderText { get; private set; }

        public VMDL_CustomLabel(String labelText, String placeholderText){
            this.labelText = labelText;
            this.placeholderText = placeholderText;
        }
    }
}
