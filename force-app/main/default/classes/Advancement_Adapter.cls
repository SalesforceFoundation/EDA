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
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description Provides an adapter for other packages to be able to inject customizations into EDA.
**/

global virtual with sharing class Advancement_Adapter {

    /*******************************************************************************************************
    * @description To be called by the EDA TDTM trigger dispatcher.
    * It returns the EDA TDTM tokens with the new one from Adv
    * @return List<TDTM_Global_API.TdtmToken> A list of EDA tokens.
    */
    global virtual List<TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        if(!Advancement_Info.useAdv()) {
            throw new AdapterException(Label.adapterException);
        }

        return TDTM_Global_API.getDefaultTdtmConfig();
    }

    /*******************************************************************************************************
    * @description This method is used to inject the NPSP rollup logic into EDA Trigger Handler.
    * @param listAccountId The list of Account (Id's) that need updating.
    * @return void
    */
    global virtual void rollupAccounts(List<Id> listAccountId) {
        if(!Advancement_Info.useAdv()) {
            throw new AdapterException(Label.adapterException);
        }

        //No logic for EDA
    }

    /*******************************************************************************************************
    * @description This method is used to inject the NPSP opportunity logic info EDA Trigger Handler.
    * @param mapContactIdAccountIdNew  A map of Contact Id to Account Id, for the Accounts to move opps to
    * @param mapContactIdAccountIdOld A map of Contact Id to Account Id, for the Accounts to move opps from
    * @return void
    */
    global virtual void moveOppsToContactAccount(Map<Id,Id> mapContactIdAccountIdNew, Map<Id,Id> mapContactIdAccountIdOld) {
        if(!Advancement_Info.useAdv()) {
            throw new AdapterException(Label.adapterException);
        }

        //No logic for EDA
    }

    /*******************************************************************************************************
    * @description This method is used to populate NPSP's primary contact field in EDA Trigger Handler
    * @param a The Account that need updating.
    * @param contactId The id of the primary contact
    * @return void
    */
    global virtual void primaryContact(Account a, Id contactId) {
        if(!Advancement_Info.useAdv()) {
            throw new AdapterException(Label.adapterException);
        }

        //No Logic for EDA
    }

    /*******************************************************************************************************
    * @description This method is used to populate NPSP's system account field in EDA Trigger Handler
    * @param a The Account that need updating.
    * @return void
    */
    global virtual void configAccountForContact(Account a) {
        if(!Advancement_Info.useAdv()) {
            throw new AdapterException(Label.adapterException);
        }

        //No Logic for EDA
    }

    /*******************************************************************************************************
    * @description This is the expection class for Advancement Adapter class
    */
    global class AdapterException extends Exception{}
}