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
 * @description Test class for ADDR_Account_TDTM.
 */
@isTest
private with sharing class ADDR_Account_TEST {
    //This test class stays as placeholder for future refactoring as we are not making changes to the ADDR_Account_TDTM at this moment.

    /**************************************************************************************************************************
     ****************************************************** turnOff ***********************************************************
     **************************************************************************************************************************/

    @isTest
    static void testTurnOffRecursionFlag() {
        TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.ADDR_Account_TDTM_After_Insert);
        TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.ADDR_Account_TDTM_After_Update);

        Test.startTest();
        ADDR_Account_TDTM.turnOff();
        Test.stopTest();

        System.assertEquals(
            true,
            TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ADDR_Account_TDTM_After_Insert)
        );
        System.assertEquals(
            true,
            TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ADDR_Account_TDTM_After_Update)
        );
    }

    /**************************************************************************************************************************
     ****************************************************** turnOn ***********************************************************
     **************************************************************************************************************************/
    @isTest
    static void testTurnOnRecursionFlag() {
        TDTM_ProcessControl.turnOffRecursionFlag(TDTM_ProcessControl.registeredTrigger.ADDR_Account_TDTM_After_Insert);
        TDTM_ProcessControl.turnOffRecursionFlag(TDTM_ProcessControl.registeredTrigger.ADDR_Account_TDTM_After_Update);

        Test.startTest();
        ADDR_Account_TDTM.turnOn();
        Test.stopTest();

        System.assertEquals(
            false,
            TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ADDR_Account_TDTM_After_Insert)
        );
        System.assertEquals(
            false,
            TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ADDR_Account_TDTM_After_Update)
        );
    }

    /**************************************************************************************************************************
     ****************************************************** Run ***************************************************************
     **************************************************************************************************************************/
    /* To Refactor:
     * 1. This method is handling too many things. Ideally we should mock other building dml wrappers methods.
     */
    @isTest
    static void testRunDMLWrapperSingleObjectType() {
    }

    @isTest
    static void testRunDMLWrapperMixedTypes() {
    }

    @isTest
    static void testRunDMLWrapperEmpty() {
    }

    /**************************************************************************************************************************
     ****************************************************** processAccsWithNewInfo ********************************************
     **************************************************************************************************************************/
    /* To Refactor:
     * 1. Break the methods chaining, which makes it almost impossible to test.
     */
    @isTest
    static void testProcessAccsWithNewInfo() {
    }

    @isTest
    static void testProcessAccsWithNewInfoEmptyListAcc() {
    }

    /**************************************************************************************************************************
     ****************************************************** updateChildContacts ***********************************************
     **************************************************************************************************************************/
    @isTest
    static void testUpdateChildContacts() {
    }

    /**************************************************************************************************************************
     ****************************************************** addrInfoDeleted ***********************************************
     **************************************************************************************************************************/
    @isTest
    static void testAddrInfoDeleted() {
    }
}
