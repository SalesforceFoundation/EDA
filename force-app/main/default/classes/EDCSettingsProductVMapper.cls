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

    public virtual List<EDCSettingsProductVModel> getEDCSettingsProductVModels() {
        List<EDCSettingsProductVModel> edcSettingsProductVModels = new List<EDCSettingsProductVModel>();

        List<EDCSettingsProductAPIModel.SettingsProductInformationResult> settingsProductInformationResultList = this.getAllSettingsProductInformation();

        if (settingsProductInformationResultList != null) {
            String navigationPrefix = this.getEDAComponentNavigationPrefix();
            for (
                EDCSettingsProductAPIModel.SettingsProductInformationResult productInformationResult : settingsProductInformationResultList
            ) {
                EDCSettingsProductVModel settingsProductVModel = new EDCSettingsProductVModel();
                settingsProductVModel.initials = productInformationResult.productInformation.initials;
                settingsProductVModel.name = productInformationResult.productInformation.name;
                settingsProductVModel.description = productInformationResult.productInformation.description;
                settingsProductVModel.settingsComponent =
                    navigationPrefix + productInformationResult.productInformation.settingsComponent;
                settingsProductVModel.documentationUrl = productInformationResult.productInformation.documentationUrl;
                settingsProductVModel.trailheadUrl = productInformationResult.productInformation.trailheadUrl;
                settingsProductVModel.icon = productInformationResult.productInformation.icon;
                edcSettingsProductVModels.add(settingsProductVModel);
            }
        }

        return edcSettingsProductVModels;
    }

    public virtual List<EDCSettingsProductAPIModel.SettingsProductInformationResult> getAllSettingsProductInformation() {
        List<ProductRegistryModel> productRegistryModelList = this.getProductRegistryModels();
        List<EDCSettingsProductAPIModel.SettingsProductInformationResult> settingsProductInformationResultList = new List<EDCSettingsProductAPIModel.SettingsProductInformationResult>();

        for (ProductRegistryModel productRegistryModel : productRegistryModelList) {
            EDCSettingsProductAPIModel.SettingsProductInformationResult settingsProductInformationResult = this.getSettingsProductInformation(
                productRegistryModel.classname,
                productRegistryModel.namespace,
                productRegistryModel.apiVersion
            );
            if (settingsProductInformationResult != null) {
                settingsProductInformationResultList.add(settingsProductInformationResult);
            }
        }

        return settingsProductInformationResultList;
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

    private List<ProductRegistryModel> getProductRegistryModels() {
        //Instead of this use the ProductRegistryVMapper for returning the list of product registry models

        return new List<ProductRegistryModel>{
            new ProductRegistryModel(
                'Settings Product Information',
                UTIL_Namespace.getNamespace(),
                'EDASettingsProductInformationAPIService',
                51.0
            ),
            new ProductRegistryModel(
                'Settings Product Information',
                UTIL_Namespace.getNamespace(),
                'EDASettingsProductInformationAPIService',
                51.0
            )
        };
    }

    public String getEDAComponentNavigationPrefix() {
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
