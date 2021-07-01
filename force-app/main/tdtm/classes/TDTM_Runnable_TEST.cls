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
 * @date 2021
 * @group TDTM
 * @group-content ../../ApexDocContent/TDTM.htm
 * @description Test Class for the TDTM_Runnable_TEST class
 */
@isTest
private class TDTM_Runnable_TEST {
    /**
     * @description Runs test for getTDTMRunnableFromClassName when the class exists and is a TDTM_Runnable
     */
    @isTest
    public static void getTDTMRunnableFromClassNameValidClass() {
        String className = 'CON_CannotDelete_TDTM';
        Test.startTest();
        TDTM_Runnable runnable = TDTM_Runnable.getTDTMRunnableFromClassName(className);
        Test.stopTest();

        System.assertNotEquals(null, runnable, 'TDTM_Runnable classes should be appropriately instantiated.');
    }

    /**
     * @description Test for getTDTMRunnableFromClassName when the class exists and is not a TDTM_Runnable
     */
    @isTest
    public static void getTDTMRunnableFromClassNameNotTDTMRunnable() {
        String className = 'TDTM_Manager';
        Test.startTest();
        TDTM_Runnable runnable = TDTM_Runnable.getTDTMRunnableFromClassName(className);
        Test.stopTest();

        System.assertEquals(null, runnable, 'Classes that are not TDTM_Runnable should be null.');
    }

    /**
     * @description Test for getTDTMRunnableFromClassName when the class does not exist
     */
    @isTest
    public static void getTDTMRunnableFromClassNameInvalidClass() {
        String className = 'ClassThatDoesNotExist';
        Test.startTest();
        TDTM_Runnable runnable = TDTM_Runnable.getTDTMRunnableFromClassName(className);
        Test.stopTest();

        System.assertEquals(null, runnable, 'Classes that do not exist should return null.');
    }

    /**
     * @description Test for getTDTMRunnableFromClassName when the class exists and is not a TDTM_Runnable
     */
    @isTest
    public static void getAllFieldsForSObjectsFromIdList() {
        //TODO
    }
}
