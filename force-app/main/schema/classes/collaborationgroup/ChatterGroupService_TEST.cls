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
 * @description Test class for ChatterGroupService class.
 */
@isTest
private with sharing class ChatterGroupService_TEST {
    /**
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ChatterGroupService class when one does not already exist.
     */
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ChatterGroupService serviceInstance = ChatterGroupService.getInstance();
        Test.stopTest();

        System.assertEquals(
            ChatterGroupService.instance,
            serviceInstance,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(true, serviceInstance != null, 'Instance of service class should not be null.');
    }

    /**
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ChatterGroup class when one already exists.
     */
    @isTest
    private static void getInstanceExisting() {
        ChatterGroupService serviceInstance1 = ChatterGroupService.getInstance();

        Test.startTest();
        ChatterGroupService serviceInstance2 = ChatterGroupService.getInstance();
        Test.stopTest();

        System.assertEquals(
            ChatterGroupService.instance,
            serviceInstance1,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(
            serviceInstance1,
            serviceInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );
        System.assertEquals(true, serviceInstance2 != null, 'Instance of service class should not be null.');
    }

    /**
     * @description Test method to verify that a chatter group model is retrieved by an Id
     */
    @isTest
    private static void getChatterGroupModelById() {
        Id chatterGroupId = UTIL_UnitTestData_TEST.getChatterGroupNoDependencyFakeId();
        ChatterGroupMapper.instance = new STUB_ChatterGroupMapper(chatterGroupId);
        ChatterGroupService chatterGroupServiceInstance = ChatterGroupService.getInstance();

        Test.startTest();
        ChatterGroupModel chatterGroupModel = chatterGroupServiceInstance.getChatterGroupModelById(chatterGroupId);
        Test.stopTest();

        System.assertEquals(
            chatterGroupId,
            chatterGroupModel.Id,
            'Chatter Group Model id should match expected value.'
        );
        System.assertEquals(
            'Chatter Group Name',
            chatterGroupModel.name,
            'Chatter Group Model name should match expected value.'
        );
        System.assertEquals(
            'Chatter Group Description',
            chatterGroupModel.description,
            'Chatter Group Model description should match expected value.'
        );
        System.assertEquals(
            'https://fake.url/test.png',
            chatterGroupModel.smallPhotoUrl,
            'Chatter Group Model small photo url should match expected value.'
        );
    }

    /**
     * @description Test method to verify that getting chatter group models like a name is functional
     */
    @isTest
    private static void getChatterGroupModelsLikeName() {
        Id chatterGroupId = UTIL_UnitTestData_TEST.getChatterGroupNoDependencyFakeId();
        ChatterGroupMapper.instance = new STUB_ChatterGroupMapper(chatterGroupId);
        ChatterGroupService chatterGroupServiceInstance = ChatterGroupService.getInstance();

        Test.startTest();
        List<ChatterGroupModel> chatterGroupModelList = chatterGroupServiceInstance.getChatterGroupModelsLikeName(
            'Chatter',
            1
        );
        Test.stopTest();

        System.assertEquals(1, chatterGroupModelList.size(), 'Only 1 chatter group model should be retrieved.');
        System.assertEquals(
            chatterGroupId,
            chatterGroupModelList[0].id,
            'The chatter group model retrieved should be for the id of those specified in the mapper.'
        );
    }

    /**
     * @description Test method to verify that getting chatter group models like a name is functional
     */
    @isTest
    private static void getChatterGroupModelsLikeNameNegative() {
        Id chatterGroupId = UTIL_UnitTestData_TEST.getChatterGroupNoDependencyFakeId();
        ChatterGroupMapper.instance = new STUB_ChatterGroupMapper(chatterGroupId);
        ChatterGroupService chatterGroupServiceInstance = ChatterGroupService.getInstance();

        Test.startTest();
        List<ChatterGroupModel> chatterGroupModelList = chatterGroupServiceInstance.getChatterGroupModelsLikeName(
            'Not Chatter Group Name',
            1
        );
        Test.stopTest();

        System.assert(chatterGroupModelList.isEmpty(), 'Only 0 chatter group models should be retrieved.');
    }

    /**
     * @description Stub class to simulate the response from ChatterGroupMapper
     */
    private class STUB_ChatterGroupMapper extends ChatterGroupMapper {
        private Id chatterGroupId;

        STUB_ChatterGroupMapper(Id chatterGroupId) {
            this.chatterGroupId = chatterGroupId;
        }

        public override ChatterGroupModel getChatterGroupModelById(Id chatterGroupId) {
            return new ChatterGroupModel(
                this.chatterGroupId,
                'Chatter Group Name',
                'Chatter Group Description',
                'https://fake.url/test.png'
            );
        }

        public override List<ChatterGroupModel> getChatterGroupModelsLikeName(
            String chatterGroupNameMatch,
            Integer recordLimit
        ) {
            List<ChatterGroupModel> chatterGroupModelModelList = new List<ChatterGroupModel>();

            if ('Chatter Group Name'.toLowerCase().contains(chatterGroupNameMatch.toLowerCase())) {
                chatterGroupModelModelList.add(
                    new ChatterGroupModel(
                        this.chatterGroupId,
                        'Chatter Group Name',
                        'Chatter Group Description',
                        'https://fake.url/test.png'
                    )
                );
            }

            return chatterGroupModelModelList;
        }
    }
}
