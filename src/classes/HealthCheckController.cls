public with sharing class HealthCheckController {

    private HealthCheckVMapper locateHealthCheckMapper() {
        return HealthCheckVMapper.getInstance();
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
