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
* @group
* @group-content
* @description Provides the Advancement Information to HEDA class.
**/

public class Advancement_Info {
    public Boolean useAdv = false;
    public Advancement_Adapter API_HEDA = null;

    public Advancement_Info() {
        //Check if Advancement is installed and enabled.
        try {
            List<SObject> advSettings = Database.query('select Use_Advancement__c, API_HEDA_Class__c from Advancement_Setting__mdt');
            useAdv = (Boolean)advSettings[0].get('Use_Advancement__c');
            String apiHedaClass = (String)advSettings[0].get('API_HEDA_Class__c');

            if(String.isNotBlank(apiHedaClass)) {
                Type classType = Type.forName(apiHedaClass);
                if (classType != null) {
                    Object classInstance = classType.newInstance();
                    if (classInstance instanceof Advancement_Adapter) {
                        API_HEDA = (Advancement_Adapter) classInstance;
                    }
                }
            }
        } catch(Exception e) {
            // Advancement not installed. Nothing to do. If the custom setting Adv_Settings doesn't exist, we'll use
            // HEDA's TDTM config.
        }
    }
}