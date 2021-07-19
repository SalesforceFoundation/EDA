public with sharing class EducationCloudSettingsController {
    @TestVisible
    private static EDCSettingsProductVMapper locateSettingsProductMapper() {
        return EDCSettingsProductVMapper.getInstance();
    }

    @AuraEnabled(cacheable=true)
    public static List<EDCSettingsProductVModel> getEDCSettingsProductVModels() {
        try {
            return EducationCloudSettingsController.locateSettingsProductMapper().getEDCSettingsProductVModels();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
