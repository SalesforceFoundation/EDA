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
 * @group-content ../../ApexDocContent/EdaSettings.htm
 * @description View mapper to generate view models associated with Course Connection Settings funtionality.
 */
public virtual with sharing class CourseConnectionSettingsVMapper {
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static CourseConnectionSettingsVMapper instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected CourseConnectionSettingsVMapper() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of CourseConnectionSettingsVMapper.
     **********************************************************************************/
    public static CourseConnectionSettingsVMapper getInstance() {
        if (instance == null) {
            instance = new CourseConnectionSettingsVMapper();
        }

        return instance;
    }

    /**********************************************************************************************************
     * @description Retrieve a CourseConnectionSettingsVModel with proper values populated.
     * @return  A CourseConnectionSettingsVModel
     *********************************************************************************************************/
    public virtual CourseConnectionSettingsVModel getCourseConnectionSettingsVModel() {
        CourseConnectionSettingsModel courseConnectionSettingsModel = this.locateCourseConnectionSettingsService()
            .getCourseConnectionSettingsModel();

        // get all active Course Connection record types in org
        Map<Id, RecordTypeModel> activeCourseConnRecordTypeModelsById = this.locateRecordTypeService()
            .getActiveRecordTypeModelsById(
                this.locateRecordTypeService().getModelByIdMapForSObjectType(Course_Enrollment__c.SObjectType).values()
            );

        // populate available combobox options with active Course Connection record types
        List<ComboboxValueVModel> activeRecordTypeComboboxValueVModelsList = this.getComboboxVModelOptionsForActiveCourseConnRecordTypes(
            activeCourseConnRecordTypeModelsById.values()
        );

        // generate comboboxVModel for Default Active Student Record Type setting with selected value set as current value in hierarchy settings
        ComboboxVModel studentRecTypeComboboxVModel = new ComboboxVModel(
            courseConnectionSettingsModel.studentRecordTypeId,
            activeRecordTypeComboboxValueVModelsList
        );

        // generate comboboxVModels for Default Faculty Student Record Type setting with selected value set as current value in hierarchy settings
        ComboboxVModel facultyRecTypeComboboxVModel = new ComboboxVModel(
            courseConnectionSettingsModel.facultyRecordTypeId,
            activeRecordTypeComboboxValueVModelsList
        );

        return new CourseConnectionSettingsVModel(
            courseConnectionSettingsModel.courseConnectionsEnabled,
            studentRecTypeComboboxVModel,
            facultyRecTypeComboboxVModel
        );
    }

    /**********************************************************************************************************************
     * @description Helper method to generate a list of comboboxValueVModels for all active Course Connection record types.
     * @param  activeCourseConnRecordTypeModelsList A list of RecordType models corresponding to active Course Connection record types.
     * @return A List<ComboboxValueVModel> containing comboboxValueVModels for all active Course Connection record types.
     **********************************************************************************************************************/
    @TestVisible
    private List<ComboboxValueVModel> getComboboxVModelOptionsForActiveCourseConnRecordTypes(
        List<RecordTypeModel> activeCourseConnRecordTypeModelsList
    ) {
        List<ComboboxValueVModel> activeRecordTypeComboboxValueVModelsList = new List<ComboboxValueVModel>();

        for (RecordTypeModel activeCourseConnRecordTypeModel : activeCourseConnRecordTypeModelsList) {
            activeRecordTypeComboboxValueVModelsList.add(
                new ComboboxValueVModel(activeCourseConnRecordTypeModel.name, activeCourseConnRecordTypeModel.id)
            );
        }

        return activeRecordTypeComboboxValueVModelsList;
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
