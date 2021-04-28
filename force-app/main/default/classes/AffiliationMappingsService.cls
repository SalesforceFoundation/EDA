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
 * @description Acts as service layer to AffiliationMappingsMapper.
 */
public virtual with sharing class AffiliationMappingsService {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static AffiliationMappingsService instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected AffiliationMappingsService() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AffiliationMappingsService.
     ******************************************************************************/
    public static AffiliationMappingsService getInstance() {
        if (instance == null) {
            instance = new AffiliationMappingsService();
        }

        return instance;
    }

    /*****************************************************************************
     * @description Retrieves a list of models representing all Affiliation Mappings
     * configured in EDA Settings.
     * @return A list of AffiliationMappingsModel
     *****************************************************************************/
    public virtual List<AffiliationMappingsModel> getAffiliationMappingsModels() {
        return this.locateAffiliationMappingsMapper().getAffiliationMappingsModel();
    }

    /********************************************************************************************************************************************
     * @description Insert an affiliation mapping
     * @param  affiliationMappingName A string representing the name of the new affiliation mapping
     * @param  recordTypeName A string representing the Record Type name for the new affiliation mapping
     * @param  contactFieldName A string representing the field label for the Contact primary affiliation field associated with the new affiliation mapping
     * @param  autoProgramEnrollment A boolean indicating whether auto program enrollment is enabled for the new affiliation mapping
     * @param  autoProgramEnrollmentStatus A string representing the auto program enrollment status of the new affiliation mapping
     * @param  autoProgramEnrollmentRole A string representing the auto program enrollment role of the new affiliation mapping
     ********************************************************************************************************************************************/
    public void insertAffiliationMappings(
        String affiliationMappingName,
        String recordTypeName,
        String contactFieldName
    ) {
        this.locateUserPermissionService().checkViewSetupForCurrentUser();

        this.locateAffiliationMappingsMapper()
            .insertAffiliationMappingModel(
                new AffiliationMappingsModel(affiliationMappingName, recordTypeName, contactFieldName)
            );
    }

    /*****************************************************************************
     * @description Checks user permissions, creates a model and passes to
     * updateAffiliationMappings.
     *****************************************************************************/
    public void updateAffiliationMappings(String mappingName, String accRecordType, String conPrimaryAfflField) {
        this.locateUserPermissionService().checkViewSetupForCurrentUser();
        AffiliationMappingsModel afflMappingModel = new AffiliationMappingsModel(
            mappingName,
            accRecordType,
            conPrimaryAfflField
        );
        this.locateAffiliationMappingsMapper().updateAffiliationMappings(afflMappingModel);
    }

    /*****************************************************************************
     * @description Checks user permissions and passes AffiliationMappingsModel to
     * updateAffiliationMappings.
     *****************************************************************************/
    public void updateAutoEnrolllmentMapping(AffiliationMappingsModel affiliationMappingsModel) {
        this.locateUserPermissionService().checkViewSetupForCurrentUser();
        this.locateAffiliationMappingsMapper().updateAutoEnrollmentMapping(affiliationMappingsModel);
    }

    /*****************************************************************************************
     * @description Delete an affiliation mapping record.
     * @param  mappingName A string representing the name of the affiliation mapping to delete
     * @return A string representing the record type name associated with the deleted affiliation mapping
     *****************************************************************************************/
    public virtual String deleteAffiliationMapping(String mappingName) {
        if (this.locateUserPermissionService().checkViewSetupForCurrentUser() != true) {
            return null;
        }

        Affl_Mappings__c affiliationMappingsToDelete = Affl_Mappings__c.getInstance(mappingName);

        if (affiliationMappingsToDelete == null) {
            // no affiliation mapping matching specified name
            return null;
        }

        return this.locateAffiliationMappingsMapper()
            .deleteAffiliationMappingModel(
                new AffiliationMappingsModel(
                    affiliationMappingsToDelete.name,
                    affiliationMappingsToDelete.Account_Record_Type__c,
                    affiliationMappingsToDelete.Primary_Affl_Field__c
                )
            );
    }

    /*****************************************************************************
     * @description Retrieves an instance of the AffiliationMappingsMapper.
     * @return The instance of AffiliationMappingsMapper.
     ******************************************************************************/
    @TestVisible
    private AffiliationMappingsMapper locateAffiliationMappingsMapper() {
        return AffiliationMappingsMapper.getInstance();
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
