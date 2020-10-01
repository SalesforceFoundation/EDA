/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group 
* @group-content ../../ApexDocContent/
* @description Test class for MODL_PreferredEmailField
*/
@isTest
private class MODL_PreferredEmailField_TEST {

    /******************************************************************************************************************************************************
    * @description Test method to verify MODL_PreferredEmailField assigns value when Email Type Field Label is in preferredEmailPicklistValuesByLabel Map
    *******************************************************************************************************************************************************/
    @isTest
    private static void MODL_PreferredEmailFieldWithLabel() {
        Test.startTest();
            MODL_PreferredEmailField prefEmailFieldModel = new MODL_PreferredEmailField('University Email',  UTIL_Namespace.StrTokenNSPrefix('') + 'UniversityEmail__c',
                                                                                       MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailPicklistLabelByApiName(), 
                                                                                       MAPR_CON_PreferredEmailFields.getInstance().getLegacyPreferredEmailPicklistValuesByLabel());
        Test.stopTest();

        System.assertEquals('University Email', prefEmailFieldModel.emailTypeFieldLabel);
        System.assertEquals(UTIL_Namespace.StrTokenNSPrefix('') + 'UniversityEmail__c', prefEmailFieldModel.emailTypeFieldApiName);
        System.assertEquals('University Email', prefEmailFieldModel.preferredLabel);
    
    }

    /**********************************************************************************************************************************************************
    * @description Test method to verify MODL_PreferredEmailField assigns value when Email Type Field Label is in preferredEmailPicklistValuesByLabelLegacy Map
    ***********************************************************************************************************************************************************/
    @isTest
    private static void MODL_PreferredEmailFieldWithLegacyLabel() {
        
        Map<String, String> preferredEmailPicklistLabelByApiNameCustom = new Map<String, String>{
                'University' => 'University',
                'Work' => 'Work',
                'Alternate' => 'Alternate'
            };
        Test.startTest();
            MODL_PreferredEmailField prefEmailFieldModel = new MODL_PreferredEmailField('University Email',  UTIL_Namespace.StrTokenNSPrefix('') + 'UniversityEmail__c',
                                                                                       preferredEmailPicklistLabelByApiNameCustom, 
                                                                                       MAPR_CON_PreferredEmailFields.getInstance().getLegacyPreferredEmailPicklistValuesByLabel());
        Test.stopTest();

        System.assertEquals('University Email', prefEmailFieldModel.emailTypeFieldLabel);
        System.assertEquals(UTIL_Namespace.StrTokenNSPrefix('') + 'UniversityEmail__c', prefEmailFieldModel.emailTypeFieldApiName);
        System.assertEquals('University', prefEmailFieldModel.preferredLabel);
    
    }

     /**************************************************************************************************************************
    * @description Test method to verify MODL_PreferredEmailField assigns value when Email Type Field Label is  not in both 
    * preferredEmailPicklistValuesByLabel and preferredEmailPicklistValuesByLabelLegacy Maps
    ***************************************************************************************************************************/
    @isTest
    private static void MODL_PreferredEmailFieldWithLabelWithCustomEmailField() {

        Test.startTest();
            MODL_PreferredEmailField prefEmailFieldModel = new MODL_PreferredEmailField('Test Email Field',  UTIL_Namespace.StrTokenNSPrefix('') + 'TestEmail__c',
                                                                                       MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailPicklistLabelByApiName(), 
                                                                                       MAPR_CON_PreferredEmailFields.getInstance().getLegacyPreferredEmailPicklistValuesByLabel());
        Test.stopTest();

        System.assertEquals('Test Email Field', prefEmailFieldModel.emailTypeFieldLabel);
        System.assertEquals(UTIL_Namespace.StrTokenNSPrefix('') + 'TestEmail__c', prefEmailFieldModel.emailTypeFieldApiName);
        System.assertEquals('Test Email Field', prefEmailFieldModel.preferredLabel);
    
    }
}