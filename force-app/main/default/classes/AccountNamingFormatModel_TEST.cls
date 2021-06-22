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
* @group EDA Settings
* @group-content ../../ApexDocContent/Test.htm
* @description Test class for AccountNamingFormatModel.
*/
@isTest
private class AccountNamingFormatModel_TEST {

    @isTest
    private static void AccountNamingFormatModelSingleParamConstructor() {
        Map<String, String> formatsByName = new Map<String, String>{
            'format1' => '{firstName} Format',
            'format2' => '{lastName} Format'
        };


        Test.startTest();
        AccountNamingFormatModel AccountNamingFormatModel = 
            new AccountNamingFormatModel(formatsByName);
        Test.stopTest();

        System.assertEquals(
            2, 
            AccountNamingFormatModel.validAccountNamingFormatsByName.values().size(), 
            'Model should have 2 account naming formats specified.'
        );

        System.assertEquals(
            '{firstName} Format', 
            AccountNamingFormatModel.validAccountNamingFormatsByName.get('format1'), 
            'Format mapped to \'format1\' should equal \'{firstName} Format\''
        );

        System.assertEquals(
            '{lastName} Format', 
            AccountNamingFormatModel.validAccountNamingFormatsByName.get('format2'), 
            'Format mapped to \'format2\' should equal \'{lastName} Format\''
        );
    }
}
