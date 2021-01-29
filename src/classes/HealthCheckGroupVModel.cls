/*
    Copyright (c) 2020, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
    its contributors may be used to endorse or promote products derived
    from this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2020
* @group Health Check
* @group-content ../../ApexDocContent/HealthCheck.htm
* @description Model to represent a Health Check Group View.
*/
public virtual with sharing class HealthCheckGroupVModel implements Comparable {
    
    @AuraEnabled public String label;
    @AuraEnabled public String status;
    @AuraEnabled public Integer passedChecks;
    @AuraEnabled public Integer totalChecks;
    @AuraEnabled public List<String> expandedRowsList { get; private set; }
    @AuraEnabled public List<HealthCheckItemVModel> healthCheckItemList { get; private set; }

    public HealthCheckGroupVModel() {
        this.label = '';
        this.passedChecks = 0;
        this.totalChecks = 0;
        this.expandedRowsList = new List<String>();
        this.healthCheckItemList = new List<HealthCheckItemVModel>();

        this.updateHealthCheckStatus();
    }
    
    public HealthCheckGroupVModel(String label, 
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

    /*********************************************************************************************************************
    * @description Update the status of a HealthCheckGroupVModel based on the number of passing health checks to total checks. 
    *********************************************************************************************************************/
    public void updateHealthCheckStatus() {      
        this.status = (this.passedChecks == this.totalChecks) ? 
            System.Label.stgHealthCheckStatusPassed : System.Label.stgHealthCheckStatusFailed;
    }
    
    /*****************************************************************************************
    * @description Implementation of CompareTo() that sorts by status (Fail above Pass), then in
    * ascending alphabetical order on label.
    * @param compareTo A HealthCheckGroupVModel object to compare to another
    * @return 0 if the current object is greater than the object to compare, -1 if it is less, 0 if
    * they are equal, or if the objec to compare is an incompatible type.
    *****************************************************************************************/ 
    public virtual Integer compareTo(Object compareTo){

        if (!(compareTo instanceof HealthCheckGroupVModel)){
            return 0;
        }

        HealthCheckGroupVModel healthCheckGroupVModelToCompareTo = (HealthCheckGroupVModel)compareTo;
        Integer statusResult = this.status.toLowerCase().compareTo(healthCheckGroupVModelToCompareTo.status.toLowerCase());
        
        if (statusResult != 0){
            return statusResult;
        }
        
        return this.label.toLowerCase().compareTo(healthCheckGroupVModelToCompareTo.label.toLowerCase());
    }
}