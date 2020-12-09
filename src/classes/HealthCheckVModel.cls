public with sharing class HealthCheckVModel {
    @AuraEnabled 
    public String lastRunDate { get; private set; }
    
    @AuraEnabled 
    public Integer numberOfHealthChecks { get; private set; }
    
    @AuraEnabled 
    public List<HealthCheckDefinitionVModel> healthChecksToRunList { get; private set; }

    public HealthCheckVModel(String lastRunDate, 
                            Integer numberOfHealthChecks, 
                            List<HealthCheckDefinitionVModel> healthChecksToRunList) {
                                
        this.lastRunDate = lastRunDate;
        this.numberOfHealthChecks = numberOfHealthChecks;
        this.healthChecksToRunList = healthChecksToRunList;
    }
}
