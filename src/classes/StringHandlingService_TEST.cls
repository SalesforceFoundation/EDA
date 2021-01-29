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
* @description Test class for StringHandlingService class.
*/
@isTest 
public with sharing class StringHandlingService_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * StringHandlingService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            StringHandlingService stringHandlingServiceInstance = StringHandlingService.getInstance();
        Test.stopTest();

        System.assertEquals(StringHandlingService.instance, stringHandlingServiceInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, stringHandlingServiceInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * StringHandlingService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            StringHandlingService stringHandlingServiceInstance1 = StringHandlingService.getInstance();
            StringHandlingService stringHandlingServiceInstance2 = StringHandlingService.getInstance();
        Test.stopTest();

        System.assertEquals(StringHandlingService.instance, stringHandlingServiceInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(stringHandlingServiceInstance1, stringHandlingServiceInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, stringHandlingServiceInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**********************************************************************************************************
    * @description Test method to verify that formatStringWithApostrophesAndParameters() returns a string with 
    * single Apostrophes escaped and parameters substituted when a string with parameters and single Apostrophes is passed as a parameter.
    **********************************************************************************************************/ 
    @isTest 
    private static void formatStringWithApostrophesAndParametersWithApostrophesAndParams() {
        String testString = 'Checkin\' to make sure test string with parameters {0} and {1} isn\'t returnin\' an invalid result.';
        StringHandlingService stringHandlingServiceInstance = StringHandlingService.getInstance(); 

        Test.startTest();
        String formattedStringResult = 
            stringHandlingServiceInstance.formatStringWithApostrophesAndParameters(
                testString, 
                new List<Object>{'1', '2'}
            );
        Test.stopTest();

        String expectedString = 'Checkin\' to make sure test string with parameters 1 and 2 isn\'t returnin\' an invalid result.';
        System.assertEquals(
            expectedString, 
            formattedStringResult, 
            'Formatted string should substitute parameters and escape single Apostrophes.'
        );
    }

    /**********************************************************************************************************
    * @description Test method to verify that formatStringWithApostrophesAndParameters() returns a string with 
    * single Apostrophes escaped when a string single Apostrophes but no parameters is passed as a parameter.
    **********************************************************************************************************/ 
    @isTest 
    private static void formatStringWithApostrophesAndParametersWithApostrophesNoParams() {
        String testString = 'Checkin\' to make sure test string without parameters isn\'t returnin\' an invalid result.';
        StringHandlingService stringHandlingServiceInstance = StringHandlingService.getInstance(); 

        Test.startTest();
        String formattedStringResult = 
            stringHandlingServiceInstance.formatStringWithApostrophesAndParameters(
                testString, 
                new List<Object>()
            );
        Test.stopTest();

        String expectedString = 'Checkin\' to make sure test string without parameters isn\'t returnin\' an invalid result.';
        System.assertEquals(
            expectedString, 
            formattedStringResult, 
            'Formatted string should escape single Apostrophes.'
        );
    }

    /**********************************************************************************************************
    * @description Test method to verify that formatStringWithApostrophesAndParameters() returns a string with 
    * parameters substituted when a string with parameters, but no single Apostrophes is passed as a parameter.
    **********************************************************************************************************/ 
    @isTest 
    private static void formatStringWithApostrophesAndParametersNoApostrophesWithParams() {
        String testString = 'Checking to make sure test string with parameters {0} and {1} returns a valid result.';
        StringHandlingService stringHandlingServiceInstance = StringHandlingService.getInstance(); 

        Test.startTest();
        String formattedStringResult = 
            stringHandlingServiceInstance.formatStringWithApostrophesAndParameters(
                testString, 
                new List<Object>{'1', '2'}
            );
        Test.stopTest();

        String expectedString = 'Checking to make sure test string with parameters 1 and 2 returns a valid result.';
        System.assertEquals(
            expectedString, 
            formattedStringResult, 
            'Formatted string should substitue parameter values.'
        );
    }

    /**********************************************************************************************************
    * @description Test method to verify that formatStringWithApostrophesAndParameters() returns the original 
    * string with no modifications when a string with no parameters or single Apostrophes is passed as a parameter.
    **********************************************************************************************************/ 
    @isTest 
    private static void formatStringWithApostrophesAndParametersNoApostrophesNoParams() {
        String testString = 'Checking to make sure a plain test string returns a valid result.';
        StringHandlingService stringHandlingServiceInstance = StringHandlingService.getInstance(); 

        Test.startTest();
        String formattedStringResult = 
            stringHandlingServiceInstance.formatStringWithApostrophesAndParameters(
                testString, 
                new List<Object>()
            );
        Test.stopTest();

        String expectedString = 'Checking to make sure a plain test string returns a valid result.';
        System.assertEquals(
            expectedString, 
            formattedStringResult, 
            'Formatted string should return original string.'
        );
    }
}
