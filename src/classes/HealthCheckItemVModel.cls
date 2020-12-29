public virtual with sharing class HealthCheckItemVModel implements Comparable {
    @AuraEnabled public String key { get; private set; }
    @AuraEnabled public String setting { get; private set; }
    @AuraEnabled public String status { get; private set; }
    @AuraEnabled public String statusLabel { get; private set; }
    @AuraEnabled public String description { get; private set; }
    @AuraEnabled public String recommendedFix { get; private set; }
    @AuraEnabled public List<HealthCheckItemVModel> healthCheckItemList { get; private set; }
    
    public HealthCheckItemVModel(String key, 
                                 String setting, 
                                 String status, 
                                 String statusLabel,
                                 String description, 
                                 String recommendedFix,
                                 List<HealthCheckItemVModel> healthCheckItemList) {
        this.key = key;
        this.setting = setting;
        this.status = status;
        this.statusLabel = statusLabel;
        this.description = description;
        this.recommendedFix = recommendedFix;
        this.healthCheckItemList = healthCheckItemList;
    }

    /*****************************************************************************************
    * @description Implementation of CompareTo() that sorts by status (Fail above Pass), then in
    * ascending alphabetical order on setting.
    * @param compareTo A HealthCheckItemVModel to compare to another
    * @return 
    *****************************************************************************************/ 
    public virtual Integer compareTo(Object compareTo){

        if (!(compareTo instanceof HealthCheckItemVModel)){
            return 0;
        }

        HealthCheckItemVModel hlthChkItemModToCompareTo = (HealthCheckItemVModel)compareTo;
        Integer statusResult = this.status.toLowerCase().compareTo(hlthChkItemModToCompareTo.status.toLowerCase());
        
        if (statusResult != 0){
            return statusResult;
        }
        
        return this.setting.toLowerCase().compareTo(hlthChkItemModToCompareTo.setting.toLowerCase());
    }

    
}
