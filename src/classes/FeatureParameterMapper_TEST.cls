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
* @description Test class for FeatureParameterMapper class
*/
@isTest
private class FeatureParameterMapper_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * FeatureParameterMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            FeatureParameterMapper featureParamMapperInstance = FeatureParameterMapper.getInstance();
        Test.stopTest();

        System.assertEquals(FeatureParameterMapper.instance, featureParamMapperInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, featureParamMapperInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * FeatureParameterMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            FeatureParameterMapper featureParamMapperInstance1 = FeatureParameterMapper.getInstance();
            FeatureParameterMapper featureParamMapperInstance2 = FeatureParameterMapper.getInstance();
        Test.stopTest();

        System.assertEquals(FeatureParameterMapper.instance, featureParamMapperInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(featureParamMapperInstance1, featureParamMapperInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, featureParamMapperInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify getFeatureParameterType returns a map
    ***************************************************************************************************************************/
    @isTest
    private static void getFeatureParameterType() {

        Test.startTest();
             Map<FeatureParameterMapper.TelemetryParameterName, String> dataTypeByFeature = FeatureParameterMapper.getInstance().getFeatureParameterType();
        Test.stopTest();

        System.assertNotEquals(null, dataTypeByFeature.size(), 'The map with the values should be retrieved.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify  convertToEnum method returns the converted value
    ***************************************************************************************************************************/
    @isTest
    private static void convertToEnumPositiveCheck() {

        Test.startTest();
             FeatureParameterMapper.TelemetryParameterName convertedValue = FeatureParameterMapper.getInstance().convertToEnum('SettingsHealthCheckLastRunDate');
        Test.stopTest();

        System.assertEquals(FeatureParameterMapper.TelemetryParameterName.SettingsHealthCheckLastRunDate, convertedValue, 'The map with the values should be retrieved.');
    }

    /**************************************************************************************************************************
    * @description Negative test for convertToEnum method
    ***************************************************************************************************************************/
    @isTest
    private static void convertToEnumNegativeCheck() {

        Test.startTest();
             FeatureParameterMapper.TelemetryParameterName convertedValue = FeatureParameterMapper.getInstance().convertToEnum('Test');
        Test.stopTest();

        System.assertEquals(null, convertedValue, 'When there is no match null should be returned');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getFeatureParameterModel method returns a FeatureParameterModel
    ***************************************************************************************************************************/
    @isTest
    private static void getFeatureParameterModelStringNotAnEnum() {

        try {
            Test.startTest();
                FeatureParameterModel featureParamModel = FeatureParameterMapper.getInstance().getFeatureParameterModel('testFeatureParam');
                System.assert(false, 'When Passed parameter string is not an enum an error is thrown');
            Test.stopTest();
        } catch (FeatureParameterMapper.FeatureParameterMapperException ex) {
            System.assert(ex.getMessage().contains('An error in Feature Parameter'));
        }

    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getFeatureParameterModel method returns a FeatureParameterModel
    ***************************************************************************************************************************/
    @isTest
    private static void getFeatureParameterModelEnumNotDate() {
        try {
            Test.startTest();
                FeatureParameterModel featureParamModel = FeatureParameterMapper.getInstance().getFeatureParameterModel('HasUserManagedTDTM');
                System.assert(false, 'When Passed parameter string is not an enum an error is thrown');
            Test.stopTest();
        } catch (FeatureParameterMapper.FeatureParameterMapperException ex) {
            System.assert(ex.getMessage().contains('An error in Feature Parameter'));
        }

    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getFeatureParameterModel method returns a FeatureParameterModel
    ***************************************************************************************************************************/
    @isTest
    private static void getFeatureParameterModelSuccess() {
        Date featureParameterDate = Date.valueOf('2015-12-31');
        String featureParameterName = 'SettingsHealthCheckLastRunDate';
        Test.startTest();
            FeatureParameterModel featureParamModel = FeatureParameterMapper.getInstance().getFeatureParameterModel(featureParameterName);
        Test.stopTest();

        System.assertEquals(featureParameterName, featureParamModel.name, 'Feature Parameter name should be same as passed');
        System.assertEquals(featureParameterDate, ((FeatureParameterDateModel)featureParamModel).value, 'Feature Parmater model value should be today');
    }

    /*****************************************************************************************************************************************
    * @description Test method to verify that the getFeatureParameterModel method throws an error when feature parameter is not a part of enum
    ******************************************************************************************************************************************/
    @isTest
    private static void updateFromFeatureParameterModelStringNotAnEnum() {

        FeatureParameterDateModel featureParamDateModel = new FeatureParameterDateModel('testFeature', Date.today());
        try {
            Test.startTest();
                FeatureParameterMapper.getInstance().updateFromFeatureParameterModel(featureParamDateModel);
                System.assert(false, 'When Passed parameter string is not an enum an error is thrown');
            Test.stopTest();
        } catch (FeatureParameterMapper.FeatureParameterMapperException ex) {
            System.assert(ex.getMessage().contains('An error in Feature Parameter'));
        }

    }
    
    /********************************************************************************************************************************************
    * @description Test method to verify that the getFeatureParameterModel method throws an error when data type is not date
    *********************************************************************************************************************************************/
    @isTest
    private static void updateFromFeatureParameterModelStringNotADate() {

        FeatureParameterDateModel featureParamDateModel = new FeatureParameterDateModel('HasUserManagedTDTM', Date.today());
        try {
            Test.startTest();
                FeatureParameterMapper.getInstance().updateFromFeatureParameterModel(featureParamDateModel);
                System.assert(false, 'When Passed parameter string is not an enum an error is thrown');
            Test.stopTest();
        } catch (FeatureParameterMapper.FeatureParameterMapperException ex) {
            System.assert(ex.getMessage().contains('An error in Feature Parameter'));
        }

    }

    /********************************************************************************************************************************************
    * @description Test method to verify that the updateFromFeatureParameterModel method updates the feature parameter date
    *********************************************************************************************************************************************/
     @isTest
     private static void updateFromFeatureParameterModel() {
        Date featureParameterDate = System.Today();
        String featureParameterName = 'SettingsHealthCheckLastRunDate';
        FeatureParameterModel featureParamModel = new FeatureParameterDateModel(featureParameterName, featureParameterDate);

        Test.startTest();
            FeatureParameterMapper.getInstance().updateFromFeatureParameterModel(featureParamModel);
        Test.stopTest();

        FeatureParameterModel featureParamModelRetrieved = FeatureParameterMapper.getInstance().getFeatureParameterModel(featureParameterName);

        FeatureParameterDateModel featureParamDateModel = (FeatureParameterDateModel)featureParamModelRetrieved;

        System.assertEquals(featureParameterName, featureParamDateModel.name,'Feature parameter should be the same as passed');
        System.assertEquals(featureParameterDate, featureParamDateModel.value,'Feature parameter value should be updated');
    }

    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from FeatureParameterMapper to return a new instance of a FeatureParameterDateModel
    **************************************************************************************************************************************/ 
    public class FPMapperUpdateStub extends FeatureParameterMapper {

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