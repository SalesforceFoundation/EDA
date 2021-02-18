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
* @description Controller for healthCheck LWC component.
*/
public with sharing class HealthCheckController {

    /**********************************************************************************
    * @description Locates and returns an instance of HealthCheckVMapper. 
    **********************************************************************************/
    @TestVisible
    private static HealthCheckVMapper locateHealthCheckMapper() {
        return HealthCheckVMapper.getInstance();
    }

    /**********************************************************************************
    * @description Retrieve a view model representing the Health Check to run.
    * @return A HealthCheckVModel representing the view of the Health Check to run.
    **********************************************************************************/
    @AuraEnabled(cacheable=true)
    public static HealthCheckVModel getHealthCheckViewModel() {
        try {
            return HealthCheckController.locateHealthCheckMapper().getHealthCheckViewModel();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**********************************************************************************
    * @description Updates and retrieves the last run date of the health check
    * @return The last run date of health check.
    **********************************************************************************/
    @AuraEnabled
    public static String updateHealthCheckLastRunDate() {
        try {
            FeatureParameterDateModel featureParamDateModel = new FeatureParameterDateModel('SettingsHealthCheckLastRunDate', System.today());
            FeatureParameterService.getInstance().updateFromFeatureParameterModel(featureParamDateModel);
            return FeatureParameterService.getInstance().getFeatureParameterModel('SettingsHealthCheckLastRunDate').convertToString();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
}
