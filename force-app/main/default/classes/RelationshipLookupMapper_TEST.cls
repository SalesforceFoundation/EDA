/*
    Copyright (c) 2020, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
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
 * @date 2020
 * @group
 * @group-content ../../ApexDocContent/Tests.htm
 * @description Test class for RelationshipLookupMapper
 */
@isTest
private class RelationshipLookupMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * RelationshipLookupMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        RelationshipLookupMapper relationshipLookupMapperInstance = RelationshipLookupMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            RelationshipLookupMapper.instance,
            relationshipLookupMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            relationshipLookupMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * RelationshipLookupMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        RelationshipLookupMapper relationshipLookupMapperInstance1 = RelationshipLookupMapper.getInstance();
        RelationshipLookupMapper relationshipLookupMapperInstance2 = RelationshipLookupMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            RelationshipLookupMapper.instance,
            relationshipLookupMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            relationshipLookupMapperInstance1,
            relationshipLookupMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            relationshipLookupMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getRelationshipLookupModels method returns a list of relationship lookup models
     *****************************************************************************************************************************/
    @isTest
    private static void getRelationshipLookupModels() {
        RelationshipLookupMapper relationshipLookupMapperInstance = RelationshipLookupMapper.getInstance();

        insert new Relationship_Lookup__c(
            Name = 'test' + system.now(),
            Active__c = true,
            Female__c = 'wife',
            Male__c = 'husband',
            Neutral__c = 'spouse'
        );

        Test.startTest();
        List<RelationshipLookupModel> relationshipLookupModelsList = relationshipLookupMapperInstance.getRelationshipLookupModels();
        Test.stopTest();

        List<Relationship_Lookup__c> relationshipLookupList = UTIL_CustomSettingsFacade.getReciprocalSettings();

        System.assertEquals(1, relationshipLookupList.size(), 'Only one item should be available in the list');
        System.assertEquals(
            relationshipLookupList[0].Name,
            relationshipLookupModelsList[0].name,
            'Retrieved model\'s name should be same as Name from settings'
        );
        System.assertEquals(
            relationshipLookupList[0].Active__c,
            relationshipLookupModelsList[0].isActive,
            'Retrieved model\'s isActive should be same as isActive__c from settings'
        );
        System.assertEquals(
            relationshipLookupList[0].Female__c,
            relationshipLookupModelsList[0].femaleValue,
            'Retrieved model\'s femaleValue should be same as Female__c from settings'
        );
        System.assertEquals(
            relationshipLookupList[0].Male__c,
            relationshipLookupModelsList[0].maleValue,
            'Retrieved model\'s maleValue should be same as Male__c from settings'
        );
        System.assertEquals(
            relationshipLookupList[0].Neutral__c,
            relationshipLookupModelsList[0].neutralValue,
            'Retrieved model\'s neutralValue should be same as Neutral__c from settings'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the insertRelationshipLookupModel inserts a record into Relationship_Lookup__c
     *****************************************************************************************************************************/
    @isTest
    private static void insertRelationshipLookupModel() {
        String relationshipLookupName = 'Father';
        String femaleValue = 'Daughter';
        String maleValue = 'Son';
        String neutralValue = 'Child';
        Boolean isActive = false;
        RelationshipLookupMapper relationshipLookupMapperInstance = RelationshipLookupMapper.getInstance();

        Test.startTest();
        relationshipLookupMapperInstance.insertRelationshipLookupModel(
            new RelationshipLookupModel(relationshipLookupName, isActive, femaleValue, maleValue, neutralValue)
        );
        Test.stopTest();

        Relationship_Lookup__c insertedRelationshipLookup = Relationship_Lookup__c.getInstance(relationshipLookupName);
        System.assertEquals(
            relationshipLookupName,
            insertedRelationshipLookup.Name,
            'Inserted record\'s name should be ' + relationshipLookupName
        );
        System.assertEquals(
            isActive,
            insertedRelationshipLookup.Active__c,
            'Inserted record\'s isActive__c should be ' + isActive
        );
        System.assertEquals(
            femaleValue,
            insertedRelationshipLookup.Female__c,
            'Inserted record\'s Female__c should be ' + femaleValue
        );
        System.assertEquals(
            maleValue,
            insertedRelationshipLookup.Male__c,
            'Inserted record\'s Male__c should be ' + maleValue
        );
        System.assertEquals(
            neutralValue,
            insertedRelationshipLookup.Neutral__c,
            'Inserted record\'s Neutral__c should be ' + neutralValue
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the updateRelationshipLookupModel updates a record in Relationship_Lookup__c
     *****************************************************************************************************************************/
    @isTest
    private static void updateRelationshipLookupModel() {
        String oldRelationshipLookupName = 'Test';
        String newRelationshipLookupName = 'Father';
        String femaleValue = 'Daughter';
        String maleValue = 'Son';
        String neutralValue = 'Child';
        Boolean isActive = true;
        RelationshipLookupMapper relationshipLookupMapperInstance = RelationshipLookupMapper.getInstance();

        insert new Relationship_Lookup__c(
            Name = oldRelationshipLookupName,
            Active__c = false,
            Female__c = 'wife',
            Male__c = 'husband',
            Neutral__c = 'spouse'
        );

        Test.startTest();
        relationshipLookupMapperInstance.updateRelationshipLookupModel(
            oldRelationshipLookupName,
            new RelationshipLookupModel(newRelationshipLookupName, isActive, femaleValue, maleValue, neutralValue)
        );
        Test.stopTest();

        Relationship_Lookup__c updatedOldRelationshipLookup = Relationship_Lookup__c.getInstance(
            oldRelationshipLookupName
        );
        Relationship_Lookup__c updatedRelationshipLookup = Relationship_Lookup__c.getInstance(
            newRelationshipLookupName
        );

        System.assertEquals(
            null,
            updatedOldRelationshipLookup,
            'A relationship record with old name should not exist: ' + oldRelationshipLookupName
        );
        System.assertEquals(
            newRelationshipLookupName,
            updatedRelationshipLookup.Name,
            'Inserted record\'s name should be ' + newRelationshipLookupName
        );
        System.assertEquals(
            isActive,
            updatedRelationshipLookup.Active__c,
            'Inserted record\'s isActive__c should be ' + isActive
        );
        System.assertEquals(
            femaleValue,
            updatedRelationshipLookup.Female__c,
            'Inserted record\'s Female__c should be ' + femaleValue
        );
        System.assertEquals(
            maleValue,
            updatedRelationshipLookup.Male__c,
            'Inserted record\'s Male__c should be ' + maleValue
        );
        System.assertEquals(
            neutralValue,
            updatedRelationshipLookup.Neutral__c,
            'Inserted record\'s Neutral__c should be ' + neutralValue
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the deleteRelationshipLookupModel deletes a record in Relationship_Lookup__c
     *****************************************************************************************************************************/
    @isTest
    private static void deleteRelationshipLookupModel() {
        String relationshipLookupName = 'Father';
        String femaleValue = 'Daughter';
        String maleValue = 'Son';
        String neutralValue = 'Child';
        Boolean isActive = true;
        RelationshipLookupMapper relationshipLookupMapperInstance = RelationshipLookupMapper.getInstance();

        insert new Relationship_Lookup__c(
            Name = relationshipLookupName,
            Active__c = isActive,
            Female__c = femaleValue,
            Male__c = maleValue,
            Neutral__c = neutralValue
        );
        Relationship_Lookup__c existingRelationshipLookup = Relationship_Lookup__c.getInstance(relationshipLookupName);

        Test.startTest();
        relationshipLookupMapperInstance.deleteRelationshipLookupModel(
            new RelationshipLookupModel(relationshipLookupName, isActive, femaleValue, maleValue, neutralValue)
        );
        Test.stopTest();

        Relationship_Lookup__c deletedRelationshipLookup = Relationship_Lookup__c.getInstance(relationshipLookupName);

        System.assertNotEquals(
            null,
            existingRelationshipLookup,
            'Inserted relationship record with name \'' +
            relationshipLookupName +
            '\' should exist prior to delete'
        );
        System.assertEquals(
            relationshipLookupName,
            existingRelationshipLookup.Name,
            'Inserted record\'s name should be ' + relationshipLookupName
        );
        System.assertEquals(
            null,
            deletedRelationshipLookup,
            'A relationship record with name \'' +
            relationshipLookupName +
            '\' should not exist'
        );
    }
}
