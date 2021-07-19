public virtual class EDCSettingsProductVModel implements Comparable {
    @AuraEnabled
    public String initials;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public String settingsComponent;
    @AuraEnabled
    public String documentationUrl;
    @AuraEnabled
    public String trailheadUrl;
    @AuraEnabled
    public String icon;

    public EDCSettingsProductVModel() {
    }

    public Integer compareTo(Object compareTo) {
        EDCSettingsProductVModel productVModel = (EDCSettingsProductVModel) compareTo;
        if (this.name > productVModel.name) {
            return 1;
        }

        if (this.name == productVModel.name) {
            return 0;
        }

        return -1;
    }
}
