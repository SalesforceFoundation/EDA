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

        CourseConnectionSettingsModel courseConnSettingsModel = this.locateCourseConnectionSettingsService().getCourseConnectionSettingsModel();
        Map<Id, RecordTypeModel> courseConnRTModelsById = this.locateRecordTypeService().getModelByIdMapForSObjectType(Course_Enrollment__c.SObjectType);

        List<HealthCheckGroupVModel> courseConSettingtHlthCheckGroupVModelsList = new List<HealthCheckGroupVModel>();
        courseConSettingtHlthCheckGroupVModelsList.add(this.getCourseConnectionsNotEnabledHealthCheckItems(courseConnSettingsModel));
        if (courseConSettingtHlthCheckGroupVModelsList[0].healthCheckItemList.size() > 0) {
            return this.combineAccountHealthCheckGroupViewModels(courseConSettingtHlthCheckGroupVModelsList);
        }
        courseConSettingtHlthCheckGroupVModelsList.add(this.getStudentHealthCheckItems(courseConnSettingsModel, courseConnRTModelsById));
        courseConSettingtHlthCheckGroupVModelsList.add(this.getFacultyHealthCheckItems(courseConnSettingsModel, courseConnRTModelsById));
        courseConSettingtHlthCheckGroupVModelsList.add(this.getCourseConnectionRecordTypeUniquenessHealthCheckItems(courseConnSettingsModel));

        return this.combineAccountHealthCheckGroupViewModels(courseConSettingtHlthCheckGroupVModelsList);

    }

    /**********************************************************************************
    * @description Generates a HealthCheckGroupVModel comprised of the combined health 
    * check results for Default Account, Administrative and Household accounts. 
    * @param  healthCheckGroupVModelsList A list of HealthCheckGroupVModels
    * @return A HealthCheckGroupVModel representing the health check results for 
    * Default, Administrative and Household Accounts.
    **********************************************************************************/ 
    @TestVisible
    private HealthCheckGroupVModel combineAccountHealthCheckGroupViewModels(List<HealthCheckGroupVModel> healthCheckGroupVModelsList) {

        Integer hlthChkGroupPassedChecks = 0;
        Integer hlthChkGroupTotalChecks = 0;

        List<String> hlthChkGroupExpandedRowsList = new List<String>();
        List<HealthCheckItemVModel> hlthChkGroupHlthChkItemsList = new List<HealthCheckItemVModel>();

        for (HealthCheckGroupVModel hlthChkGroupVMod : healthCheckGroupVModelsList) {
            hlthChkGroupPassedChecks += hlthChkGroupVMod.passedChecks;
            hlthChkGroupTotalChecks += hlthChkGroupVMod.totalChecks;

            hlthChkGroupExpandedRowsList.addAll(hlthChkGroupVMod.expandedRowsList);
            hlthChkGroupHlthChkItemsList.addAll(hlthChkGroupVMod.healthCheckItemList);
        }

        HealthCheckGroupVModel hlthChkGroupVMod = new HealthCheckGroupVModel(Label.stgHCCourseConnectionsTitle,
                                                                             Label.stgHealthCheckStatusPassed,
                                                                             hlthChkGroupPassedChecks,
                                                                             hlthChkGroupTotalChecks,
                                                                             hlthChkGroupExpandedRowsList,
                                                                             hlthChkGroupHlthChkItemsList);

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
                                                                      Label.stgEnableCourseConnectionsTitle,
                                                                      'Fail',
                                                                      Label.stgHealthCheckStatusWarning,
                                                                      Label.stgHCCourseConEnable,
                                                                      Label.stgHCCourseConEnableFix,
                                                                      new List<HealthCheckItemVModel>()));
            healthCheckGroupVModel.totalChecks++;

            return healthCheckGroupVModel;
        }

        return HealthCheckGroupVModel;
    }

    /**********************************************************************************
    * @description Generates a HealthCheckGroupVModel for a Default Account Model health check
    * @param  acctModelSettingsMod An AccountModelSettingsModel
    * @param  recordTypeModelsById A map of Record Type models by Id
    * @return A HealthCheckGroupVModel with representing a Default Account Model Health Check
    **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getStudentHealthCheckItems(CourseConnectionSettingsModel courseConnectionSettingsModel, 
                                                                      Map<Id, RecordTypeModel> recordTypeModelsById) {
                     
        HealthCheckGroupVModel hlthChkGroupVMod = new HealthCheckGroupVModel(
            '',
            '',
            0,
            0,
            new List<String>(),
            new List<HealthCheckItemVModel>()
        );
                                           
        RecordTypeModel studentRecTypeModel =   
            this.locateRecordTypeService().getRecordTypeModelFromMap(courseConnectionSettingsModel.studentRecordTypeId, recordTypeModelsById);

        if (studentRecTypeModel == null) {
            hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('02',
                                                                                Label.stgDefaultStudentTypeTitle,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCRecordTypeNotFound, 
                                                                                    new List<Object>{courseConnectionSettingsModel.studentRecordTypeId}
                                                                                ),
                                                                                Label.stgHCCourseConStudentNotFoundFix,
                                                                                new List<HealthCheckItemVModel>()));
            hlthChkGroupVMod.totalChecks++;
            return hlthChkGroupVMod;
        }

        if (studentRecTypeModel.isActive == false) {
            hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('02',
                                                                                Label.stgDefaultStudentTypeTitle,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCRecordTypeInactive, 
                                                                                    new List<Object>{studentRecTypeModel.name, studentRecTypeModel.developerName}
                                                                                ),
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCCourseConStudentInactiveFix, 
                                                                                    new List<Object>{studentRecTypeModel.name, studentRecTypeModel.developerName}
                                                                                ),
                                                                                new List<HealthCheckItemVModel>()));
            hlthChkGroupVMod.totalChecks++;
            return hlthChkGroupVMod;
        }

       hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('02',
                                                                          Label.stgDefaultStudentTypeTitle,
                                                                          'Pass',
                                                                          Label.stgHealthCheckStatusPassed,
                                                                          this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                Label.stgHCRecordTypeValid, 
                                                                                new List<Object>{studentRecTypeModel.name, studentRecTypeModel.developerName}
                                                                            ),
                                                                          Label.stgHealthCheckFixNotApplicable,
                                                                          new List<HealthCheckItemVModel>()));
        hlthChkGroupVMod.totalChecks++;
        hlthChkGroupVMod.passedChecks++;

        return hlthChkGroupVMod;
    }

    /**********************************************************************************
    * @description Generates a HealthCheckGroupVModel for a Default Account Model health check
    * @param  acctModelSettingsMod An AccountModelSettingsModel
    * @param  recordTypeModelsById A map of Record Type models by Id
    * @return A HealthCheckGroupVModel with representing a Default Account Model Health Check
    **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getFacultyHealthCheckItems(CourseConnectionSettingsModel courseConnectionSettingsModel, 
                                                                      Map<Id,RecordTypeModel> recordTypeModelsById) {
                               
        HealthCheckGroupVModel hlthChkGroupVMod = new HealthCheckGroupVModel(
            '',
            '',
            0,
            0,
            new List<String>(),
            new List<HealthCheckItemVModel>()
        );
                                                              
        RecordTypeModel facultyRecTypeModel =   
            this.locateRecordTypeService().getRecordTypeModelFromMap(courseConnectionSettingsModel.facultyRecordTypeId, recordTypeModelsById);
                                
        if (facultyRecTypeModel == null) {
            hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('03',
                                                                                Label.stgDefaultFacultyTypeTitle,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCRecordTypeNotFound, 
                                                                                    new List<Object>{courseConnectionSettingsModel.facultyRecordTypeId}
                                                                                ),
                                                                                Label.stgHCCourseConFacultyNotFoundFix,
                                                                                new List<HealthCheckItemVModel>()));
            hlthChkGroupVMod.totalChecks++;
            return hlthChkGroupVMod;
        }

        if (facultyRecTypeModel.isActive == false) {
            hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('03',
                                                                                Label.stgDefaultFacultyTypeTitle,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCRecordTypeInactive, 
                                                                                    new List<Object>{facultyRecTypeModel.name, facultyRecTypeModel.developerName}
                                                                                ),
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCCourseConFacultyInactiveFix, 
                                                                                    new List<Object>{facultyRecTypeModel.name, facultyRecTypeModel.developerName}
                                                                                ),
                                                                                new List<HealthCheckItemVModel>()));
            hlthChkGroupVMod.totalChecks++;
            return hlthChkGroupVMod;
        }

       hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('03',
                                                                          Label.stgDefaultFacultyTypeTitle,
                                                                          'Pass',
                                                                          Label.stgHealthCheckStatusPassed,
                                                                          this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                Label.stgHCRecordTypeValid, 
                                                                                new List<Object>{facultyRecTypeModel.name, facultyRecTypeModel.developerName}
                                                                            ),
                                                                          Label.stgHealthCheckFixNotApplicable,
                                                                          new List<HealthCheckItemVModel>()));
        hlthChkGroupVMod.totalChecks++;
        hlthChkGroupVMod.passedChecks++;

        return hlthChkGroupVMod;                                                                                      

    }

    /**********************************************************************************
    * @description Generates a HealthCheckGroupVModel for an Account Model health check based
    * on whether the Administrative and Household RT settings are the same.
    * @param  accountSettingsMod An AccountModelSettingsModel
    * @return A HealthCheckGroupVModel with a status of Fail if the Admin and HH Accounts are not
    * unique; a HealthCheckGroupVModel with a status of Pass otherwise.
    **********************************************************************************/
    @TestVisible
    private HealthCheckGroupVModel getCourseConnectionRecordTypeUniquenessHealthCheckItems(CourseConnectionSettingsModel courseConnectionSettingsModel) {

        List<HealthCheckItemVModel> hlthChkItemsList = new List<HealthCheckItemVModel>();

        HealthCheckGroupVModel hlthChkGroupVMod = new HealthCheckGroupVModel(
            '',
            '',
            0,
            0,
            new List<String>(),
            new List<HealthCheckItemVModel>()
        );
                                    
        Boolean isStudentEqualToFacultyRT = (courseConnectionSettingsModel.facultyRecordTypeId == courseConnectionSettingsModel.studentRecordTypeId);

        if (isStudentEqualToFacultyRT == true) {
            hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('04',
                                                           Label.stgHCCourseConRecordTypesUnique,
                                                           'Fail',
                                                           Label.stgHealthCheckStatusFailed,
                                                           Label.stgHCCourseConRecordTypesNotUnique,
                                                           Label.stgHCCourseConRecordTypesNotUniqueFix,
                                                           new List<HealthCheckItemVModel>()));

            hlthChkGroupVMod.totalChecks++;
            return hlthChkGroupVMod;
        }

        hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('04',
                                                       Label.stgHCCourseConRecordTypesUnique,
                                                       'Pass',
                                                       Label.stgHealthCheckStatusPassed,
                                                       Label.stgHCCourseConRecordTypesUniqueDesc,
                                                       Label.stgHealthCheckFixNotApplicable,
                                                       new List<HealthCheckItemVModel>()));

        hlthChkGroupVMod.totalChecks++;
        hlthChkGroupVMod.passedChecks++;

        return hlthChkGroupVMod;
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

    /*****************************************************************************
    * @description Retrieve an instance of the StringHandlingService class.
    * @return An instance of StringHandlingService.
    *****************************************************************************/
    @TestVisible
    private StringHandlingService locateStringHandlingService() {
        return StringHandlingService.getInstance();
    }
}