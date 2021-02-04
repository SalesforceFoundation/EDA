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
* @group-content ../../ApexDocContent/Tests.htm
* @description Test class for FeatureParameterService class
*/
@isTest
private class FeatureParameterService_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * FeatureParameterService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            FeatureParameterService featureParamServiceInstance = FeatureParameterService.getInstance();
        Test.stopTest();

        System.assertEquals(FeatureParameterService.instance, featureParamServiceInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, featureParamServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * FeatureParameterService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            FeatureParameterService featureParamServiceInstance1 = FeatureParameterService.getInstance();
            FeatureParameterService featureParamServiceInstance2 = FeatureParameterService.getInstance();
        Test.stopTest();

        System.assertEquals(FeatureParameterService.instance, featureParamServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(featureParamServiceInstance1, featureParamServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, featureParamServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /****************************************************************************************************************************
    * @description Test method to verify that the locateFeatureParameterMapper method returns instance of FeatureParameterMapper
    ****************************************************************************************************************************/
    @isTest
    private static void locateFeatureParameterMapper() {

        Test.startTest();
            FeatureParameterMapper featureParamMapper = FeatureParameterService.getInstance().locateFeatureParameterMapper();
        Test.stopTest();

        System.assertEquals(FeatureParameterMapper.getInstance(), featureParamMapper, 'Should return the instance of FeatureParameterMapper');

    }    

    /**************************************************************************************************************************
    * @description Test method to verify that the getFeatureParameterModel method returns FeatureParameterModel
    ***************************************************************************************************************************/
    @isTest
    private static void getFeatureParameterModel() {

        FeatureParameterMapper.instance = new STUB_FeatureParameterDateModel();
        Test.startTest();
            FeatureParameterModel featureParamModel = FeatureParameterService.getInstance().getFeatureParameterModel('Test Feature Param');
        Test.stopTest();

        System.assertNotEquals(null, featureParamModel, 'should return a FeatureParameterModel');
        System.assertEquals('Test Feature Param', featureParamModel.name, 'Feature Parameter Name should be returned');
        System.assertEquals(Date.today(), ((featureParameterDateModel)featureParamModel).value, 'Feature Parameter value should be returned');

    }

    /**************************************************************************************************************************
    * @description Test method to verify updateFromFeatureParameterModel method
    ***************************************************************************************************************************/
    @isTest
    private static void updateFromFeatureParameterModel() {

        FeatureParameterMapper.instance = new STUB_FeatureParameterUpdate();
        FeatureParameterModel featureParamModel = new FeatureParameterDateModel('example', System.Today());

        Test.startTest();
            FeatureParameterService.getInstance().updateFromFeatureParameterModel(featureParamModel);
        Test.stopTest();

        System.assertEquals(FeatureParameterService.getInstance().getFeatureParameterModel('example'), featureParamModel);
    }

    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from FeatureParameterMapper to return a new instance of a FeatureParameterDateModel
    **************************************************************************************************************************************/ 
    private class STUB_FeatureParameterDateModel extends FeatureParameterMapper {
        @TestVisible 
        public override FeatureParameterModel getFeatureParameterModel(String featureParameter){            
            FeatureParameterDateModel featureParamDateMdl = new FeatureParameterDateModel('Test Feature Param', Date.today());
            return featureParamDateMdl;
        }
    }

    /**********************************************************************************************************************************************************
    * @description Stub class to simulate the response from FeatureParameterMapper to return a FeatureParameterDateModel and update from FeatureParameterModel
    **********************************************************************************************************************************************************/ 
     public class STUB_FeatureParameterUpdate extends FeatureParameterMapper {
         
         @testVisible
         private FeatureParameterModel featureParameterModel;
         
         public override void updateFromFeatureParameterModel(FeatureParameterModel featureParamModel) {
             this.featureParameterModel = featureParamModel;
         }
         
         public override FeatureParameterModel getFeatureParameterModel(String featureParameter) {
             return this.featureParameterModel;
         }
     }
}