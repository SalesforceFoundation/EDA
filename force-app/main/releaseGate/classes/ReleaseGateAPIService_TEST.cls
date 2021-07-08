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
 * @description Test class for ReleaseGateAPIService
 */
@isTest
public with sharing class ReleaseGateAPIService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the constructor is assigning the values correctly
     ***************************************************************************************************************************/
    @isTest
    private static void createInstance() {
        Test.startTest();
        ReleaseGateAPIService releaseGateApiServiceInstance = new ReleaseGateAPIService(
            'testnamespace',
            'testclass',
            1
        );
        Test.stopTest();

        System.assertEquals('testnamespace', releaseGateApiServiceInstance.namespace, 'namespace is incorrect');
        System.assertEquals('testclass', releaseGateApiServiceInstance.className, 'className is incorrect');
        System.assertEquals(1, releaseGateApiServiceInstance.version, 'version is incorrect');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateAPIModel method returns a ReleaseGateAPIModel
     * from another managed package
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesManagedPackage() {
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(
            'edainteropdemo',
            'DemoGlobalReleaseGateCallableImpl',
            1
        );

        Test.startTest();
        ReleaseGateAPIModel.GetActionResult getReleaseGatesResult = callableService.getReleaseGates();
        Test.stopTest();

        System.assertEquals(true, getReleaseGatesResult.success, 'Expected successful response');
        System.assertEquals(1, getReleaseGatesResult.result.size(), 'Expected 1 release gate product in the list');
        System.assertEquals(
            'DemoGlobalCallable',
            getReleaseGatesResult.result[0].product.name,
            'Product name should be DemoGlobalCallable'
        );
        System.assertEquals(1, getReleaseGatesResult.result[0].gates.size(), 'Expected 1 release gate in the list');
        System.assertEquals('summer21', getReleaseGatesResult.result[0].gates[0].name, 'Gate name should be summer21');
        System.assertEquals(
            1,
            getReleaseGatesResult.result[0].gates[0].items.size(),
            'Expected 1 release gate item in the list'
        );
        System.assertEquals(
            'FlexibleAdviseeSnapshot',
            getReleaseGatesResult.result[0].gates[0].items[0].name,
            'Gate feature name should be FlexibleAdviseeSnapshot'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateAPIModel method returns a ReleaseGateAPIModel
     * from the current package
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesCurrentPackage() {
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateCallableImpl',
            1
        );

        Test.startTest();
        ReleaseGateAPIModel.GetActionResult getReleaseGatesResult = callableService.getReleaseGates();
        Test.stopTest();

        System.assertEquals(true, getReleaseGatesResult.success, 'Expected successful response');
        System.assertEquals(1, getReleaseGatesResult.result.size(), 'Expected 1 release gate product in the list');
        System.assertEquals(
            'TestCallable',
            getReleaseGatesResult.result[0].product.name,
            'Product name should be DemoGlobalCallable'
        );
        System.assertEquals(1, getReleaseGatesResult.result[0].gates.size(), 'Expected 1 release gate in the list');
        System.assertEquals('summer21', getReleaseGatesResult.result[0].gates[0].name, 'Gate name should be summer21');
        System.assertEquals(
            1,
            getReleaseGatesResult.result[0].gates[0].items.size(),
            'Expected 1 release gate item in the list'
        );
        System.assertEquals(
            'FlexibleAdviseeSnapshot',
            getReleaseGatesResult.result[0].gates[0].items[0].name,
            'Gate feature name should be FlexibleAdviseeSnapshot'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the activateReleaseGateAPIModel method returns a ReleaseGateAPIModel
     * from another managed package
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGatesManagedPackage() {
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(
            'edainteropdemo',
            'DemoGlobalReleaseGateCallableImpl',
            1
        );
        ReleaseGateAPIModel.GetActionResult getReleaseGatesResult = callableService.getReleaseGates();
        String productName = getReleaseGatesResult.result[0].product.name;
        String gateName = getReleaseGatesResult.result[0].gates[0].name;

        Test.startTest();
        ReleaseGateAPIModel.ActivateActionResult activateReleaseGateResult = callableService.activateReleaseGate(
            productName,
            gateName
        );
        Test.stopTest();

        System.assertEquals(true, activateReleaseGateResult.success, 'Expected successful response');
        System.assertEquals(
            1,
            activateReleaseGateResult.result.size(),
            'Expected 1 activated release gate product in the list'
        );
        System.assertEquals(
            productName,
            activateReleaseGateResult.result[0].productName,
            'Expected product name should be ' + productName
        );
        System.assertEquals(
            gateName,
            activateReleaseGateResult.result[0].gateName,
            'Expected gate name should be ' + gateName
        );
        System.assertEquals('active', activateReleaseGateResult.result[0].status, 'Expected status should be active');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the activateReleaseGate method returns a ReleaseGateAPIModel
     * from the current package
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGatesCurrentPackage() {
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateCallableImpl',
            1
        );
        ReleaseGateAPIModel.GetActionResult getReleaseGatesResult = callableService.getReleaseGates();
        String productName = getReleaseGatesResult.result[0].product.name;
        String gateName = getReleaseGatesResult.result[0].gates[0].name;

        Test.startTest();
        ReleaseGateAPIModel.ActivateActionResult activateReleaseGateResult = callableService.activateReleaseGate(
            productName,
            gateName
        );
        Test.stopTest();

        System.assertEquals(true, activateReleaseGateResult.success, 'Expected successful response');
        System.assertEquals(
            1,
            activateReleaseGateResult.result.size(),
            'Expected 1 activated release gate product in the list'
        );
        System.assertEquals(
            productName,
            activateReleaseGateResult.result[0].productName,
            'Expected product name should be ' + productName
        );
        System.assertEquals(
            gateName,
            activateReleaseGateResult.result[0].gateName,
            'Expected gate name should be ' + gateName
        );
        System.assertEquals('active', activateReleaseGateResult.result[0].status, 'Expected status should be active');
    }

    /***********************************************************************************************************************************
     ************************************************* Test Callable class *************************************************************
     ***********************************************************************************************************************************/

    public class TestReleaseGateCallableImpl implements Callable {
        public TestReleaseGateCallableImpl() {
        }

        public String getReleaseGates(Decimal version) {
            System.debug('Retrieving release gates');
            System.debug('API version: ' + version);
            return '{' +
                '\r\n' +
                '"success":true,' +
                '\r\n' +
                '"result":[' +
                '\r\n' +
                '  {' +
                '\r\n' +
                '    "product":{' +
                '\r\n' +
                '      "name":"TestCallable",' +
                '\r\n' +
                '      "label":"Test Callable Product",' +
                '\r\n' +
                '      "nextReleaseDate":"2022-02-01"' +
                '\r\n' +
                '    },' +
                '\r\n' +
                '    "gates":[' +
                '\r\n' +
                '      {' +
                '\r\n' +
                '        "name":"summer21",' +
                '\r\n' +
                '        "label":"Summer\'21",' +
                '\r\n' +
                '        "description":"Here\'s what\'s new in Summer\'21 ...",' +
                '\r\n' +
                '        "releaseDate":"2021-07-01",' +
                '\r\n' +
                '        "dueDate":"2021-11-04",' +
                '\r\n' +
                '        "activationDate":"2021-11-03T00:00:00.000Z",' +
                '\r\n' +
                '        "items":[' +
                '\r\n' +
                '          {' +
                '\r\n' +
                '            "name":"FlexibleAdviseeSnapshot",' +
                '\r\n' +
                '            "label":"Flexible Advisee Snapshot",' +
                '\r\n' +
                '            "description":"We\'ve redesigned the Advisee snapshot ...",' +
                '\r\n' +
                '            "helpLink":"https://powerofus.force.com/s/article/SAL-Advisor-App-Snapshot-Contact",' +
                '\r\n' +
                '            "helpLinkLabel":"Set up the Advisee Snapshot and Contact Details"' +
                '\r\n' +
                '          }' +
                '\r\n' +
                '        ],' +
                '\r\n' +
                '        "status":"active"' +
                '\r\n' +
                '      }' +
                '\r\n' +
                '    ]' +
                '\r\n' +
                '  }' +
                '\r\n' +
                ']' +
                '\r\n' +
                '}';
        }

        public String activateReleaseGate(Decimal version, String productName, String gateName) {
            System.debug('Activating release gate');
            System.debug('API version: ' + version);
            System.debug('Product name: ' + productName);
            System.debug('Gate name: ' + gateName);
            return '{' +
                '\r\n' +
                '"success":true,' +
                '\r\n' +
                '"result":[' +
                '\r\n' +
                '  {' +
                '\r\n' +
                '    "productName":"TestCallable",' +
                '\r\n' +
                '    "gateName":"summer21",' +
                '\r\n' +
                '    "status":"active"' +
                '\r\n' +
                '  }' +
                '\r\n' +
                ']' +
                '\r\n' +
                '}';
        }

        public Object call(String action, Map<String, Object> args) {
            System.debug('Execution callable action: ' + action);
            String result;
            if (action == ReleaseGateAPIService.GET_ACTION) {
                result = this.getReleaseGates((Decimal) args.get('version'));
            } else if (action == ReleaseGateAPIService.ACTIVATE_ACTION) {
                result = this.activateReleaseGate(
                    (Decimal) args.get('version'),
                    (String) args.get('product'),
                    (String) args.get('gate')
                );
            } else {
                throw new IllegalArgumentException('Method not implemented');
            }
            System.debug('Action finished, result: \r\n' + result);
            return result;
        }
    }
}
