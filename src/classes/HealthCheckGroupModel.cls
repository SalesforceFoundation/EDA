public virtual with sharing class HealthCheckGroupModel implements Comparable {
    
    @AuraEnabled public String label { get; private set; }
    @AuraEnabled public String status { get; private set; }
    @AuraEnabled public Integer passedChecks { get; private set; }
    @AuraEnabled public Integer totalChecks { get; private set; }
    @AuraEnabled public List<String> expandedRowsList { get; private set; }
    @AuraEnabled public List<HealthCheckItemVModel> healthCheckItemList { get; private set; }

    public HealthCheckGroupModel(String label, 
                                 String status, 
                                 Integer passedChecks, 
                                 Integer totalChecks, 
                                 List<String> expandedRowsList, 
                                 List<HealthCheckItemVModel> healthCheckItemList) {
        this.label = label;
        this.status = status;
        this.passedChecks = passedChecks;
        this.totalChecks = totalChecks;
        this.expandedRowsList = expandedRowsList;
        this.healthCheckItemList = healthCheckItemList;
    }

    /*****************************************************************************************
    * @description Implementation of CompareTo() that sorts by status (Fail above Pass), then in
    * ascending alphabetical order on label.
    * @param compareTo A HealthCheckGroupModel to compare to another
    * @return 
    *****************************************************************************************/ 
    public virtual Integer compareTo(Object compareTo){

        if (!(compareTo instanceof HealthCheckGroupModel)){
            return 0;
        }

        HealthCheckGroupModel hlthChkGroupModToCompareTo = (HealthCheckGroupModel)compareTo;
        Integer statusResult = this.status.toLowerCase().compareTo(hlthChkGroupModToCompareTo.status.toLowerCase());
        
        if (statusResult != 0){
            return statusResult;
        }
        
        return this.label.toLowerCase().compareTo(hlthChkGroupModToCompareTo.label.toLowerCase());
    }
}