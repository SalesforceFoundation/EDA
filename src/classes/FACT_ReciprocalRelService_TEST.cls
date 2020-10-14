/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group 
* @group-content ../../ApexDocContent/Relationships.htm
* @description Test class for FACT_ReciprocalRelationshipService.
*/
@isTest
private class FACT_ReciprocalRelService_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * SRVC_ReciprocalRelationshipInversion class when one does not already exist and reciprocal method is inversion.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceInversionTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Reciprocal_Method__c = 'Value Inversion'));

        Test.startTest();
            SRVC_ReciprocalRelationship srvcReciprocalRelationshipInversionInstance = FACT_ReciprocalRelationshipService.getInstance();
        Test.stopTest();

        System.assertEquals(true, srvcReciprocalRelationshipInversionInstance instanceof SRVC_ReciprocalRelationshipInversion, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, srvcReciprocalRelationshipInversionInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * SRVC_ReciprocalRelationshipInversion class when one does not already exist and reciprocal method is list.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceListTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));

        Test.startTest();
            SRVC_ReciprocalRelationship srvcReciprocalRelationshipListInstance = FACT_ReciprocalRelationshipService.getInstance();
        Test.stopTest();

        System.assertEquals(true, srvcReciprocalRelationshipListInstance instanceof SRVC_ReciprocalRelationshipList, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, srvcReciprocalRelationshipListInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * SRVC_ReciprocalRelationshipInversion class when one does not already exist and reciprocal method is empty.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceEmptyTest() {
        Test.startTest();
            SRVC_ReciprocalRelationship srvcReciprocalRelationshipInstance = FACT_ReciprocalRelationshipService.getInstance();
        Test.stopTest();

        System.assertEquals(true, srvcReciprocalRelationshipInstance instanceof SRVC_ReciprocalRelationship, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, srvcReciprocalRelationshipInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * SRVC_ReciprocalRelationshipInversion class when reciprocal method is empty and one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceEmptyExistingTest() {
        Test.startTest();
            SRVC_ReciprocalRelationship srvcReciprocalRelationshipInstance1 = FACT_ReciprocalRelationshipService.getInstance();
            SRVC_ReciprocalRelationship srvcReciprocalRelationshipInstance2 = FACT_ReciprocalRelationshipService.getInstance();
        Test.stopTest();

        System.assertEquals(true, srvcReciprocalRelationshipInstance1 instanceof SRVC_ReciprocalRelationship, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(srvcReciprocalRelationshipInstance1, srvcReciprocalRelationshipInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, srvcReciprocalRelationshipInstance1 != null, 'Instance of service class should not be null.');
    }

    /*****************************************************************************
    * @description Test for getting the reciprocal method from custom setting if reciprocal method is inversion
    ******************************************************************************/
    @isTest
    private static void getReciprocalMethodFromSettingsInversionTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Reciprocal_Method__c = 'Value Inversion'));

        Test.startTest();
            String reciprocalMethod = FACT_ReciprocalRelationshipService.getReciprocalMethodFromSettings();
        Test.stopTest();

        System.assertEquals('Value Inversion', reciprocalMethod);
    }

    /*****************************************************************************
    * @description Test for getting the reciprocal method from custom setting if reciprocal method is empty
    ******************************************************************************/
    @isTest
    private static void getReciprocalMethodFromSettingsEmptyTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Reciprocal_Method__c = ''));

        Test.startTest();
            String reciprocalMethod = FACT_ReciprocalRelationshipService.getReciprocalMethodFromSettings();
        Test.stopTest();

        System.assertEquals('', reciprocalMethod);
    }
}