public virtual with sharing class HealthCheckItemVModel implements Comparable {
    @AuraEnabled public String key { get; private set; }
    @AuraEnabled public String setting { get; private set; }
    @AuraEnabled public String status { get; private set; }
    @AuraEnabled public String statusLabel { get; private set; }
    @AuraEnabled public String description { get; private set; }
    @AuraEnabled public String recommendedFix { get; private set; }
    
    public HealthCheckItemVModel(String key, 
                                 String setting, 
                                 String status, 
                                 String statusLabel,
                                 String description, 
                                 String recommendedFix) {
        this.key = key;
        this.setting = setting;
        this.status = status;
        this.statusLabel = statusLabel;
        this.description = description;
        this.recommendedFix = recommendedFix;
    }

    /*****************************************************************************************
    * compareTo description
    * @param  compareTo compareTo description
    * @return           return description
    *****************************************************************************************/
    public virtual Integer compareTo(Object compareTo){
        return 0;
    }
}
