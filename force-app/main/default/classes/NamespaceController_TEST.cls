/*
    Copyright (c) 2011, Salesforce.org
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
 * @date 2011 (1.x)
 * @group Utilities
 * @group-content ../../ApexDocContent/Utilities.htm
 * @description Test class for namespaceController class
 */
@isTest
private with sharing class NamespaceController_TEST {
    /************************************************************************************************************************
     * @description Test method to verify that the locateNameSpaceService method returns instance of NameSpaceService
     ************************************************************************************************************************/
    @isTest
    private static void locateNameSpaceService() {
        Test.startTest();
        NameSpaceService nameSpaceServiceInstance = NamespaceController.locateNameSpaceService();
        Test.stopTest();

        System.assertEquals(
            NameSpaceService.getInstance(),
            nameSpaceServiceInstance,
            'Should return the instance of NameSpaceService'
        );
    }

    /************************************************************************************************************************
     * @description Test method to verify that the getNamespaceName method returns a nameSpace
     ************************************************************************************************************************/

    @isTest
    static void getNamespaceName() {
        NamespaceService.Instance = new STUB_NamespaceService();
        Test.startTest();
        String nameSpace = NamespaceController.getNamespaceName();
        Test.stopTest();

        System.assertEquals('testNameSpace', nameSpace, 'Namespace should be returned');
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from NamespaceService to throw an exception
     **************************************************************************************************************************************/
    private class STUB_NamespaceService extends NamespaceService {
        public override String getNamespacePrefix(String classNameSpace) {
            return 'testNameSpace';
        }
    }
}
