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
* @group
* @group-content ../../ApexDocContent/HealthCheck.htm
* @description Model to represent a Health Check Group View.
*/
public virtual with sharing class HealthCheckGroupVModel implements Comparable {
    
    @AuraEnabled public String label { get; private set; }
    @AuraEnabled public String status { get; private set; }
    @AuraEnabled public Integer passedChecks { get; private set; }
    @AuraEnabled public Integer totalChecks { get; private set; }
    @AuraEnabled public List<String> expandedRowsList { get; private set; }
    @AuraEnabled public List<HealthCheckItemVModel> healthCheckItemList { get; private set; }

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
    
    /*****************************************************************************************
    * @description Implementation of CompareTo() that sorts by status (Fail above Pass), then in
    * ascending alphabetical order on label.
    * @param compareTo A HealthCheckGroupVModel to compare to another
    * @return 
    *****************************************************************************************/ 
    public virtual Integer compareTo(Object compareTo){

        if (!(compareTo instanceof HealthCheckGroupVModel)){
            return 0;
        }

        HealthCheckGroupVModel hlthChkGroupModToCompareTo = (HealthCheckGroupVModel)compareTo;
        Integer statusResult = this.status.toLowerCase().compareTo(hlthChkGroupModToCompareTo.status.toLowerCase());
        
        if (statusResult != 0){
            return statusResult;
        }
        
        return this.label.toLowerCase().compareTo(hlthChkGroupModToCompareTo.label.toLowerCase());
    }
}