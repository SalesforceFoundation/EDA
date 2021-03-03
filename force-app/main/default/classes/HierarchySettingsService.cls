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
* @description Acts as the Service Layer between the HierarchySettingsChangesController and
* the HierarchySettingsMapper.
*/
public virtual with sharing class HierarchySettingsService {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static HierarchySettingsService instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected HierarchySettingsService() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of HierarchySettingsService.
    **********************************************************************************/
    public static HierarchySettingsService getInstance() {
        if (instance == null) {
            instance = new HierarchySettingsService();
        }

        return instance;
    }

    /************************************************************************************************************
    * @description Update Hierarchy Settings fields with specified changes.
    * @param  hierarchySettingsChangesModel A HierarchySettingsChangesModel representing updates to Hierarchy Settings.
    * @return True if the updates were completed successfully, false otherwise.
    ************************************************************************************************************/ 
    public Boolean updateHierarchySettings(HierarchySettingsChangesModel hierarchySettingsChangesModel) {
        try {
            HierarchySettingsModel hierarchySettingsModel = 
            this.locateHierarchySettingsMapper().updateHierarchySettings(hierarchySettingsChangesModel);
            update hierarchySettingsModel.hierarchySettings;
        } catch (HierarchySettingsMapper.InvalidSettingsException e) {
            // invalid field mapping specified in HierarchySettingsChangesModel
        } 

        return true;
    }

    private HierarchySettingsMapper locateHierarchySettingsMapper() {
        return HierarchySettingsMapper.getInstance();
    }
}
