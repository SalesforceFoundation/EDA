public with sharing class EducationCloudSettingsController {
    @AuraEnabled(cacheable=true)
    public static EDCSettingsProductVModel getEDCSettingsProductVModel(String productRegistry) {
        try {
            return EducationCloudSettingsController.locateSettingsProductVMapper()
                .getEDCSettingsProductVModel(productRegistry);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductRegistryVModel> getProductRegistrySettingsProductInformationVModels() {
        try {
            return EducationCloudSettingsController.locateProductRegistryVMapper()
                .getProductRegistrySettingsProductInformation();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible
    private static EDCSettingsProductVMapper locateSettingsProductVMapper() {
        return EDCSettingsProductVMapper.getInstance();
    }

    @TestVisible
    private static ProductRegistryVMapper locateProductRegistryVMapper() {
        return ProductRegistryVMapper.getInstance();
    }
}
