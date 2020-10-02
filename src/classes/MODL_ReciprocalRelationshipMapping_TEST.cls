/*
    Copyright (c) 2009, 2012, Salesforce.org
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
* @date 2011,2012
* @group Relationships
* @group-content ../../ApexDocContent/Relationships.htm
* @description Test class for MODL_ReciprocalRelationshipMapping.
*/
@isTest
private class MODL_ReciprocalRelationshipMapping_TEST {
    /*********************************************************************** 
    * @descriptionTests MODL_ReciprocalRelationshipMapping constructor with all the parameters 
    ************************************************************************/
    @isTest
    static void constructorWithAllParametersTest() {
        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'test relationship name',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        Test.startTest();
            MODL_ReciprocalRelationshipMapping modelReciprocalRelationshipMapping = new MODL_ReciprocalRelationshipMapping(relationshipLookup);
        Test.stopTest();

        System.assertEquals('test relationship name', modelReciprocalRelationshipMapping.getRelationshipName());
        System.assertEquals(true, modelReciprocalRelationshipMapping.getIsActive());
        System.assertEquals('Mother', modelReciprocalRelationshipMapping.getFemaleRelationshipType());
        System.assertEquals('Father', modelReciprocalRelationshipMapping.getMaleRelationshipType());
        System.assertEquals('Parent', modelReciprocalRelationshipMapping.getNeutralRelationshipType());
    }

    /*********************************************************************** 
    * @descriptionTests Test for hasFemaleValue if true
    ************************************************************************/
    @isTest
    static void hasFemaleValueTrueTest() {
        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'test relationship name',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        Test.startTest();
            MODL_ReciprocalRelationshipMapping modelReciprocalRelationshipMapping = new MODL_ReciprocalRelationshipMapping(relationshipLookup);
            Boolean hasFemaleValue = modelReciprocalRelationshipMapping.hasFemaleValue();
        Test.stopTest();

        System.assertEquals(true, hasFemaleValue);
    }

    /*********************************************************************** 
    * @descriptionTests Test for hasFemaleValue if false
    ************************************************************************/
    @isTest
    static void hasFemaleValueFalseTest() {
        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'test relationship name',
                                                                            Active__c = true,
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        Test.startTest();
            MODL_ReciprocalRelationshipMapping modelReciprocalRelationshipMapping = new MODL_ReciprocalRelationshipMapping(relationshipLookup);
            Boolean hasFemaleValue = modelReciprocalRelationshipMapping.hasFemaleValue();
        Test.stopTest();

        System.assertEquals(false, hasFemaleValue);
    }
}