/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
* @date 2021
* @group Health Check
* @group-content ../../ApexDocContent/HealthCheck.htm
* @description Class to represent the view model for a Health Check Item.
*/
public virtual with sharing class HealthCheckItemVModel implements Comparable {
    @AuraEnabled public String key { get; private set; }
    @AuraEnabled public String setting { get; private set; }
    @AuraEnabled public String status;
    @AuraEnabled public String statusLabel;
    @AuraEnabled public String description;
    @AuraEnabled public String recommendedFix;
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
    * @param compareTo A HealthCheckItemVModel object to compare to another
    * @return 0 if the current object is greater than the object to compare, -1 if it is less, 0 if
    * they are equal, or if the objec to compare is an incompatible type.
    *****************************************************************************************/ 
    public virtual Integer compareTo(Object compareTo){

        if (!(compareTo instanceof HealthCheckItemVModel)){
            return 0;
        }

        HealthCheckItemVModel healthCheckItemVModelToCompareTo = (HealthCheckItemVModel)compareTo;
        Integer statusResult = this.status.toLowerCase().compareTo(healthCheckItemVModelToCompareTo.status.toLowerCase());
        
        if (statusResult != 0){
            return statusResult;
        }
        
        return this.setting.toLowerCase().compareTo(healthCheckItemVModelToCompareTo.setting.toLowerCase());
    }
}