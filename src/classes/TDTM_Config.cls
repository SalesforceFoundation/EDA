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
 * @description Class that queries custom object to retrieve classes to call for creation or modification
 * of a record of a specific object type.
 */
public class TDTM_Config {
    
    /*******************************************************************************************************
    * @description Holds the trigger handlers cached in a list, to avoid repetitive soql calls.
    */
    private static List<TDTM_Global_API.TdtmToken> tdtmTokensCache;
    
    /*******************************************************************************************************
     * @description Number of Trigger Handlers records.
     */
    private static Integer rowCount;
    
    public TDTM_Config(List<TDTM_Global_API.TdtmToken> tdtmTokens) {
        if(tdtmTokens != null) {
            tdtmTokensCache = tdtmTokens;
            rowCount = tdtmTokens.size();
        } else {
            tdtmTokensCache = new List<TDTM_Global_API.TdtmToken>();
        }
    }
    
    /*******************************************************************************************************
    * @description
    */
    public static List<TDTM_Global_API.TdtmToken> getTdtmConfig() {
        if(tdtmTokensCache != null) {
            return tdtmTokensCache;
        }
        List<TDTM_Global_API.TdtmToken> tokens = new List<TDTM_Global_API.TdtmToken>();
        List<Trigger_Handler__c> defaultConfig = TDTM_DefaultConfig.getDefaultRecords();
        for(Trigger_Handler__c handler : defaultConfig) {
            tokens.add(new TDTM_Global_API.TdtmToken(handler.Class__c, handler.Object__c, handler.Trigger_Action__c, handler.Active__c, 
            Integer.valueOf(handler.Load_Order__c), handler.Asynchronous__c, handler.Filter_Field__c, handler.Filter_Value__c));
        }
        //tdtmTokensCache = tokens; we probably don't want to do this here, but instead have code explicity call setTdtmConfig.
        return tokens;
    }
    
    /*******************************************************************************************************
    * @description
    */
    public static void setTdtmConfig(List<TDTM_Global_API.TdtmToken> tdtmTokens) {
        tdtmTokensCache = tdtmTokens;
    }
    
    /*******************************************************************************************************
     * @description Checks if any TDTM records exist.
     * @return Boolean True is there are no TDTM records. False otherwise.
     */
    public Boolean isEmpty() {
        if(rowCount == null) {
            List<AggregateResult> result = [select count(Id) rowCount from Trigger_Handler__c];
            rowCount = (Integer)result[0].get('rowCount');
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
     * @return List<SObject> List of classes to call, sorted by load order.
     **/
    public static List<TDTM_Global_API.TdtmToken> getClassesToCallForObject(String objectName, TDTM_Runnable.Action action) {
        
        //@TODO: it seems silly we are getting them and then setting them...
        List<TDTM_Global_API.TdtmToken> tdtmTokens = getTdtmConfig();
        setTdtmConfig(tdtmTokens);
        
        /*if(tdtmTokensCache == null || tdtmTokensCache.size() == 0) {
             for(Trigger_Handler__c handler : [select Asynchronous__c, Class__c, Load_Order__c, Object__c, Active__c, 
             Trigger_Action__c, Filter_Field__c, Filter_Value__c from Trigger_Handler__c where Active__c = true order by Load_Order__c]) {
                 
                 tdtmTokensCache.add(new TDTM_Global_API.TdtmToken(handler.Class__c, handler.Object__c, handler.Active__c));
             }
        }
        List<SObject> listClasses = new List<Sobject>();
        for (Trigger_Handler__c th : triggerHandlers) {
            if (th.Object__c == objectName && th.Trigger_Action__c.contains(action.Name())) 
                listClasses.add(th);
        }*/
        
        Map<Integer, List<TDTM_Global_API.TdtmToken>> loadOrderedTokens = new Map<Integer, List<TDTM_Global_API.TdtmToken>>();
        Integer loadOrderMax = 0;
        //Put all tokens for the specified object in map, keyed by load order.
        for(TDTM_Global_API.TdtmToken token : tdtmTokens) {
            if(token.getTargetObject() == objectName) {
                //We need a list, in case there is more than one entry with the same load order.
                List<TDTM_Global_API.TdtmToken> tokens = loadOrderedTokens.get(token.getLoadOrder());
                if(tokens == null)
                    tokens = new List<TDTM_Global_API.TdtmToken>();
                tokens.add(token);
	            loadOrderedTokens.put(token.getLoadOrder(), tokens);
	            if(token.getLoadOrder() > loadOrderMax)
	                loadOrderMax = token.getLoadOrder();
            }
        }
        
        List<TDTM_Global_API.TdtmToken> sortedTokens = new List<TDTM_Global_API.TdtmToken>(); 
        //Sort them by load order
        for(Integer i = 0; i <= loadOrderMax; i++) {
            List<TDTM_Global_API.TdtmToken> tokens = loadOrderedTokens.get(i);
            sortedTokens.addAll(tokens);
        }
        
        return sortedTokens;
    }
    
    /*******************************************************************************************************
     * @description to allow test code to modify the saved trigger handlers and have them reread into the cache.
     */ 
    public static void clearTdtmCacheForTest() {
        tdtmTokensCache = null;
    }
}