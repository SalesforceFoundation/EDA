public virtual with sharing class HealthCheckItemVModel implements Comparable {
    @AuraEnabled public String key;
    @AuraEnabled public String setting;
    @AuraEnabled public String status;
    @AuraEnabled public String description;
    @AuraEnabled public String recommendedFix;
    
    public HealthCheckItemVModel(String key, String setting, String status, String description, String recommendedFix) {
        this.key = key;
        this.setting = setting;
        this.status = status;
        this.description = description;
        this.recommendedFix = recommendedFix;
    }

    public virtual Integer compareTo(Object compareTo){
        return 0;
    }
}
