/*
    Copyright (c) 2015, Salesforce.org
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
* @date 2015
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description Validates Trigger Handler filtering condition. 
*/
public class THAN_Filter_TDTM extends TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description Validates Trigger Handler fields data.
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Course Offering.
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        if(newlist != null) {
            //newList should be a short list of records. There should be no duplicates. That is, you shouldn't have two entries
            //for AFFL_MultiRecordType_TDTM running on Affiliation__c. Thus we are not going to try to optimize that case.
            for (integer i=0; i<newlist.size(); i++) {
                Trigger_Handler__c handler = (Trigger_Handler__c)newlist[i];
                
                if(triggerAction == TDTM_Runnable.Action.BeforeInsert || triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
                    //null should be a valid filter value, so we only check if the filter field isn't null
                    if(handler.Filter_Field__c == null && handler.Filter_Value__c != null) {
                        handler.addError(Label.BothFieldAndValue);
                    } else if(handler.Filter_Field__c != null && handler.Object__c != null) {
	                    String filterField = String.escapeSingleQuotes(handler.Filter_Field__c);
	                    String obj = String.escapeSingleQuotes(handler.Object__c);
	                    if(!String.isBlank(filterField) && !String.isBlank(obj)) {
                            //those four type of fields are considered valid Filter field
                            //1. Standard Field e.g. FirstName
                            //2. HEDA Field WITHOUT namespace e.g. Military_Service__c
                            //3. User's Custom Field e.g. MyField__c
                            //4. Field from another package with namespace e.g. NS__Field__c
                            //5. The relationship field e.g. Account.Id; Affiliation__c.Account__c.RecordType.Name
                            //if the Filter Field is not a relationship field, then we need to do more check
                            if(filterField.contains('.')) {
                                try {
                                    String dynamicQuery = 'select ' + filterField + ' from ' + obj + ' limit 1';
                                    List<SObject> records =  Database.query(dynamicQuery);
                                } catch(QueryException e) {
                                    handler.addError(Label.InvalidFilter + handler.Class__c);
                                }
                            } else {
                                String hedaPrefix = String.isBlank(UTIL_Namespace.getNamespace()) ? '' : (UTIL_Namespace.getNamespace() + '__');
                                Boolean hasHEDAPrefix = filterField.startsWithIgnoreCase(hedaPrefix) ? true : false;
                                Boolean ignoreDuplicateField = filterField.endsWithIgnoreCase(Label.duplicateFieldInFilter) ? true: false;

                                //Get the ignoreDuplicateField flag and remove it from the Filter Field value
                                if(ignoreDuplicateField) {
                                    filterField = filterField.replace(Label.duplicateFieldInFilter, '');
                                    handler.Filter_Field__c = handler.Filter_Field__c.replace(Label.duplicateFieldInFilter, '');
                                }

                                //System should't allow a Filter Field with HEDA namespace
                                if(String.isNotBlank(hedaPrefix) && hasHEDAPrefix) {
                                    handler.addError(Label.InvalidFilter + handler.Class__c + '. ' + Label.fieldWithHEDANamespace);
                                } else {

                                    //Get Sobject keyset. If user put a HEDA object without namespace, we need to add the namespace for it
                                    Set<String> fieldSet = UTIL_Describe.getAllFieldsDescribe(obj) == null ? UTIL_Describe.getAllFieldsDescribe(UTIL_Namespace.StrTokenNSPrefix(obj)).keySet() : UTIL_Describe.getAllFieldsDescribe(obj).keySet();

                                    //First, test if the field exists outside HEDA
                                    Boolean fieldExists = fieldSet.contains(filterField.toLowerCase());

                                    //Second, add the HEDA namespace and test if the field exists in HEDA
                                    filterField = UTIL_Namespace.StrTokenNSPrefix(filterField);
                                    Boolean fieldExistsHEDA = fieldSet.contains(filterField.toLowerCase());

                                    if(fieldExists && fieldExistsHEDA && !ignoreDuplicateField) {
                                        handler.addError(Label.InvalidFilter + handler.Class__c + '. ' +string.format(Label.duplicateWithHEDAField, new String[]{Label.duplicateFieldInFilter}));
                                    }

                                    if(!fieldExists && !fieldExistsHEDA) {
                                        handler.addError(Label.InvalidFilter + handler.Class__c);
                                    }
                                }
                            }
	                    }
                    }
                }
            }
        }
        
        return new DmlWrapper();
    }
}