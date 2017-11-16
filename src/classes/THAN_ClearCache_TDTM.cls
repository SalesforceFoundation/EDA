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
* @description Clear cached TDTM Tokens after Insert/Update Trigger Handler.
*/
public class THAN_ClearCache_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Clear cached TDTM Tokens after Insert/Update Trigger Handler.
    * @param listNew the list of Accounts from trigger new.
    * @param listOld the list of Accounts from trigger old.
    * @param triggerAction which trigger event (AfterInsert, AfterUpdate, etc.).
    * @param objResult the describe for Trigger Handler.
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
            TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        if(newlist != null && newlist.size() > 0) {
            if(triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                List<TDTM_Global_API.TdtmToken> cachedTokens = TDTM_Global_API.getTdtmConfig();
                cachedTokens.clear();
            }
        }

        return new DmlWrapper();
    }

}