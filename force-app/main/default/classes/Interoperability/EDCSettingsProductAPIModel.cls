public virtual with sharing class EDCSettingsProductAPIModel {
    public class SettingsProductInformationActionResult extends CallableResult {
        public SettingsProductinformationResult result;
    }

    public class SettingsProductInformationResult {
        public SettingsProductInformation productInformation;
    }

    public class SettingsProductInformation {
        public String initials;
        public String name;
        public String description;
        public String settingsComponent;
        public String documentationUrl;
        public String trailheadUrl;
        public String icon;
    }
}
