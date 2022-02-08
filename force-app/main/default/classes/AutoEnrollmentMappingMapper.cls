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
 * @description Acts as mapper layer to Auto Enrollment Mappings.
 */
public virtual with sharing class AutoEnrollmentMappingMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static AutoEnrollmentMappingMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected AutoEnrollmentMappingMapper() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AutoEnrollmentMappingMapper.
     ******************************************************************************/
    public static AutoEnrollmentMappingMapper getInstance() {
        if (instance == null) {
            instance = new AutoEnrollmentMappingMapper();
        }

        return instance;
    }

    /**
     * @description Update Affiliations Mappings from a list of auto enrollment mapping models
     * @param autoEnrollmentMappingModelList The auto enrollment mapping models to update
     */
    public virtual List<AutoEnrollmentMappingModel> updateAffiliationMappingsFromModelList(
        List<AutoEnrollmentMappingModel> autoEnrollmentMappingModelList
    ) {
        List<Affl_Mappings__c> affiliationMappingList = new List<Affl_Mappings__c>();
        List<AutoEnrollmentMappingModel> returnList = new List<AutoEnrollmentMappingModel>();

        for (AutoEnrollmentMappingModel autoEnrollmentMappingModel : autoEnrollmentMappingModelList) {
            Affl_Mappings__c affiliationMapping = Affl_Mappings__c.getInstance(autoEnrollmentMappingModel.name);
            affiliationMapping.Auto_Program_Enrollment__c = autoEnrollmentMappingModel.active;
            affiliationMapping.Auto_Program_Enrollment_Status__c = autoEnrollmentMappingModel.status;
            affiliationMapping.Auto_Program_Enrollment_Role__c = autoEnrollmentMappingModel.role;
            affiliationMappingList.add(affiliationMapping);

            returnList.add(
                new AutoEnrollmentMappingModel(
                    affiliationMapping.name,
                    affiliationMapping.Account_Record_Type__c,
                    affiliationMapping.Auto_Program_Enrollment_Role__c,
                    affiliationMapping.Auto_Program_Enrollment_Status__c,
                    affiliationMapping.Auto_Program_Enrollment__c
                )
            );
        }
        /* sfca-disable-next-line ApexFlsViolationRule */
        update affiliationMappingList;
        return returnList;
    }
}
