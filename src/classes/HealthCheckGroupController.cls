public with sharing class HealthCheckGroupController {

    /**********************************************************************************
    * @description Locates and returns an instance of HealthCheckVMapper. 
    **********************************************************************************/
    @TestVisible
    private static HealthCheckGroupService locateHealthCheckGroupService() {
        return HealthCheckGroupService.getInstance();
    }

    @AuraEnabled
    public static HealthCheckGroupVModel getHealthCheckGroup(String name, String className, String namespace){
        try {
            return HealthCheckGroupController.locateHealthCheckGroupService().getHealthCheckGroup(name, className, namespace);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
