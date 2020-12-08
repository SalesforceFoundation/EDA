public with sharing class HealthCheckController {

    private VMPR_HealthCheck locateHealthCheckMapper() {
        return VMPR_HealthCheck.getInstance();
    }

    @AuraEnabled(cacheable=true)
    public static VMDL_HealthCheck getHealthCheckViewModel(){
        try {
            return new VMDL_HealthCheck(Date.today().format(), 3, new List<VMDL_HealthCheckDefinition>());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
  
}
