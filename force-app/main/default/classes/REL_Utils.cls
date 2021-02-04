/*
    Copyright (c) 2009,2012, Salesforce.org
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
* @date 2011,2012
* @group Relationships
* @group-content ../../ApexDocContent/Relationships.htm
* @description Relationships utilities.
*/
public with sharing class REL_Utils {

    private static Map<String, Relationship_Auto_Create__c> autoCreateMap;
    
    public static Map<String, Relationship_Auto_Create__c> getAutoCreateMap() {
        if(AutoCreateMap == null){
            List<Relationship_Auto_Create__c> settings = UTIL_CustomSettingsFacade.getAutoCreateSettings();
            AutoCreateMap = new Map<String, Relationship_Auto_Create__c>();
            for(Relationship_Auto_Create__c setting : settings) {
                autoCreateMap.put(setting.Name, setting);
            }
        }
        return autoCreateMap;
    }
    
    private static Boolean contactAutoCreate;
    public static Boolean hasContactAutoCreate{get{
        if (contactAutoCreate == null){
            for(String s : getAutoCreateMap().keySet()){
               if (getAutoCreateMap().get(s).Object__c == 'Contact'){
                   contactAutoCreate = true;
                   break;
               }                
            }     
            if (contactAutoCreate != true)contactAutoCreate = false;    
        }           
        return contactAutoCreate;   
    }}
    
    private static Boolean cmAutoCreate;
    public static Boolean hasCMAutoCreate{get{
        if (cmAutoCreate == null){
            for(String s : getAutoCreateMap().keySet()){
                if(getAutoCreateMap().get(s).Object__c == 'CampaignMember'){
                    cmAutoCreate = true;
                    break;
                }
            }
            if (cmAutoCreate != true)cmAutoCreate = false;
        }   
        return cmAutoCreate;
    }}
}