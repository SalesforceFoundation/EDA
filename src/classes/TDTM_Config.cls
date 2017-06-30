/*
    Copyright (c) 2013, Salesforce.org
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
 * @date 2014
 * @group TDTM
 * @group-content ../../ApexDocContent/TDTM.htm
 * @description A Class to retreive, cache and interact with the Org wide TDTM configurtaion
 */
public class TDTM_Config {

    /*******************************************************************************************************
    * @description Holds the trigger handlers cached in a list, to avoid repetitive soql calls.
    *********************************************************************************************************/
    @TestVisible
    private static List<TDTM_Global_API.TdtmToken> tdtmTokensCache;

    /*******************************************************************************************************
    * @description Number of trigger handlers records that currently exist in the system.
    *********************************************************************************************************/
    private static Integer rowCount;

    /********************************************************************************************************
    * @description Returns the TDTM configuration. If no configuration is currently set, it will return
    * the default configuration without setting it. The configuration returned has not yet been inserted in the
    * database. It can be manipulated, if necessary, then set.
    * If no configuration exists, the application will insert the defaults when any of the triggers run.
    * @return List<TDTM_Global_API.TdtmToken> List of trigger handler tokens with the default values.
    *********************************************************************************************************/
    public static List<TDTM_Global_API.TdtmToken> getTdtmConfig() {
        if(tdtmTokensCache != null) {
            return tdtmTokensCache;
        }
        List<TDTM_Global_API.TdtmToken> tokens = new List<TDTM_Global_API.TdtmToken>();
        List<Trigger_Handler__c> tdtmConfig = [select Class__c, Object__c, Trigger_Action__c, Load_Order__c, Active__c,
                            Asynchronous__c, Filter_Field__c, Filter_Value__c, User_Managed__c, Owned_by_Namespace__c from Trigger_Handler__c];

        // Getting the default configuration only if there is no data in the Trigger Handler object. Otherwise
        // we would delete customizations and Trigger Handlers entries that aren't in the default configuration.
        if(tdtmConfig.size() == 0) {
	        tdtmConfig = TDTM_DefaultConfig.getDefaultRecords();
        }

        for(Trigger_Handler__c handler : tdtmConfig) {
            tokens.add(new TDTM_Global_API.TdtmToken(handler.Class__c, handler.Object__c, handler.Trigger_Action__c,
                    handler.Load_Order__c, handler.Active__c, handler.Asynchronous__c,
                    handler.Filter_Field__c, handler.Filter_Value__c, handler.User_Managed__c, handler.Owned_by_Namespace__c));
        }

        tdtmTokensCache = tokens;

        return tokens;
    }

    /********************************************************************************************************
    * @description Returns the default TDTM configuration directly as TDTM Tokens as a List.
    * @return List<TDTM_Global_API.TdtmToken> List of trigger handler tokens with the default values.
    *********************************************************************************************************/
    public static List<TDTM_Global_API.TdtmToken> getDefaultTdtmConfig() {
        if(tdtmTokensCache != null) {
            return tdtmTokensCache;
        }

        List<TDTM_Global_API.TdtmToken> tokens = new List<TDTM_Global_API.TdtmToken>();

        List<Trigger_Handler__c> existingHandlers = TDTM_DefaultConfig.getDefaultRecords();
        for(Trigger_Handler__c handler : existingHandlers) {
            tokens.add(
                new TDTM_Global_API.TdtmToken(handler.Class__c, handler.Object__c, handler.Trigger_Action__c, handler.Load_Order__c, handler.Active__c, handler.Asynchronous__c, handler.Filter_Field__c, handler.Filter_Value__c, handler.User_Managed__c, handler.Owned_by_Namespace__c )
            );
        }

        tdtmTokensCache = tokens;

        return tokens;
    }

    /*******************************************************************************************************
    * @description Checks if any Trigger Handler records exist in the database.
    * @return Boolean True is there are no TDTM records. False otherwise.
    *********************************************************************************************************/
    public static Boolean isEmpty() {
        if(rowCount == null) {
            List<AggregateResult> result = [select count(Id) rowCount from Trigger_Handler__c];
            rowCount = (Integer)result[0].get('rowCount');
            UTIL_Debug.debug('****rowCount: ' + rowCount);
        }
        if(rowCount == 0)
            return true;
        return false;
    }

    /*******************************************************************************************************
    * @description Returns the classes that will be called for the specified object and action. Returned list
    *              is sorted by load order.
    * @param objectName The name of the object.
    * @param action The action (before insert, after insert,...).
    * @return List<DTM_Global_API.TdtmToken> List of trigger handlers to call, sorted by load order.
    *********************************************************************************************************/
    public static List<TDTM_Global_API.TdtmToken> getClassesToCallForObject(String objectName, TDTM_Runnable.Action action) {

        //Getting the TDTM configuration and storing it in the cache.
        List<TDTM_Global_API.TdtmToken> tdtmTokens = getTdtmConfig();

        //Using a map because there might be more than one TDTM entry with the same Load Order for the same Object.
        Map<Decimal, List<TDTM_Global_API.TdtmToken>> loadKeyedTokens = new Map<Decimal, List<TDTM_Global_API.TdtmToken>>();
        Decimal loadOrderMax = 0;
        //Put all tokens for the specified object in map, keyed by load order.
        for(TDTM_Global_API.TdtmToken token : tdtmTokens) {
            //Filtering those active by object and action.
            if(token.active && token.targetObject == objectName && token.actions.contains(action.Name())) {
                //We need a list, in case there is more than one entry with the same load order.
                List<TDTM_Global_API.TdtmToken> tokens = loadKeyedTokens.get(token.loadOrderDec);
                if(tokens == null)
                    tokens = new List<TDTM_Global_API.TdtmToken>();
                tokens.add(token);
	            loadKeyedTokens.put(token.loadOrderDec, tokens);
	            if(token.loadOrderDec > loadOrderMax)
	                loadOrderMax = token.loadOrderDec;
            }
        }

        List<TDTM_Global_API.TdtmToken> sortedTokens = new List<TDTM_Global_API.TdtmToken>();
        //Sort them by load order
        for(Integer i = 0; i <= loadOrderMax; i++) {
            List<TDTM_Global_API.TdtmToken> tokens = loadKeyedTokens.get(i);
            if(tokens != null)
                sortedTokens.addAll(tokens);
        }
        return sortedTokens;
    }
}