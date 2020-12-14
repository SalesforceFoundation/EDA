public virtual with sharing class HealthCheckGroupModel implements Comparable {
    
    @AuraEnabled public String label;
    @AuraEnabled public String status;
    @AuraEnabled public String statusLabel;
    @AuraEnabled public Integer passedChecks;
    @AuraEnabled public Integer totalChecks;
    @AuraEnabled public List<String> expandedRowsList;
    @AuraEnabled public List<HealthCheckItemVModel> healthCheckItemList;

    public HealthCheckGroupModel(String label, 
                                 String status, 
                                 String statusLabel, 
                                 Integer passedChecks, 
                                 Integer totalChecks, 
                                 List<String> expandedRowsList, 
                                 List<HealthCheckItemVModel> healthCheckItemList) {
        this.label = label;
        this.status = status;
        this.statusLabel = statusLabel;
        this.passedChecks = passedChecks;
        this.totalChecks = totalChecks;
        this.expandedRowsList = expandedRowsList;
        this.healthCheckItemList = healthCheckItemList;
    }

    /**
    * compareTo description
    * @param  compareTo compareTo description
    * @return           return description
    */ 
    public virtual Integer compareTo(Object compareTo){
        HealthCheckGroupModel hlthChkGroupModToCompareTo = (HealthCheckGroupModel)compareTo;
        
        // sort by status, fail above pass
        if (status.equalsIgnoreCase(hlthChkGroupModToCompareTo.status) == false){
            if (status.equalsIgnoreCase('fail')){
                return 1;
            }
            return -1;
        }
        
        // same status - sort by name
        return (label.compareTo(hlthChkGroupModToCompareTo.label));
    }
}
