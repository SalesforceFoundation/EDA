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
* @description Test class for LeadConversionAccountNamingService class.
*/
@isTest
private with sharing class LeadConversionAccountNamingService_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * LeadConversionAccountNamingService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            LeadConversionAccountNamingService LeadConversionAccountNamingServiceInstance = 
                LeadConversionAccountNamingService.getInstance();
        Test.stopTest();

        System.assertEquals(
            LeadConversionAccountNamingService.instance, 
            LeadConversionAccountNamingServiceInstance, 
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true, 
            LeadConversionAccountNamingServiceInstance != null, 
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * LeadConversionAccountNamingService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            LeadConversionAccountNamingService LeadConversionAccountNamingServiceInstance1 = 
                LeadConversionAccountNamingService.getInstance();

            LeadConversionAccountNamingService LeadConversionAccountNamingServiceInstance2 = 
                LeadConversionAccountNamingService.getInstance();
        Test.stopTest();

        System.assertEquals(
            LeadConversionAccountNamingService.instance, 
            LeadConversionAccountNamingServiceInstance1, 
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            LeadConversionAccountNamingServiceInstance1, 
            LeadConversionAccountNamingServiceInstance2, 
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true, 
            LeadConversionAccountNamingServiceInstance1 != null, 
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getLeadConversionAccountNamingModel method returns an LeadConversionAccountNamingModel
    * populated with a list of strings matching the semi-colon delimited list specifed in Hierarchy Settings.
    ***************************************************************************************************************************/
    @isTest 
    private static void getLeadConversionAccountNamingModelValid() {
        LeadConversionAccountNamingMapper.instance = new STUB_LeadConversionAccountNamingMapper();

        LeadConversionAccountNamingService LeadConversionAccountNamingServiceInstance = 
                LeadConversionAccountNamingService.getInstance();

        Test.startTest();
        LeadConversionAccountNamingModel LeadConversionAccountNamingModel = 
            LeadConversionAccountNamingServiceInstance.getLeadConversionAccountNamingModel();
        Test.stopTest();

        System.assertEquals(
            'Id1', 
            LeadConversionAccountNamingModel.accountRecordTypeIdsForLeadConversionWhenOrphanedList[0],
            'Should match value set in stubbed model.'
        );

        System.assertEquals(
            'Id2', 
            LeadConversionAccountNamingModel.accountRecordTypeIdsForLeadConversionWhenOrphanedList[1],
            'Should match value set in stubbed model.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the locateLeadConversionAccountNamingMapper method returns an instance of 
    * the LeadConversionAccountNamingMapper class.
    ***************************************************************************************************************************/
    @isTest 
    private static void locateLeadConversionAccountNamingMapperValid() {
        LeadConversionAccountNamingService LeadConversionAccountNamingServiceInstance = 
                LeadConversionAccountNamingService.getInstance();

        Test.startTest();
        LeadConversionAccountNamingMapper LeadConversionAccountNamingMapperInstance = 
            LeadConversionAccountNamingServiceInstance.locateLeadConversionAccountNamingMapper();
        Test.stopTest();

        System.assertEquals(
            LeadConversionAccountNamingMapper.getInstance(), 
            LeadConversionAccountNamingMapperInstance,
            'Should return an instance of LeadConversionAccountNamingMapper.');
    }


    /**************************************************************************************************************************
    ****************************************************** STUB CLASS *********************************************************
    **************************************************************************************************************************/

    /*************************************************************************************************************
    * @description Stub class to simulate the response from LeadConversionAccountNamingMapper to return an 
    * LeadConversionAccountNamingModel for testing.
    *************************************************************************************************************/
    private class STUB_LeadConversionAccountNamingMapper extends LeadConversionAccountNamingMapper {
        public override LeadConversionAccountNamingModel getLeadConversionAccountNamingModel() {
            List<String> recordTypeIdsList = new List<String>{
                'Id1',
                'Id2'
            };

            return new LeadConversionAccountNamingModel(recordTypeIdsList);
        }
    }    
}
