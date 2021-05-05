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
 * @description View mapper to generate view models associated with Primary Affiliations Settings funtionality.
 */
public virtual with sharing class ProgramSettingsVMapper {
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static ProgramSettingsVMapper instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected ProgramSettingsVMapper() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AffiliationsSettingsVMapper.
     **********************************************************************************/
    public static ProgramSettingsVMapper getInstance() {
        if (instance == null) {
            instance = new ProgramSettingsVMapper();
        }

        return instance;
    }

    /**********************************************************************************************************
     * @description Retrieve an instance of ProgramSettingsVModel
     * @return An instance of ProgramSettingsVModel
     *********************************************************************************************************/
    public virtual ProgramSettingsVModel getProgramSettingsVModel() {
        List<AffiliationMappingsModel> affiliationMappingsModelsList = this.locateAffiliationMappingsService()
            .getAffiliationMappingsModels();

        Map<Id, RecordTypeModel> accRecordTypeModelsById = this.locateRecordTypeService()
            .getModelByIdMapForSObjectType(Account.SObjectType);

        Map<String, RecordTypeModel> accountRecordTypeModelsByName = this.locateRecordTypeService()
            .getRecordTypeModelByName(accRecordTypeModelsById);
        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel = this.locateRecordTypeService()
            .getRecordTypeModelByLabel(accRecordTypeModelsById);

        List<AutoEnrollmentMappingVModel> autoEnrollmentMappingVModelsList = new List<AutoEnrollmentMappingVModel>();

        for (AffiliationMappingsModel affiliationMappingsModel : affiliationMappingsModelsList) {
            if (affiliationMappingsModel.autoProgramEnrollment != false) {
                autoEnrollmentMappingVModelsList.add(
                    this.getAutoEnrollmentMappingVModel(
                        affiliationMappingsModel,
                        accountRecordTypeModelsByName,
                        accountRecordTypeModelsByLabel
                    )
                );
            }
        }

        return new ProgramSettingsVModel(autoEnrollmentMappingVModelsList);
    }

    /**********************************************************************************************************
     * @description Generate a view model representing the auto enrollment mapping.
     * @param  affiliationMappingsModel A model representing the affililation mapping
     * @param  accountRecordTypeModelsByName A Map of Account Record Type models by developer name
     * @param  accountRecordTypeModelsByLabel A Map of Account Record Type models by label
     * @return An instance of AutoEnrollmentMappingVModel
     **********************************************************************************************************/
    @TestVisible
    protected AutoEnrollmentMappingVModel getAutoEnrollmentMappingVModel(
        AffiliationMappingsModel affiliationMappingsModel,
        Map<String, RecordTypeModel> accountRecordTypeModelsByName,
        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel
    ) {
        String accountRecordTypeName = affiliationMappingsModel.accountRecordTypeFieldValue;
        String accountRecordTypeLabel = affiliationMappingsModel.accountRecordTypeFieldValue;

        // get RecordType model matching Account Record Type specified in Affiliation mapping
        RecordTypeModel recordTypeModel = this.locateRecordTypeService()
            .getRecordTypeModelFromNameAndLabelMaps(
                affiliationMappingsModel.accountRecordTypeFieldValue,
                accountRecordTypeModelsByName,
                accountRecordTypeModelsByLabel
            );

        if (recordTypeModel != null) {
            accountRecordTypeName = recordTypeModel.developerName;
            accountRecordTypeLabel = recordTypeModel.name;
        }

        return new AutoEnrollmentMappingVModel(
            accountRecordTypeName,
            accountRecordTypeLabel,
            affiliationMappingsModel.autoProgramEnrollmentStatus == '""'
                ? ''
                : affiliationMappingsModel.autoProgramEnrollmentStatus,
            affiliationMappingsModel.autoProgramEnrollmentRole == '""'
                ? ''
                : affiliationMappingsModel.autoProgramEnrollmentRole
        );
    }

    /*****************************************************************************
     * @description Retrieve an instance of the AffiliationMappingsService class.
     * @return An instance of AffiliationMappingsService.
     *****************************************************************************/
    @TestVisible
    private AffiliationMappingsService locateAffiliationMappingsService() {
        return AffiliationMappingsService.getInstance();
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