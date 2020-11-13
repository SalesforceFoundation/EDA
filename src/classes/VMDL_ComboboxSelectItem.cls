public with sharing class VMDL_ComboboxSelectItem {
    public VMDL_ComboboxSelectItem(){}

    /**
    * @description We could incorporate an invalid version of this model that overrides it.
    * In that case we would use the value and label as the 'bad' settings option.
    */
    public VMDL_ComboboxSelectItem(String value, String label) {
        this.value = value;
        this.label = label;
        this.isValid = true;
    }

    public VMDL_ComboboxSelectItem(String value, String label, Boolean isValid) {
        this.value = value;
        this.label = label;
        this.isValid = isValid;
    }

    /**
    * @description Aura enabled property for passing down to back-end
    */
    @AuraEnabled
    public String value {
        get; private set;
    }

    /**
    * @description Aura enabled property for displaying value in localized format
    */
    @AuraEnabled
    public String label {
        get; private set;
    }

    /**
    * @description Aura enabled property for displaying value in localized format
    */
    @AuraEnabled
    public Boolean isValid {
        get; private set;
    }
}