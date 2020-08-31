/*
    Copyright (c) 2017, Salesforce.org
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
* @date 2017
* @group Error Handling
* @description Tests exception handler
*/
@isTest
private with sharing class ERR_ExceptionHandler_TEST {

    /*********************************************************************************************************
    * @description Catches a required field exception, verifies it's an exception we can handle, applies 
    * exception handler method to beautify the error message, and verifies the results. Applies the method 
    * again, verifies the results are unchanged.
    */
    @isTest
    static void testHandleException() {
		Exception ex;
		try {
			insert new Opportunity();
		} catch (Exception oppException) {
			ex = oppException;
		}
		system.assertNotEquals(null, ex, 'An exception should be caught.');
		system.assert(ERR_ExceptionHandler.isHandledException(ex), 'The exception caught should be able to be beautified.');
		
		ERR_ExceptionHandler.beautifyExceptionMessage(ex);

		system.assert(ERR_ExceptionHandler.isHandledException(ex), 'After updating the message, we still detect it as handled.');
		system.assert(ex.getMessage().contains(Label.exceptionRequiredField), 'The correct message is added.');

		String oldMessage = ex.getMessage();
		ERR_ExceptionHandler.beautifyExceptionMessage(ex);

		system.assertEquals(oldMessage, ex.getMessage(), 'Applying the method twice shouldn\'t change the results.');

	}

    /*********************************************************************************************************
    * @description Catches an invalid ID error, which we don't handle. Verifies it's not a handled exception,
    * and that applying the beautify method does nothing.
    */
    @isTest
    static void testUnhandledExceptionIsUnmodified() {
		Exception ex;
		try {
			Id foo = 'foo';
		} catch (Exception typeException) {
			ex = typeException;
		}
		
		system.assertNotEquals(null, ex, 'An exception should be caught.');
		system.assert(!ERR_ExceptionHandler.isHandledException(ex), 'The exception caught shouldn\'t be a handled exception.');
		
		String oldMessage = ex.getMessage();

		ERR_ExceptionHandler.beautifyExceptionMessage(ex);

		system.assertEquals(oldMessage, ex.getMessage(), 'Unhandled exception type should be unmodified.');
	}

    // This method tests handleAfflNullRecordTypeException() of ERR_ExceptionHandler class by passing Affiliaiton Record and List of Account Record Type API Names
    @isTest
    private static void testHandleAfflNullRecordTypeExceptionWithAPIPositive() {
        AFFL_MultiRecordTypeMapper afflMultiRecordTypeMapper = new AFFL_MultiRecordTypeMapper();

        // Insert an Account
        Account[] testAccount = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID());
        insert testAccount;

        // Insert a Contact
        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        insert testContact;

        Affiliation__c affl = new Affiliation__c(Contact__c = testContact.ID, Account__c = testAccount[0].ID);
        insert affl;

        Affiliation__c afflAfterInsert = [Select Id, Affiliation_Type__c, Account__c FROM Affiliation__c];
        System.assertEquals('Business Organization', afflAfterInsert.Affiliation_Type__c);

        // Construct a list of Account Record Type Names
        List<String> accRecTypeAPIs = new List<String>();
           accRecTypeAPIs.add('Academic_Program');
           accRecTypeAPIs.add('Educational_Institution');
           accRecTypeAPIs.add('Business_Organization');
           accRecTypeAPIs.add('HH_Account');
           accRecTypeAPIs.add('University_Department');
           accRecTypeAPIs.add('Sports_Organization');

        // Test calling the method doesn't throw any error
        Test.startTest();
            ERR_ExceptionHandler.handleAfflNullRecordTypeException(afflAfterInsert, accRecTypeAPIs, afflMultiRecordTypeMapper.accRecTypeLabelToAPI);
        Test.stopTest();
    }

    // This method tests handleAfflNullRecordTypeException() of ERR_ExceptionHandler class by passing Affiliaiton Record and List of Account Record Type Labels
    @isTest
    private static void testHandleAfflNullRecordTypeExceptionWithLabelsPositive() {
        AFFL_MultiRecordTypeMapper afflMultiRecordTypeMapper = new AFFL_MultiRecordTypeMapper();

        Account[] testAccount = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID());
        insert testAccount;

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        insert testContact;

        Affiliation__c affl = new Affiliation__c(Contact__c = testContact.ID, Account__c = testAccount[0].ID);
        insert affl;

        Affiliation__c afflAfterInsert = [Select Id, Affiliation_Type__c, Account__c FROM Affiliation__c];
        System.assertEquals('Business Organization', afflAfterInsert.Affiliation_Type__c);

        // Construct a list of Account Record Type Names
        List<String> accRecTypeLabels = new List<String>();
           accRecTypeLabels.add('Academic Program');
           accRecTypeLabels.add('Educational Institution');
           accRecTypeLabels.add('Business Organization');
           accRecTypeLabels.add('Household Account');
           accRecTypeLabels.add('University Department');
           accRecTypeLabels.add('Sports Organization');

        // Test calling the method doesn't throw any error
        Test.startTest();
            ERR_ExceptionHandler.handleAfflNullRecordTypeException(afflAfterInsert, accRecTypeLabels, afflMultiRecordTypeMapper.accRecTypeLabelToAPI);
        Test.stopTest();
    }

    // This method tests handleAfflNullRecordTypeException() of ERR_ExceptionHandler class by passing Affiliaiton Record and List of Account Record Type Names
    @isTest
    private static void testHandleAfflNullRecordTypeExceptionWithLabelsNegative() {
        AFFL_MultiRecordTypeMapper afflMultiRecordTypeMapper = new AFFL_MultiRecordTypeMapper();

        Account[] testAccount = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID());
        insert testAccount;

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        insert testContact;

        Affiliation__c affl = new Affiliation__c(Contact__c = testContact.ID, Account__c = testAccount[0].ID);
        insert affl;

        Affiliation__c afflAfterInsert = [Select Id, Affiliation_Type__c, Account__c FROM Affiliation__c];
        System.assertEquals('Business Organization', afflAfterInsert.Affiliation_Type__c);

        // Construct a list of Account Record Type Names
        List<String> accRecTypeLabels = new List<String>();
           accRecTypeLabels.add('Academic Program');
           accRecTypeLabels.add('Educational Institution');
           accRecTypeLabels.add('Household Account');
           accRecTypeLabels.add('University Department');
           accRecTypeLabels.add('Sports Organization');

        // Test Error is thrown because Business Organization is not part of accRecTypeLabels
        try {
            Test.startTest();
                ERR_ExceptionHandler.handleAfflNullRecordTypeException(afflAfterInsert, accRecTypeLabels, afflMultiRecordTypeMapper.accRecTypeLabelToAPI);
            Test.stopTest();
            System.assert(false, 'Always throw an exception when affiliation type is not a part of Mappings');
        } catch (ERR_ExceptionHandler.AffAccountRecordTypeMappingsException error) {
            System.assert(error.getMessage().contains(Label.afflAccoutMappingError));
        }
    }
}