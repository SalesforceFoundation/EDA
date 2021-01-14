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
* @description Class to generate a view model for Health Checks to be run and retrieves date of
* last run.
*/
public virtual with sharing class HealthCheckVMapper {

    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static HealthCheckVMapper instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected HealthCheckVMapper() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of HealthCheckVMapper.
    **********************************************************************************/
    public static HealthCheckVMapper getInstance() {
        if (instance == null) {
            instance = new HealthCheckVMapper();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Locates and returns an instance of FeatureParameterService 
    **********************************************************************************/
    @TestVisible
    private FeatureParameterService locateFeatureParameterService() {
        return FeatureParameterService.getInstance();
    }

    /**********************************************************************************
    * @description Locates and returns an instance of HealthCheckDefinitionService 
    **********************************************************************************/
    @TestVisible
    private HealthCheckDefinitionService locateHealthCheckDefinitionService() {
        return HealthCheckDefinitionService.getInstance();
    }

    /**********************************************************************************
    * @description Retrieve a view model representing a health check to run.
    * @return A HealthCheckVModel representing details of a health check to be run.
    **********************************************************************************/
    public virtual HealthCheckVModel getHealthCheckViewModel() {
        try {
            String lastRunDate = '';

            FeatureParameterDateModel featureParamDateModel = 
               (FeatureParameterDateModel)this.locateFeatureParameterService().getFeatureParameterModel('SettingsHealthCheckLastRunDate');

            if (featureParamDateModel.value != date.newinstance(2015, 12, 31)) {
                lastRunDate = featureParamDateModel.convertToString();
            }

            List<HealthCheckDefinitionVModel> healthCheckDefViewModelsList = new List<HealthCheckDefinitionVModel>(); // list to store VIEW MODELS
            List<HealthCheckDefinitionModel> healthCheckDefinitionList = this.locateHealthCheckDefinitionService().getHealthCheckDefinitionModels(); // retrieve models
            
            for (HealthCheckDefinitionModel healthCheckDefinitionModel : healthCheckDefinitionList) {
                //Generate view model for current health check definition model
                HealthCheckDefinitionVModel healthCheckDefinitionVModel = new HealthCheckDefinitionVModel(healthCheckDefinitionModel.name,
                                                                                                    healthCheckDefinitionModel.className,
                                                                                                    healthCheckDefinitionModel.namespace);

                healthCheckDefViewModelsList.add(healthCheckDefinitionVModel);
            }

            Integer numberOfRuns = healthCheckDefinitionList.size();

            return new HealthCheckVModel(lastRunDate, numberOfRuns, healthCheckDefViewModelsList);
        }
        catch (FeatureParameterMapper.FeatureParameterMapperException e) {
            throw new AuraHandledException(Label.stgHealthCheckErrorLastRunDate);
        }
    }
}