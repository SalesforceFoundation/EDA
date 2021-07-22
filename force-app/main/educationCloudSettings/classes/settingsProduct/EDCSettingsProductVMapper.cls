public virtual with sharing class EDCSettingsProductVMapper {
    @TestVisible
    private static EDCSettingsProductVMapper instance;

    protected EDCSettingsProductVMapper() {
    }

    public static EDCSettingsProductVMapper getInstance() {
        if (instance == null) {
            instance = new EDCSettingsProductVMapper();
        }

        return instance;
    }

    public virtual EDCSettingsProductVModel getEDCSettingsProductVModel(String productRegistry) {
        ProductRegistryVModel prodRegistryVModel = (ProductRegistryVModel) JSON.deserialize(
            productRegistry,
            ProductRegistryVModel.class
        );

        EDCSettingsProductAPIModel.SettingsProductInformationResult productInformationResult = this.getSettingsProductInformation(
            prodRegistryVModel.classname,
            prodRegistryVModel.namespace,
            prodRegistryVModel.apiVersion
        );

        EDCSettingsProductVModel settingsProductVModel = new EDCSettingsProductVModel();

        if (productInformationResult != null) {
            String navigationPrefix = this.getEDAComponentNavigationPrefix();
            settingsProductVModel.initials = productInformationResult.productInformation.initials;
            settingsProductVModel.name = productInformationResult.productInformation.name;
            settingsProductVModel.description = productInformationResult.productInformation.description;
            settingsProductVModel.settingsComponent =
                navigationPrefix + productInformationResult.productInformation.settingsComponent;
            settingsProductVModel.documentationUrl = productInformationResult.productInformation.documentationUrl;
            settingsProductVModel.trailheadUrl = productInformationResult.productInformation.trailheadUrl;
            settingsProductVModel.icon = productInformationResult.productInformation.icon;
        }

        return settingsProductVModel;
    }

    private virtual EDCSettingsProductAPIModel.SettingsProductInformationResult getSettingsProductInformation(
        String className,
        String namespace,
        Decimal apiVersion
    ) {
        EDCSettingsProductAPIModel.SettingsProductInformationActionResult settingsProductInformationActionResult = this.locateSettingsProductAPIService()
            .getSettingsProductInformation(className, namespace, apiVersion);

        EDCSettingsProductAPIModel.SettingsProductInformationResult result;

        if (settingsProductInformationActionResult != null) {
            if (settingsProductInformationActionResult.success) {
                result = settingsProductInformationActionResult.result;
            } else {
                throw new SettingsProductException(settingsProductInformationActionResult.error.message);
            }
        }
        return result;
    }

    @TestVisible
    private EDCSettingsProductAPIService locateSettingsProductAPIService() {
        return EDCSettingsProductAPIService.getInstance();
    }

    private virtual String getEDAComponentNavigationPrefix() {
        String courseOfferingName = Course_Offering_Schedule__c.Course_Offering__c.getDescribe().getName();
        String navigationPrefix = courseOfferingName.replace('Course_Offering__c', '');
        String prefix;

        if (String.isBlank(navigationPrefix)) {
            navigationPrefix = 'c__';
        }

        return navigationPrefix;
    }

    public class SettingsProductException extends Exception {
    }
}
