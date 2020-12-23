public with sharing class HealthCheckGroupController {

    /**********************************************************************************
    * @description Locates and returns an instance of HealthCheckVMapper. 
    **********************************************************************************/
    @TestVisible
    private static HealthCheckGroupService locateHealthCheckGroupService() {
        return HealthCheckGroupService.getInstance();
    }

    /**********************************************************************************
    * getHealthCheckGroupViewModel description
    * @param  name      name description
    * @param  className className description
    * @param  namespace namespace description
    * @return           return description
    **********************************************************************************/
    @AuraEnabled(cacheable=true)
    public static HealthCheckGroupVModel getHealthCheckGroupViewModel(String name, String className, String namespace){
        try {
            return HealthCheckGroupController.locateHealthCheckGroupService().getHealthCheckGroup(name, className, namespace);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
