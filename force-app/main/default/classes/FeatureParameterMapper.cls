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
* @group 
* @group-content ../../ApexDocContent/
* @description Mapper class to return Feature Parameter Models and sets feature parameter value
*/
public virtual with sharing class FeatureParameterMapper {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static FeatureParameterMapper instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected FeatureParameterMapper() {}

    /***************************************************************************
    * @description Map to hold Data Types(values) of the feature parameter(keys)
    ***************************************************************************/
    private static final Map<TelemetryParameterName, String> dataTypeByFeatureParameter {
        get {
            if (dataTypeByFeatureParameter == null) {
                dataTypeByFeatureParameter = new Map<TelemetryParameterName, String>();
                dataTypeByFeatureParameter.put(TelemetryParameterName.SettingsHealthCheckLastRunDate, 'Date');
            }
            return dataTypeByFeatureParameter;
        }  
        private set;
    }

    /***************************************************************************
    * @description Map to hold Enums by their string values
    ***************************************************************************/
    @TestVisible
    private static final Map<String, TelemetryParameterName> TelemetryParameterByString {
        get {
            if (TelemetryParameterByString == null) {
                TelemetryParameterByString = new Map<String, TelemetryParameterName>();
                for (TelemetryParameterName telmetryParam: TelemetryParameterName.values()) {
                    TelemetryParameterByString.put(String.valueOf(telmetryParam), telmetryParam);
                }
            }
            return TelemetryParameterByString;
        }
        private set;
    }

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of FeatureParameterMapper.
    ******************************************************************************/
    public static FeatureParameterMapper getInstance() {

        if (instance == null) {
            instance = new FeatureParameterMapper();
        }

        return instance;
    }

    /*********************************************************************************************************
    * @description Each of these corresponds to the exact name of a FeatureParameter in the managed package.
    **********************************************************************************************************/
    public enum TelemetryParameterName {
        Data_CountAdministrativeAccounts,
            Data_CountHouseholdAccounts,
            Data_CountCampaignMemberRelationshipRules,
            Data_CountContactRelationshipRules,
            Data_CountCourseConnections,
            Data_CountCourseOfferingSchedules,
            Data_CountErrorLog,
            Data_CountFacilities,
            Data_CountPlanRequirements,
            Data_CountProgramPlans,
            Data_CountTermGrades,
            HasDefaultAdministrativeAccountModel,
            HasDefaultHouseholdAccountModel,
            HasCustomAdministrativeAccountNaming,
            HasCustomHouseholdAccountNaming,
            HasEDAInactiveTDTM,
            HasUserManagedTDTM,
            HasValueInversionReciprocalMethod,
            IsEnabled_StoreErrors,
            HasErrorNotificationsAdminRecipients,
            IsEnabled_AutomaticHouseholdNaming,
            IsEnabled_CourseConnections,
            IsEnabled_ErrorHandling,
            Org_CountActiveCourseConnectionRecordTypes,
            SettingsHealthCheckLastRunDate,
            UsingOldContactEthnicity,
            UsingOldCourseDescription,
            AutodeleteNoContactHouseholdAcc,
            AutodeleteNoContactProgramAcc,
            AutodeleteNoContactEducationalInstitutionAcc,
            AutodeleteNoContactBusinessOrganizationAcc,
            AutodeleteNoContactUniversityDepartmentAcc,
            HasAffiliationsRelatedToDeletedProgramEnrollments,
            HasAffiliationStartDate,
            HasAffiliationEndDate,
            HasApplicationWindowValidation
    }

    /**********************************************************************************
    * @description Returns the data type of the feature parameter passed
    * @return dataTypeByFeatureParameter The data type of the feature parameter passed
    **********************************************************************************/
    @TestVisible
    private String getFeatureParameterType(TelemetryParameterName featureParameter) {
        return FeatureParameterMapper.dataTypeByFeatureParameter.get(featureParameter);
    }

    /*************************************************************************************************************
    * @description Method to return a featureParameterModel
    * @Params featureParameter The feature Parameter to return the model for
    * @return featureParamDateModel The model for the featureParameter with with value set to the current datetime
    **************************************************************************************************************/
    public virtual FeatureParameterModel getFeatureParameterModel(String featureParameter) {

        TelemetryParameterName telemetryParameterName = FeatureParameterMapper.TelemetryParameterByString.get(featureParameter);

        if (telemetryParameterName == null) {
            throw new FeatureParameterMapperException('Could not find the Feature Parameter ' + featureParameter);
        }

        String featureParameterDataType = this.getFeatureParameterType(telemetryParameterName);

        if (featureParameterDataType == 'Date') {
            UTIL_FeatureManagement featureManager = new UTIL_FeatureManagement();
            Date featureParameterDate = featureManager.checkPackageDateValue(String.valueOf(telemetryParameterName));
            FeatureParameterDateModel featureParamDateMdl = new FeatureParameterDateModel(String.valueOf(telemetryParameterName), featureParameterDate);
            return featureParamDateMdl;
        }

        throw new FeatureParameterMapperException('Feature Parameter ' + String.valueOf(telemetryParameterName) + ' is not defined.');

    }

    /*************************************************************************************************************
    * @description Updates the feature parameter's value
    * @Params featureParameter The feature Parameter to update the parameter from
    **************************************************************************************************************/
    public virtual void updateFromFeatureParameterModel(FeatureParameterModel featureParamModel) {

        TelemetryParameterName telemetryParameterName = FeatureParameterMapper.TelemetryParameterByString.get(featureParamModel.name);

        if (telemetryParameterName == null) {
            throw new FeatureParameterMapperException('Could not find the Feature Parameter ' + featureParamModel.name);
        }

        String dataType = this.getFeatureParameterType(telemetryParameterName);

        if (dataType == 'Date') {
            FeatureParameterDateModel featureParamDateModel = (FeatureParameterDateModel)featureParamModel;
            UTIL_FeatureManagement featureManager = new UTIL_FeatureManagement();
            featureManager.setPackageDateValue(featureParamDateModel.name, featureParamDateModel.value);
        } else {
            throw new FeatureParameterMapperException('Feature Parameter ' + String.valueOf(telemetryParameterName) + ' is not defined.');
        }

    }

    /*************************************************************************
    * @description An expection class for Feature Parameter Exceptions
    **************************************************************************/
    public class FeatureParameterMapperException extends Exception {}

}