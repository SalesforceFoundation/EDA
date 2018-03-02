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
* @description Provides an adapter for other packages to be able to inject customizations into HEDA.
**/

global virtual with sharing class Advancement_Adapter {

    /**
     * @description To be called by the HEDA TDTM trigger dispatcher. It returns the HEDA TDTM tokens with the new one from Adv.
     *
     * @return A list of HEDA tokens.
     */
    global virtual List<TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        return TDTM_Global_API.getDefaultTdtmConfig();
    }

    /**
    *  @description This method is used to inject the NPSP rollup logic into HEDA Trigger Handler.
    */
    global virtual void rollupAccount(list<Id> listAccountId) {
        //No logic for HEDA
    }

    /**
     * @description This method is used to inject the NPSP opportunity logic info HEDA Trigger Handler.
     */
    global virtual void moveOppsToContactAccount(map<Id,Id> mapContactIdAccountIdNew, map<Id,Id> mapContactIdAccountIdOld) {
        //No logic for HEDA
    }

    /**
     * @description This method is used to populate NPSP's primary contact field in HEDA Trigger Handler
     */
    global virtual void primaryContact(Account a, Id contactId) {
        //No Logic for HEDA
    }

    /**
     * @description This method is used to populate NPSP's system account field in HEDA Trigger Handler
     */
    global virtual void configAccountForContact(Account a, String defaultRecTypeID) {
        //No Logic for HEDA
    }

}