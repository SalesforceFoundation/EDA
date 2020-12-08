public with sharing class VMDL_HealthCheck {
    @AuraEnabled 
    public String lastRunDate { get; private set; }
    
    @AuraEnabled 
    public Integer numberOfHealthChecks { get; private set; }
    
    @AuraEnabled 
    public List<VMDL_HealthCheckDefinition> healthChecksToRunList { get; private set; }

    public VMDL_HealthCheck(String lastRunDate, 
                            Integer numberOfHealthChecks, 
                            List<VMDL_HealthCheckDefinition> healthChecksToRunList) {
                                
        this.lastRunDate = lastRunDate;
        this.numberOfHealthChecks = numberOfHealthChecks;
        this.healthChecksToRunList = healthChecksToRunList;
    }
}
