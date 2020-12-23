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
private class  RelationshipLookupMapper_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * RelationshipLookupMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            RelationshipLookupMapper relationshipLookupMapperInstance = RelationshipLookupMapper.getInstance();
        Test.stopTest();

        System.assertEquals(RelationshipLookupMapper.instance, relationshipLookupMapperInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, relationshipLookupMapperInstance != null, 'Instance of mapper class should not be null.');
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

        System.assertEquals(RelationshipLookupMapper.instance, relationshipLookupMapperInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(relationshipLookupMapperInstance1, relationshipLookupMapperInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, relationshipLookupMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /****************************************************************************************************************************
    * @description Test method to verify that the getRelationshipLookupModels method returns a list of relationship lookup models
    *****************************************************************************************************************************/
    @isTest
    private static void getRelationshipLookupModels() {

        insert new Relationship_Lookup__c(Name = 'test' + system.now(), Active__c = true, Female__c = 'wife',
                                          Male__c = 'husband', Neutral__c = 'spouse');

        Test.startTest();
             List<RelationshipLookupModel> relationshipLookupModelsList = RelationshipLookupMapper.getInstance().getRelationshipLookupModels();
        Test.stopTest();

        List<Relationship_Lookup__c> relationshipLookupList = UTIL_CustomSettingsFacade.getReciprocalSettings();

        System.assertEquals(1, relationshipLookupList.size(), 'Only one item should be available in the list');
        System.assertEquals(relationshipLookupList[0].Name, relationshipLookupModelsList[0].name, 'Retrieved model\'s name should be same as Name from settings');
        System.assertEquals(relationshipLookupList[0].Active__c, relationshipLookupModelsList[0].isActive, 'Retrieved model\'s isActive should be same as isActive__c from settings');
        System.assertEquals(relationshipLookupList[0].Female__c, relationshipLookupModelsList[0].femaleValue, 'Retrieved model\'s femaleValue should be same as Female__c from settings');
        System.assertEquals(relationshipLookupList[0].Male__c, relationshipLookupModelsList[0].maleValue, 'Retrieved model\'s maleValue should be same as Male__c from settings');
        System.assertEquals(relationshipLookupList[0].Neutral__c, relationshipLookupModelsList[0].neutralValue, 'Retrieved model\'s neutralValue should be same as Neutral__c from settings');        

    }
}