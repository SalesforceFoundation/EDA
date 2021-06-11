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
 * @group-content ../../ApexDocContent/Tests
 * @description Test class for ChatterGroupLookupResultVMapper
 */
@isTest
private with sharing class ChatterGroupLookupResultVMapper_TEST {
    /**
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ChatterGroupLookupResultVMapper class when one does not already exist.
     */
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ChatterGroupLookupResultVMapper chatterGroupLookupResultVMapperInstance = ChatterGroupLookupResultVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ChatterGroupLookupResultVMapper.instance,
            chatterGroupLookupResultVMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );

        System.assertEquals(
            true,
            chatterGroupLookupResultVMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ChatterGroupLookupResultVMapper class when one already exists.
     */
    @isTest
    private static void getInstanceExisting() {
        ChatterGroupLookupResultVMapper chatterGroupLookupResultVMapperInstance1 = ChatterGroupLookupResultVMapper.getInstance();

        Test.startTest();
        ChatterGroupLookupResultVMapper chatterGroupLookupResultVMapperInstance2 = ChatterGroupLookupResultVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ChatterGroupLookupResultVMapper.instance,
            chatterGroupLookupResultVMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );

        System.assertEquals(
            chatterGroupLookupResultVMapperInstance1,
            chatterGroupLookupResultVMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );

        System.assertEquals(
            true,
            chatterGroupLookupResultVMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**
     * @description Test method to verify that the locateChatterGroupService method returns instance of UserService
     */
    @isTest
    private static void locateChatterGroupServiceValid() {
        ChatterGroupLookupResultVMapper chatterGroupLookupResultVMapperInstance = ChatterGroupLookupResultVMapper.getInstance();

        Test.startTest();
        ChatterGroupService chatterGroupServiceInstance = chatterGroupLookupResultVMapperInstance.locateChatterGroupService();
        Test.stopTest();

        System.assertEquals(
            ChatterGroupService.getInstance(),
            chatterGroupServiceInstance,
            'Should return the instance of ChatterGroupService'
        );
    }

    /**
     * @description Test method to verify that the getLookupResultFromChatterGroupModel method returns a mapped Lookup Result
     */
    @isTest
    private static void getLookupResultFromChatterGroupModel() {
        Id chatterGroupId = UTIL_UnitTestData_TEST.getFakeId(CollaborationGroup.SObjectType);
        ChatterGroupService.instance = new STUB_ChatterGroupService(chatterGroupId);
        ChatterGroupLookupResultVMapper chatterGroupLookupResultVMapperInstance = ChatterGroupLookupResultVMapper.getInstance();

        ChatterGroupModel chatterGroupModel = new ChatterGroupModel(
            chatterGroupId,
            'Chatter Group Name',
            'Chatter Group Description',
            'https://fake.url/test.png'
        );

        Test.startTest();
        LookupResult lookupResult = chatterGroupLookupResultVMapperInstance.getLookupResultFromChatterGroupModel(
            chatterGroupModel
        );
        Test.stopTest();

        System.assertEquals(
            'Chatter Group Name',
            lookupResult.label,
            'Lookup Result label should be the expected label.'
        );
        System.assertEquals(chatterGroupId, lookupResult.value, 'Lookup Result value should be the expected value.');
        System.assertEquals('standard:groups', lookupResult.icon, 'Lookup Result icon should be the expected icon.');
        System.assertEquals(
            Label.stgOptChatterGroup,
            lookupResult.alternativeText,
            'Lookup Result alternative text should be the expected value.'
        );
        System.assertEquals(
            'https://fake.url/test.png',
            lookupResult.imageUrl,
            'Lookup Result image url should be the expected value.'
        );
        System.assertEquals(
            'Chatter Group Description',
            lookupResult.meta,
            'Lookup Result meta should be the expected value.'
        );
    }

    /**
     * @description Test method to verify that the getLookupResultsLikeChatterGroupName method returns a mapped Lookup Result
     */
    @isTest
    private static void getLookupResultsLikeChatterGroupName() {
        Id chatterGroupId = UTIL_UnitTestData_TEST.getFakeId(CollaborationGroup.SObjectType);
        ChatterGroupService.instance = new STUB_ChatterGroupService(chatterGroupId);
        ChatterGroupLookupResultVMapper chatterGroupLookupResultVMapperInstance = ChatterGroupLookupResultVMapper.getInstance();

        Test.startTest();
        List<LookupResult> lookupResultList = chatterGroupLookupResultVMapperInstance.getLookupResultsLikeChatterGroupName(
            'Chatter',
            1
        );
        Test.stopTest();

        System.assertEquals(1, lookupResultList.size(), 'Only 1 Lookup result should be retrieved.');

        LookupResult lookupResult = lookupResultList[0];

        System.assertEquals(
            'Chatter Group Name',
            lookupResult.label,
            'Lookup Result label should be the expected label.'
        );
        System.assertEquals(chatterGroupId, lookupResult.value, 'Lookup Result value should be the expected value.');
        System.assertEquals('standard:groups', lookupResult.icon, 'Lookup Result icon should be the expected icon.');
        System.assertEquals(
            Label.stgOptChatterGroup,
            lookupResult.alternativeText,
            'Lookup Result alternative text should be the expected value.'
        );
        System.assertEquals(
            'https://fake.url/test.png',
            lookupResult.imageUrl,
            'Lookup Result image url should be the expected value.'
        );
        System.assertEquals(
            'Chatter Group Description',
            lookupResult.meta,
            'Lookup Result meta should be the expected value.'
        );
    }

    /**
     * @description Test method to verify that the truncateDescription method returns a non-truncated description when under 80 characters
     */
    @isTest
    private static void truncateDescriptionLessThan80() {
        ChatterGroupLookupResultVMapper chatterGroupLookupResultVMapperInstance = ChatterGroupLookupResultVMapper.getInstance();

        String description = 'Description';

        Test.startTest();
        String truncatedDescription = chatterGroupLookupResultVMapperInstance.truncateDescription(description);
        Test.StopTest();

        System.assertEquals(
            description,
            truncatedDescription,
            'Descriptions under 80 characters should not be truncated.'
        );
    }

    /**
     * @description Test method to verify that the truncateDescription method returns a non-truncated description when under 80 characters
     */
    @isTest
    private static void truncateDescriptionMoreThan80() {
        ChatterGroupLookupResultVMapper chatterGroupLookupResultVMapperInstance = ChatterGroupLookupResultVMapper.getInstance();

        String description = 'Description'.rightPad(81);
        String expectedTruncatedDescription = 'Description'.rightPad(77) + '...';

        Test.startTest();
        String truncatedDescription = chatterGroupLookupResultVMapperInstance.truncateDescription(description);
        Test.StopTest();

        System.assertEquals(
            expectedTruncatedDescription,
            truncatedDescription,
            'Descriptions over 80 characters should be truncated.'
        );
    }

    /**
     * @description Stub class to simulate the response from ChatterGroupService
     */
    private class STUB_ChatterGroupService extends ChatterGroupService {
        private Id chatterGroupId;

        STUB_ChatterGroupService(Id chatterGroupId) {
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
