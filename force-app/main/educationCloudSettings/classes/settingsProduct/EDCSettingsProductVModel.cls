public virtual class EDCSettingsProductVModel {
    @AuraEnabled
    public String initials { get; private set; }
    @AuraEnabled
    public String name { get; private set; }
    @AuraEnabled
    public String description { get; private set; }
    @AuraEnabled
    public String settingsComponent { get; private set; }
    @AuraEnabled
    public String documentationUrl { get; private set; }
    @AuraEnabled
    public String trailheadUrl { get; private set; }
    @AuraEnabled
    public String icon { get; private set; }

    public EDCSettingsProductVModel(
        String initials,
        String name,
        String description,
        String settingsComponent,
        String documentationUrl,
        String trailheadUrl,
        String icon
    ) {
        this.initials = initials;
        this.name = name;
        this.description = description;
        this.settingsComponent = settingsComponent;
        this.documentationUrl = documentationUrl;
        this.trailheadUrl = trailheadUrl;
        this.icon = icon;
    }
}
