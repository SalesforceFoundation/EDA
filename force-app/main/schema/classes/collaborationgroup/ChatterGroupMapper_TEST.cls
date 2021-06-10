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
 * @description Test class for ChatterGroupMapper class.
 */
@isTest
private with sharing class ChatterGroupMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ChatterGroupMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ChatterGroupMapper mapperInstance = ChatterGroupMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ChatterGroupMapper.instance,
            mapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(true, mapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ChatterGroup class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        ChatterGroupMapper mapperInstance1 = ChatterGroupMapper.getInstance();

        Test.startTest();
        ChatterGroupMapper mapperInstance2 = ChatterGroupMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ChatterGroupMapper.instance,
            mapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            mapperInstance1,
            mapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(true, mapperInstance2 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that a chatter group model is retrieved by an Id
     ***************************************************************************************************************************/
    @isTest
    private static void getChatterGroupModelById() {
        ChatterGroupMapper chatterGroupMapperInstance = ChatterGroupMapper.getInstance();
        CollaborationGroup collaborationGroup = UTIL_UnitTestData_TEST.getCollaborationGroup(
            System.now().getTime() + '@testerson.com'
        );
        insert collaborationGroup;

        List<CollaborationGroup> chatterGroupList = UTIL_UnitTestData_TEST.getCollaborationGroupList(
            System.now().getTime() + 'EDA',
            2
        );
        insert chatterGroupList;

        CollaborationGroup chatterGroupToTest = [
            SELECT Id, Name, Description, SmallPhotoUrl
            FROM CollaborationGroup
            WHERE Id = :collaborationGroup.id
        ];

        Test.startTest();
        ChatterGroupModel chatterGroupModel = chatterGroupMapperInstance.getChatterGroupModelById(
            chatterGroupToTest.Id
        );
        Test.stopTest();

        System.assertEquals(
            chatterGroupToTest.Id,
            chatterGroupModel.Id,
            'Chatter Group Model id should match chatter group id.'
        );
        System.assertEquals(
            chatterGroupToTest.Name,
            chatterGroupModel.name,
            'Chatter Group Model name should match chatter group name.'
        );
        System.assertEquals(
            chatterGroupToTest.Description,
            chatterGroupModel.description,
            'Chatter Group Model description should match chatter group description.'
        );
        System.assertEquals(
            chatterGroupToTest.SmallPhotoUrl,
            chatterGroupModel.smallPhotoUrl,
            'Chatter Group Model small photo url should match chatter group small photo url.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that getting chatter group models like a name is functional
     ***************************************************************************************************************************/
    @isTest
    private static void getChatterGroupModelsLikeName() {
        ChatterGroupMapper chatterGroupMapperInstance = ChatterGroupMapper.getInstance();
        List<CollaborationGroup> chatterGroupList = UTIL_UnitTestData_TEST.getCollaborationGroupList(
            System.now().getTime() + 'EDA',
            2
        );
        insert chatterGroupList;

        Map<Id, CollaborationGroup> chatterGroupsByIdsBeforeQuery = new Map<Id, CollaborationGroup>(chatterGroupList);

        Map<Id, CollaborationGroup> chatterGroupsByIds = new Map<Id, CollaborationGroup>(
            [
                SELECT Id, Name, Description, SmallPhotoUrl
                FROM CollaborationGroup
                WHERE Id IN :chatterGroupsByIdsBeforeQuery.keySet()
            ]
        );

        Test.startTest();
        List<ChatterGroupModel> chatterGroupModelList = chatterGroupMapperInstance.getChatterGroupModelsLikeName(
            'EDA',
            1
        );
        Test.stopTest();

        System.assertEquals(1, chatterGroupModelList.size(), 'Only 1 chatter group model should be retrieved.');
        System.assertNotEquals(
            null,
            chatterGroupsByIds.get(chatterGroupModelList[0].id),
            'The chatter group model retrieved should be within the map of those created.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that getting chatter group models like a name is functional
     ***************************************************************************************************************************/
    @isTest
    private static void getChatterGroupModelsLikeNameNegative() {
        ChatterGroupMapper chatterGroupMapperInstance = ChatterGroupMapper.getInstance();
        List<CollaborationGroup> chatterGroupList = UTIL_UnitTestData_TEST.getCollaborationGroupList(
            System.now().getTime() + 'EDA',
            2
        );
        insert chatterGroupList;

        Map<Id, CollaborationGroup> chatterGroupsByIdsBeforeQuery = new Map<Id, CollaborationGroup>(chatterGroupList);

        Map<Id, CollaborationGroup> chatterGroupsByIds = new Map<Id, CollaborationGroup>(
            [
                SELECT Id, Name, Description, SmallPhotoUrl
                FROM CollaborationGroup
                WHERE Id IN :chatterGroupsByIdsBeforeQuery.keySet()
            ]
        );

        Test.startTest();
        List<ChatterGroupModel> chatterGroupModelList = chatterGroupMapperInstance.getChatterGroupModelsLikeName(
            'Doesn\'t Exist',
            1
        );
        Test.stopTest();

        System.assert(chatterGroupModelList.isEmpty(), 'No chatter group models should be retrieved.');
    }
}
