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
* @group ErrorHandling
* @description Tests exception handler
*/
@isTest
private with sharing class ERR_ExceptionHandler_TEST {

    /*********************************************************************************************************
    * @description Catches a required field exception, verifies it's an exception we can handle, applies 
    * exception handler method to beautify the error message, and verifies the results. Applies the method 
    * again, verifies the results are unchanged.
    */
	static testMethod void testHandleException() {
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
	static testMethod void testUnhandledExceptionIsUnmodified() {
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
}