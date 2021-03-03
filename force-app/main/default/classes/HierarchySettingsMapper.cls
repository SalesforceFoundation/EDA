
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
* @description Acts as the Mapper Layer for the Hierarchy Settings service, 
* abstracting the data in the database so we can use mocks and stubs in our Singleton Pattern.
*/
public virtual with sharing class HierarchySettingsMapper {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static HierarchySettingsMapper instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected HierarchySettingsMapper() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of HierarchySettingsMapper.
    **********************************************************************************/
    public static HierarchySettingsMapper getInstance() {
        if (instance == null) {
            instance = new HierarchySettingsMapper();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Retrieve a model representing the values set in Hierarchy Settings.
    * @return A HierarchySettingsModel.
    **********************************************************************************/
    public HierarchySettingsModel getHierarchySettings() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettingsFacade.getSettings();
        return new HierarchySettingsModel(hierarchySettings);
    }

    /**********************************************************************************
    * @description Retrieve the describe result for a specified Hierarchy Settings field.
    * @return A Schema.DescribeFieldResult for the specified Hierarchy Settings field.
    **********************************************************************************/
    public Schema.DescribeFieldResult getHierarchySettingsField(String apiName) {
        return UTIL_Describe.getFieldDescribe(
            UTIL_Namespace.StrTokenNSPrefix('Hierarchy_Settings__c'), 
            UTIL_Namespace.StrTokenNSPrefix(apiName)
        );
    }

    /****************************************************************************************************
    * @description Update a HierarchySettingsModel to reflect changes made to setting values.
    * @param hierarchySettingsChangesModel A HierarchySettingsChangesModel containing all updates to Hierarchy Settings.
    * @return A HierarchySettingsModel with updates recorded.
    ****************************************************************************************************/
    public HierarchySettingsModel updateHierarchySettings(HierarchySettingsChangesModel hierarchySettingsChangesModel) {

        HierarchySettingsModel updatedHierarchySettingsModel = this.getHierarchySettings();

        updatedHierarchySettingsModel = this.updateHierarchySettingsWithSingleValues(
            updatedHierarchySettingsModel,
            hierarchySettingsChangesModel.settingsSingleValueBySettingsName
        );

        updatedHierarchySettingsModel = this.updateHierarchySettingsWithListValues(
            updatedHierarchySettingsModel,
            hierarchySettingsChangesModel.settingsListSettingsName
        );

        return  updatedHierarchySettingsModel;
    }

    /****************************************************************************************************
    * @description Helper method to update Hierarchy Settings with values represented by primitive data types.
    * @param  singleValueSettingUpdatesByName A map of updated hierarchy settings with primitive data types
    * @return A HierarchySettingsModel with updates to settings with single values recorded.
    ****************************************************************************************************/
    @TestVisible
    public HierarchySettingsModel updateHierarchySettingsWithSingleValues(
        HierarchySettingsModel hierarchySettingsModelToUpdate,
        Map<String, String> singleValueSettingUpdatesByName) 
    {
        if (singleValueSettingUpdatesByName.isEmpty() == true) {
            return hierarchySettingsModelToUpdate;
        }

        for (String changedSettingName : singleValueSettingUpdatesByName.keySet()) {
            Schema.DescribeFieldResult fieldDescribeResult = this.getHierarchySettingsField(changedSettingName);
            Schema.DisplayType displayType = fieldDescribeResult.getType();

            try{
                if (displayType == Schema.DisplayType.STRING) {
                    String hierarchySettingValue = (String)singleValueSettingUpdatesByName.get(changedSettingName);
                    hierarchySettingsModelToUpdate.hierarchySettings.put(changedSettingName, hierarchySettingValue);
                }

                if (displayType == Schema.DisplayType.BOOLEAN) {
                    Boolean hierarchySettingValue = Boolean.valueOf(singleValueSettingUpdatesByName.get(changedSettingName));
                    hierarchySettingsModelToUpdate.hierarchySettings.put(changedSettingName, hierarchySettingValue);
                }

                if (displayType == Schema.DisplayType.DATETIME) {
                    Datetime hierarchySettingValue = Datetime.valueOf(singleValueSettingUpdatesByName.get(changedSettingName));
                    hierarchySettingsModelToUpdate.hierarchySettings.put(changedSettingName, hierarchySettingValue);
                }

            } catch (UTIL_Describe.SchemaDescribeException e) {
                UTIL_Debug.debug('****SchemaDescribeException encountered: ' + e.getMessage());
                throw new InvalidSettingsException(Label.stgErrorInvalidSettings);
            } catch (System.StringException e) {
                UTIL_Debug.debug('****StringException encountered: ' + e.getMessage());
                throw new InvalidSettingsException(Label.stgErrorInvalidSettings);
            } catch (System.TypeException e) {
                UTIL_Debug.debug('****TypeException encountered: ' + e.getMessage());
                throw new InvalidSettingsException(Label.stgErrorInvalidSettings);
            } catch (Exception e) {
                UTIL_Debug.debug('****Exception encountered: ' + e.getMessage());
                throw new InvalidSettingsException(Label.stgErrorInvalidSettings);
            }
        }

        return hierarchySettingsModelToUpdate;
    }

    /****************************************************************************************************
    * @description Helper method to update Hierarchy Settings with values represented by collections.
    * @param  listValueSettingUpdatesByName A map of updated hierarchy settings with collections
    * @return A HierarchySettingsModel with updates to settings with collections recorded.
    ****************************************************************************************************/
    @TestVisible
    private HierarchySettingsModel updateHierarchySettingsWithListValues(
        HierarchySettingsModel hierarchySettingsModelToUpdate,
        Map<String, List<String>> listValueSettingUpdatesByName) 
    {
        if (listValueSettingUpdatesByName.isEmpty() == true) {
            return hierarchySettingsModelToUpdate;
        }

        for (String changedSettingName : listValueSettingUpdatesByName.keySet()) {
            Schema.DescribeFieldResult fieldDescribeResult = this.getHierarchySettingsField(changedSettingName);

            try {
                String hierarchySettingValue = this.denormalizeListSettingChange(listValueSettingUpdatesByName.get(changedSettingName));
                hierarchySettingsModelToUpdate.hierarchySettings.put(changedSettingName, hierarchySettingValue);

            } catch (UTIL_Describe.SchemaDescribeException e) {
                UTIL_Debug.debug('****SchemaDescribeException encountered: ' + e.getMessage());
                throw new InvalidSettingsException(Label.stgErrorInvalidSettings);
            } catch (System.StringException e) {
                UTIL_Debug.debug('****StringException encountered: ' + e.getMessage());
                throw new InvalidSettingsException(Label.stgErrorInvalidSettings);
            } catch (System.TypeException e) {
                System.debug('Type Exception');
                UTIL_Debug.debug('****TypeException encountered: ' + e.getMessage());
                throw new InvalidSettingsException(Label.stgErrorInvalidSettings);
            } catch (Exception e) {
                UTIL_Debug.debug('****Exception encountered: ' + e.getMessage());
                throw new InvalidSettingsException(Label.stgErrorInvalidSettings);
            }
        }

        return hierarchySettingsModelToUpdate;
    }

    /******************************************************************************************************
    * @description Converts a List of Strings to a semicolon-delimited string.
    * @param  collectionTypeHierarchySettingsUpdateList List<String> to convert
    * @return A semicolon-delimited String representing each String in the specified list.
    ******************************************************************************************************/
    @TestVisible
    private String denormalizeListSettingChange(List<String> collectionTypeHierarchySettingsUpdateList) {
        return String.join(collectionTypeHierarchySettingsUpdateList, ';');
    }

    /********************************************************************************************************
    * @description A custom exception class to represent errors associated with updates to Hierarchy Settings.
    ********************************************************************************************************/
    public class InvalidSettingsException extends Exception {}
}
