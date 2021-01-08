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
* @description Generate a HealthCheckGroup view model representing the results of
* an Course Connection settings health check.  Verifies Course connection is enabled. 
*/
public virtual with sharing class CourseConSettingHealthCheckVMapper {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static CourseConSettingHealthCheckVMapper instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected CourseConSettingHealthCheckVMapper() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of CourseConSettingHealthCheckVMapper.
    **********************************************************************************/
    public static CourseConSettingHealthCheckVMapper getInstance() {
        if (instance == null) {
            instance = new CourseConSettingHealthCheckVMapper();
        }

        return instance;
    }

    /********************************************************************************************
    * @description Retrieve the results for a for an Course Connection Settings health check.
    * @return A HealthCheckGroupVModel representing a HealtCheckDescription for Course Connection.
    ********************************************************************************************/ 
    public virtual HealthCheckGroupVModel getHealthCheckGroup() {

        HealthCheckGroupVModel hlthChkGroupVMod = new HealthCheckGroupVModel(
            Label.stgHCCourseConnectionsTitle
            Label.stgHealthCheckStatusPassed,
            0,
            0,
            new List<String>(),
            new List<HealthCheckItemVModel>()
        );

        CourseConnectionSettingsModel courseConnSettingsModel = this.locateCourseConnectionSettingsService().getCourseConnectionSettingsModel();

        String objectName = UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c');
        SObjectType courseConnSObjectType = UTIL_Describe.getObjectDescribe(objectName).getSObjectType();
        Map<Id, RecordTypeModel> courseConnRTModelsById = this.locateRecordTypeService().getModelByIdMapForSObjectType(courseConnSObjectType);

        HealthCheckGroupVModel courseConnEnableCheckResult = this.getCourseConnectionsNotEnabledHealthCheckItems(courseConnSettingsModel);

        hlthChkGroupVMod.passedChecks += courseConnEnableCheckResult.passedChecks;
        hlthChkGroupVMod.totalChecks +=  courseConnEnableCheckResult.totalChecks;
        hlthChkGroupVMod.expandedRowsList.addAll(courseConnEnableCheckResult.expandedRowsList);
        hlthChkGroupVMod.healthCheckItemList.addAll(courseConnEnableCheckResult.healthCheckItemList);

        if(hlthChkGroupVMod.passedChecks < hlthChkGroupVMod.totalChecks) {
            hlthChkGroupVMod.status = Label.stgHealthCheckStatusFailed;
        }

        hlthChkGroupVMod.healthCheckItemList.sort();
        return hlthChkGroupVMod;

    }

    /*******************************************************************************
    * @description Retrieves the health check for a Course Connection Settings Model
    * @param CourseConnectionSettingsModel The courseConnSettingsModel model to perform
    * the health check on.
    * @return The health check for the Course Connection Settings Model
    *******************************************************************************/
    @TestVisible
    protected virtual HealthCheckGroupVModel getCourseConnectionsNotEnabledHealthCheckItems(
        CourseConnectionSettingsModel courseConnSettingsModel
    ) {

        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(
            '',
            '',
            0,
            0,
            new List<String>(),
            new List<HealthCheckItemVModel>()
        );

        if (courseConnSettingsModel.courseConnectionsEnabled == false) {
            healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel('01',
                                                                      Label.stgEnableCourseConnectionsTitle
                                                                      'Fail',
                                                                      Label.stgHealthCheckStatusFailed,
                                                                      Label.stgHCCourseConEnable
                                                                      Label.stgHCCourseConEnableFix
                                                                      new List<HealthCheckItemVModel>()));
            healthCheckGroupVModel.totalChecks++;
            
            return healthCheckGroupVModel;
        }

        return HealthCheckGroupVModel;
    }    

    /*****************************************************************************
    * @description Retrieve an instance of the CourseConnectionSettingsService class.
    * @return An instance of CourseConnectionSettingsService.
    *****************************************************************************/
    @TestVisible
    private CourseConnectionSettingsService locateCourseConnectionSettingsService() {
        return CourseConnectionSettingsService.getInstance();
    }

    /*****************************************************************************
    * @description Retrieve an instance of the RecordTypeService class.
    * @return An instance of RecordTypeService.
    *****************************************************************************/
    @TestVisible
    private RecordTypeService locateRecordTypeService() {
        return RecordTypeService.getInstance();
    }
}