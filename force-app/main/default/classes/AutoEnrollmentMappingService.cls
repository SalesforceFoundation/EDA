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
 * @group Settings
 * @group-content ../../ApexDocContent/Settings.htm
 * @description Acts as service layer for Auto Enrollment Mappings
 */
public virtual with sharing class AutoEnrollmentMappingService {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static AutoEnrollmentMappingService instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected AutoEnrollmentMappingService() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AutoEnrollmentMappingService.
     ******************************************************************************/
    public static AutoEnrollmentMappingService getInstance() {
        if (instance == null) {
            instance = new AutoEnrollmentMappingService();
        }

        return instance;
    }

    /*****************************************************************************
     * @description Checks user permissions and create the auto enrollment mappping.
     *****************************************************************************/
    public virtual AutoEnrollmentMappingModel createAutoEnrollmentMapping(
        String accountRecordType,
        String status,
        String role
    ) {
        this.locateUserPermissionService().checkViewSetupForCurrentUser();

        //Get the appropriate Record Type Model for entries with labels in the field
        RecordTypeModel accountRecordTypeModel = this.locateRecordTypeService()
            .getRecordTypeModelFromRecTypeDevName('Account', accountRecordType);

        String mappingName = this.getMappingNameByRecordTypeDeveloperNameOrName(
            accountRecordTypeModel.developerName,
            accountRecordTypeModel.name
        );

        List<AutoEnrollmentMappingModel> autoEnrollmentMappingModelListToUpdate = new List<AutoEnrollmentMappingModel>();

        autoEnrollmentMappingModelListToUpdate.add(
            new AutoEnrollmentMappingModel(mappingName, accountRecordType, role, status, true)
        );

        List<AutoEnrollmentMappingModel> returnModelList = this.locateAutoEnrollmentMappingMapper()
            .updateAffiliationMappingsFromModelList(autoEnrollmentMappingModelListToUpdate);
        return returnModelList[0];
    }

    /**
     * @description Updates auto enrollment mappings
     * @param mappingName The name of the original auto enrollment mapping
     * @param accountRecordType The account record type for the original auto enrollment mapping
     * @param newAccountRecordType The account record type for the updated auto enrollment mapping
     * @param status The status for the auto enrollment mapping
     * @param role The role for the auto enrollment mapping
     * @return the newly updated Auto Enrollment Mapping Model
     */
    public virtual AutoEnrollmentMappingModel updateAutoEnrollmentMappings(
        String mappingName,
        String accountRecordType,
        String newAccountRecordType,
        String status,
        String role
    ) {
        this.locateUserPermissionService().checkViewSetupForCurrentUser();
        if (accountRecordType == newAccountRecordType) {
            return this.updateAutoEnrollmentMapping(mappingName, accountRecordType, status, role);
        }

        return this.shiftAutoEnrollmentMapping(mappingName, accountRecordType, newAccountRecordType, status, role);
    }

    /**
     * @description Updates a single auto enrollment mapping
     * @param mappingName The name of the auto enrollment mapping
     * @param accountRecordType The account record type for the auto enrollment mapping
     * @param status The status for the auto enrollment mapping
     * @param role The role for the auto enrollment mapping
     * @return the newly updated Auto Enrollment Mapping Model
     */
    @TestVisible
    private AutoEnrollmentMappingModel updateAutoEnrollmentMapping(
        String mappingName,
        String accountRecordType,
        String status,
        String role
    ) {
        AutoEnrollmentMappingModel autoEnrollmentModel = new AutoEnrollmentMappingModel(
            mappingName,
            accountRecordType,
            role,
            status,
            true
        );
        List<AutoEnrollmentMappingModel> returnModelList = this.locateAutoEnrollmentMappingMapper()
            .updateAffiliationMappingsFromModelList(new List<AutoEnrollmentMappingModel>{ autoEnrollmentModel });
        return returnModelList[0];
    }

    /**
     * @description Updates two auto enrollment mappings, deactivating it for the record type and
     * activating it for the new one with the new values
     * @param mappingName The name of the auto enrollment mapping
     * @param accountRecordType The account record type for the original auto enrollment mapping
     * @param newAccountRecordType The account record type for the new auto enrollment mapping
     * @param status The status for the auto enrollment mapping
     * @param role The role for the auto enrollment mapping
     * @return the newly updated Auto Enrollment Mapping Model
     */
    @TestVisible
    private AutoEnrollmentMappingModel shiftAutoEnrollmentMapping(
        String mappingName,
        String accountRecordType,
        String newAccountRecordType,
        String status,
        String role
    ) {
        //Get the appropriate Record Type Model for entries with labels in the field
        RecordTypeModel accountRecordTypeModel = this.locateRecordTypeService()
            .getRecordTypeModelFromRecTypeDevName('Account', newAccountRecordType);

        String newMappingName = this.getMappingNameByRecordTypeDeveloperNameOrName(
            accountRecordTypeModel.developerName,
            accountRecordTypeModel.name
        );

        List<AutoEnrollmentMappingModel> autoEnrollmentMappingModelListToUpdate = new List<AutoEnrollmentMappingModel>();

        autoEnrollmentMappingModelListToUpdate.add(
            new AutoEnrollmentMappingModel(mappingName, accountRecordType, null, null, false)
        );
        autoEnrollmentMappingModelListToUpdate.add(
            new AutoEnrollmentMappingModel(newMappingName, newAccountRecordType, role, status, true)
        );

        List<AutoEnrollmentMappingModel> returnModelList = this.locateAutoEnrollmentMappingMapper()
            .updateAffiliationMappingsFromModelList(autoEnrollmentMappingModelListToUpdate);
        return returnModelList[1];
    }

    /**
     * @description Gets a mapping name for an affiliation mapping matching the account record type's developer name or name
     * @param accountRecordTypeDeveloperName The developer name of the record type
     * @param accountRecordTypeName The name of the record type
     * @return the name of the first affiliation mapping to matching the account record type
     */
    @TestVisible
    private virtual String getMappingNameByRecordTypeDeveloperNameOrName(
        String accountRecordTypeDeveloperName,
        String accountRecordTypeName
    ) {
        //We need to preserve the load order to account for the current state
        List<AffiliationMappingsModel> affiliationMappingsModelsList = this.locateAffiliationMappingsService()
            .getAffiliationMappingsModels();

        List<AffiliationMappingsModel> labelMatches = new List<AffiliationMappingsModel>();

        for (AffiliationMappingsModel affiliationMappingsModel : affiliationMappingsModelsList) {
            //Prioritize api name matches.
            if (affiliationMappingsModel.accountRecordTypeFieldValue == accountRecordTypeDeveloperName) {
                return affiliationMappingsModel.name;
            }

            //Fall back to label matches
            if (affiliationMappingsModel.accountRecordTypeFieldValue == accountRecordTypeName) {
                labelMatches.add(affiliationMappingsModel);
            }
        }

        if (labelMatches.isEmpty() == false) {
            return labelMatches[0].name;
        }

        return null;
    }

    /*****************************************************************************
     * @description Retrieves an instance of the AffiliationMappingsService.
     * @return The instance of AffiliationMappingsService.
     ******************************************************************************/
    @TestVisible
    private AffiliationMappingsService locateAffiliationMappingsService() {
        return AffiliationMappingsService.getInstance();
    }

    /*****************************************************************************
     * @description Retrieves an instance of the AutoEnrollmentMappingMapper.
     * @return The instance of AutoEnrollmentMappingMapper.
     ******************************************************************************/
    @TestVisible
    private AutoEnrollmentMappingMapper locateAutoEnrollmentMappingMapper() {
        return AutoEnrollmentMappingMapper.getInstance();
    }

    /*****************************************************************************
     * @description Retrieves an instance of the RecordTypeService.
     * @return The instance of RecordTypeService.
     ******************************************************************************/
    @TestVisible
    private RecordTypeService locateRecordTypeService() {
        return RecordTypeService.getInstance();
    }

    /*****************************************************************************
     * @description Retrieves an instance of the UserPermissionService.
     * @return The instance of UserPermissionService.
     ******************************************************************************/
    @TestVisible
    private UserPermissionService locateUserPermissionService() {
        return UserPermissionService.getInstance();
    }
}
