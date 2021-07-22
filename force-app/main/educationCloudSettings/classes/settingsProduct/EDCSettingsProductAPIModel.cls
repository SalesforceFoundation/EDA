public virtual with sharing class EDCSettingsProductAPIModel {
    public class SettingsProductInformationActionResult extends CallableResult {
        public SettingsProductInformationResult result;
    }

    public class SettingsProductInformationResult {
        public SettingsProductInformation productInformation;
    }

    public class SettingsProductInformation {
        public String initials { get; private set; }
        public String name { get; private set; }
        public String description { get; private set; }
        public String settingsComponent { get; private set; }
        public String documentationUrl { get; private set; }
        public String trailheadUrl { get; private set; }
        public String icon { get; private set; }

        public SettingsProductInformation(
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
}
