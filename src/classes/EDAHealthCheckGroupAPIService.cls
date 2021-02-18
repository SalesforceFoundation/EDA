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
* @description API service class for EDA HealthCheckGroup to retrieve HealthCheckGroup view models
* corresponding to specified HealthCheckDefinition models.
*/
public virtual with sharing class EDAHealthCheckGroupAPIService implements HealthCheckGroupAPIServiceInterface {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static EDAHealthCheckGroupAPIService instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    public EDAHealthCheckGroupAPIService() {}

    /******************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of HealthCheckGroupAPIServiceInterface.
    ******************************************************************************/
    public static HealthCheckGroupAPIServiceInterface getInstance() {
        if (instance == null) {
            instance = new EDAHealthCheckGroupAPIService();
        }

        return instance;
    }

    /******************************************************************************************
    * @description Retrieves an instance of CourseConSettingHealthCheckVMapper. 
    * @return An instance of CourseConSettingHealthCheckVMapper.
    ******************************************************************************************/
    @TestVisible 
    private CourseConSettingHealthCheckVMapper locateCourseConSettingHealthCheckVMapper(){
        return CourseConSettingHealthCheckVMapper.getInstance();
    }

    /******************************************************************************************
    * @description Retrieves an instance of AccountModelHealthCheckVMapper. 
    * @return An instance of AccountModelHealthCheckVMapper.
    ******************************************************************************************/
    @TestVisible 
    private AccountModelHealthCheckVMapper locateAccountModelHealthCheckVMapper(){
        return AccountModelHealthCheckVMapper.getInstance();
    }

    /******************************************************************************************
    * @description Retrieves an instance of AffiliationMappingsHealthCheckVMapper. 
    * @return An instance of AffiliationMappingsHealthCheckVMapper.
    ******************************************************************************************/
    @TestVisible 
    private AffiliationMappingsHealthCheckVMapper locateAffiliationMappingsHealthCheckVMapper(){
        return AffiliationMappingsHealthCheckVMapper.getInstance();
    }

    /******************************************************************************************
    * @description Retrieves a view model representing a health check group for a specified 
    * HealthCheckDefinition.
    * @param  name The name of a HealthCheckDefinition
    * @return A HealthCheckGroupVModel representing a specified HealthCheckDefinition; null if one
    * matching the name provided does not exist.
    ******************************************************************************************/
    public virtual HealthCheckGroupVModel getHealthCheckGroup(String name){
        String lowercasedHCGroupName = name.toLowerCase();

        List<HealthCheckItemVModel> hlthChkItemsList = new List<HealthCheckItemVModel>();
        List<String> rowKeysList = new List<String>();

        switch on lowercasedHCGroupName {
            when 'courseconnectionsettings' {
                return this.locateCourseConSettingHealthCheckVMapper().getHealthCheckGroup();
            }    
            when 'accountmodel' {
                return this.locateAccountModelHealthCheckVMapper().getHealthCheckGroup();
            } 
            when 'affiliationmappings' {
                return this.locateAffiliationMappingsHealthCheckVMapper().getHealthCheckGroup();
            } 
            when 'reciprocalrelationship' {
                return this.locateReciprocalRelHealthCheckVMapper().getHealthCheckGroup();
            } 
            when else {
                return null;                
            }
        }
    }

    /***************************************************************************
    * @description Retrieves an instance of ReciprocalRelHealthCheckVMapper. 
    * @return An instance of ReciprocalRelHealthCheckVMapper.
    ***************************************************************************/
    @TestVisible
    private ReciprocalRelHealthCheckVMapper locateReciprocalRelHealthCheckVMapper(){
        return ReciprocalRelHealthCheckVMapper.getInstance();
    }
}