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
* @description Test class for RelationshipLookupSettingsService class
*/
@isTest
private class RelationshipLookupSettingsService_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * RelationshipLookupSettingsService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            RelationshipLookupSettingsService relationshipLookupSettingsServiceInstance = RelationshipLookupSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(RelationshipLookupSettingsService.instance, relationshipLookupSettingsServiceInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, relationshipLookupSettingsServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * RelationshipLookupSettingsService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            RelationshipLookupSettingsService relationshipLookupSettingsServiceInstance1 = RelationshipLookupSettingsService.getInstance();
            RelationshipLookupSettingsService relationshipLookupSettingsServiceInstance2 = RelationshipLookupSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(RelationshipLookupSettingsService.instance, relationshipLookupSettingsServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(relationshipLookupSettingsServiceInstance1, relationshipLookupSettingsServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, relationshipLookupSettingsServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /***********************************************************************************************************************************
    * @description Test method to verify that the locateRelationshipLookupMapper method returns instance of RelationshipLookupMapper
    ***********************************************************************************************************************************/
    @isTest
    private static void locateRelationshipLookupMapper() {

        Test.startTest();
            RelationshipLookupMapper relLookupMapper = RelationshipLookupSettingsService.getInstance().locateRelationshipLookupMapper();
        Test.stopTest();

        System.assertEquals(RelationshipLookupMapper.getInstance(), relLookupMapper, 'Should return the instance of RelationshipLookupMapper');

    }

    /***********************************************************************************************************************************
    * @description Test method to verify that the getRelationshipLookupModels method returns instance of getRelationshipLookup Models
    ***********************************************************************************************************************************/
    @isTest
    private static void getRelationshipLookupModels() {

        RelationshipLookupMapper.instance = new STUB_RelationshipLookupMapper();

        Test.startTest();
            List<RelationshipLookupModel> relationshipLookupModelList = RelationshipLookupSettingsService.getInstance().getRelationshipLookupModels();
        Test.stopTest();

        System.assertEquals(1, relationshipLookupModelList.size(), 'Only 1 record should be availabel in the list as we are adding only one settings to the model');
        System.assertEquals('Father', relationshipLookupModelList[0].Name, 'Retrieved model\'s name should be same as Name from settings');
        System.assertEquals(true, relationshipLookupModelList[0].isActive, 'Retrieved model\'s isActive should be same as isActive__c from settings');
        System.assertEquals('Daughter', relationshipLookupModelList[0].femaleValue, 'Retrieved model\'s femaleValue should be same as Female__c from settings');
        System.assertEquals('Son', relationshipLookupModelList[0].maleValue, 'Retrieved model\'s maleValue should be same as Male__c from settings');
        System.assertEquals('Child', relationshipLookupModelList[0].neutralValue, 'Retrieved model\'s neutralValue should be same as Neutral__c from settings');        

    }

    /***************************************************************************
    * @description Test Method to verify that duplicate relationship model names
    * are retrieved.
    ***************************************************************************/
    @isTest
    private static void getDuplicateRelationshipModelNamesFromList() {
        RelationshipLookupModel uniqueRelationshipLookupModel =
            new RelationshipLookupModel(
                'unique',
                true,
                'uniquefemale',
                'uniquemale',
                'uniqueneutral'
            );

        RelationshipLookupModel duplicateRelationshipLookupModel1 =
            new RelationshipLookupModel(
                'duplicate',
                true,
                'duplicatefemale1',
                'duplicatemale1',
                'duplicateneutral1'
            );
        RelationshipLookupModel duplicateRelationshipLookupModel2 =
            new RelationshipLookupModel(
                'duplicate',
                true,
                'duplicatefemale2',
                'duplicatemale2',
                'duplicateneutral2'
            );

        List<RelationshipLookupModel> relationshipLookupModelList
            = new List<RelationshipLookupModel>{
                uniqueRelationshipLookupModel,
                duplicateRelationshipLookupModel1,
                duplicateRelationshipLookupModel2
            };

        RelationshipLookupSettingsService relationshipLookupSettingsService
            = RelationshipLookupSettingsService.getInstance(); 

        Test.startTest();
            Set<String> duplicateNameSet =
                relationshipLookupSettingsService.getDuplicateRelationshipModelNamesFromList(
                    relationshipLookupModelList
                );
        Test.stopTest();

        System.assertEquals(
            1,
            duplicateNameSet.size(),
            'Duplicate name set size should equal 1'
        );
        System.assertEquals(
            true,
            duplicateNameSet.contains('duplicate'),
            'Duplicate name set should contain name for duplicate'
        );
        System.assertNotEquals(
            true,
            duplicateNameSet.contains('unique'),
            'Duplicate name set should not contain name for unique.'
        );
    }

    /***********************************************************************************************************************************
    ****************************************************** STUBS ***********************************************************************
    ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from RelationshipLookupMapper to return a RelationshipLookup model
    **************************************************************************************************************************************/ 
    private class STUB_RelationshipLookupMapper extends RelationshipLookupMapper {

        public override List<RelationshipLookupModel> getRelationshipLookupModels() {

            List<RelationshipLookupModel> RelationshipLookupModelList= new List<RelationshipLookupModel>();

            RelationshipLookupModel accModelSettingsModel = new RelationshipLookupModel('Father', true, 'Daughter', 'Son', 'Child');
            RelationshipLookupModelList.add(accModelSettingsModel);

            return RelationshipLookupModelList;
        }
    }
}