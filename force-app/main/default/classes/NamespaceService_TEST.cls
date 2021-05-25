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
 * @description Test class for namespaceService class
 */
@isTest
private class NamespaceService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * NameSpaceService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        NameSpaceService nameSpaceServiceInstance = NameSpaceService.getInstance();
        Test.stopTest();

        System.assertEquals(
            NameSpaceService.instance,
            nameSpaceServiceInstance,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(true, nameSpaceServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * NameSpaceService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        NameSpaceService nameSpaceServiceInstance1 = NameSpaceService.getInstance();
        NameSpaceService nameSpaceServiceInstance2 = NameSpaceService.getInstance();
        Test.stopTest();

        System.assertEquals(
            NameSpaceService.instance,
            nameSpaceServiceInstance1,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(
            nameSpaceServiceInstance1,
            nameSpaceServiceInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );
        System.assertEquals(true, nameSpaceServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getNamespacePrefix method returns the nameSpace from class name
     ***********************************************************************************************************************************/
    @isTest
    private static void getNamespacePrefixString() {
        NameSpaceService nameSpaceServiceInstance = NameSpaceService.getInstance();
        Test.startTest();
        String namespacePrefix = nameSpaceServiceInstance.getNamespacePrefix('Test');
        Test.stopTest();

        System.assertEquals('Test__', namespacePrefix, 'Should return the namespace');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getNamespacePrefix method returns the nameSpace from class name
     ***********************************************************************************************************************************/
    @isTest
    private static void getNamespacePrefixNull() {
        NameSpaceService nameSpaceServiceInstance = NameSpaceService.getInstance();
        Test.startTest();
        String namespacePrefix = nameSpaceServiceInstance.getNamespacePrefix(null);
        Test.stopTest();

        System.assertEquals('c__', namespacePrefix, 'Should return the default namespace');
    }
}
