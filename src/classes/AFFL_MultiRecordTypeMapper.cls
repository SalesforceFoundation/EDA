/*
    Copyright (c) 2014, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
* @author Salesforce.com Foundation
* @date 2015
* @group Affiliations
* @description Helps with the mapping of Account record types to Account lookup fields on Contact defined
*				in the Affiliation Mapping custom settings. 
*/
public with sharing class AFFL_MultiRecordTypeMapper {

	/*******************************************************************************************************
    * @description Map of Contact field names to Contact field labels.
    ********************************************************************************************************/
	public Map<String, String> contactLabelNames;
		
    /*******************************************************************************************************
    * @description Affiliation Account-record-type-to-Contact-field mappings.
    ********************************************************************************************************/
    public Map<String, String> mapAccRecTypeToContactLabel;
    
    /*******************************************************************************************************
    * @description Affiliation Account-record-type-to-Academic-auto-create-field mappings.
    ********************************************************************************************************/
    public Map<String, Boolean> mapAccRecTypeToAcadAutoCreate;
    
    /*******************************************************************************************************
    * @description List of primary affiliation lookup fields names on Contact.
    ********************************************************************************************************/
    public List<String> primaryAfflFieldNames;
    
    /*******************************************************************************************************
    * @description Constructor that initializes class properties.
    ********************************************************************************************************/
    public AFFL_MultiRecordTypeMapper() {
    	//List of Contact field names.
		List<SObjectField> contactFields = Contact.sObjectType.getDescribe().fields.getMap().values();
		
		//Map of Contact field labels to Contact field Names.
		contactLabelNames = getContactLabelsNamesMap(contactFields);
		
		//List of primary affiliation lookup fields names.
		List<String> contactFieldNames = contactLabelNames.values();
		
		//Affiliation Account-record-type-to-Contact-field mappings.
		populateMaps();
		UTIL_Debug.debug('****MRT: primaryAfflMappings: ' + JSON.serializePretty(mapAccRecTypeToContactLabel)); 
		
		//List of primary affiliation lookup fields labels.
		List<String> primaryAfflFieldLabels = mapAccRecTypeToContactLabel.values();
		UTIL_Debug.debug('****MRT: primaryAfflFieldLabels: ' + JSON.serializePretty(primaryAfflFieldLabels));
		
		//List of primary affiliation Contact fields.
		List<SObjectField> primaryAfflFields = getPrimaryAfflFields(contactFields, primaryAfflFieldLabels);
		UTIL_Debug.debug('****MRT: primaryAfflFieldNames: ' + JSON.serializePretty(primaryAfflFieldNames));
    }
    
    private Map<String, String> getContactLabelsNamesMap(List<SObjectField> cf) {
    	Map<String, String> labelsnames = new Map<String, String>();
		for(SObjectField field : cf) {
			labelsnames.put(field.getDescribe().getLabel(), field.getDescribe().getName());
		}
		return labelsnames;
    }
    
    private void populateMaps() {
    	mapAccRecTypeToContactLabel = new Map<String, String>();
    	mapAccRecTypeToAcadAutoCreate = new Map<String, Boolean>();
		//Get the affiliation mappings.
		List<Affl_Mappings__c> primaryAfflMappings = [select Account_Record_Type__c, Primary_Affl_Field__c, Auto_Academic_Record__c from Affl_Mappings__c];
		//Put them in a map.
		for(Affl_Mappings__c mapping : primaryAfflMappings) {
			if(!String.isBlank(mapping.Account_Record_Type__c) && !String.isBlank(mapping.Primary_Affl_Field__c)) {
				mapAccRecTypeToContactLabel.put(mapping.Account_Record_Type__c, mapping.Primary_Affl_Field__c);
				mapAccRecTypeToAcadAutoCreate.put(mapping.Account_Record_Type__c, mapping.Auto_Academic_Record__c);
			}
		}
	}
	
	/*******************************************************************************************************
    * @description Returns those fields from the provided list that are in the provided list of lables. 
    * @param cf List of fields.
    * @param primaryAfflFieldLabels List of field labels.
    * @return List<SObjectField> List of fields in object that are in the provided list of labels.
    ********************************************************************************************************/
	private List<SObjectField> getPrimaryAfflFields(List<SObjectField> cf, List<String> primaryAfflFieldLabels) {
		Set<String> primaryAfflFieldLabelsSet = new Set<String>(primaryAfflFieldLabels);
		List<SObjectField> primaryFields = new List<SObjectField>();
		primaryAfflFieldNames = new List<String>();
		for(SObjectField field : cf) {
			if(primaryAfflFieldLabelsSet.contains(field.getDescribe().getLabel())) {
				primaryAfflFieldNames.add(field.getDescribe().getName());
				primaryFields.add(field);
			}
		}
		return primaryFields;
	}
	
	/*******************************************************************************************************
    * @description Returns the name of the key affiliation Contact field that matches the Account record type provided.
    * @param recordTypeId The ID of an Account record type.
    * @return String The name of the key affiliation Contact field.
    ********************************************************************************************************/
	public String getKeyAfflFieldByAccRecordType(ID recordTypeId) {
		for(String recTypeName : mapAccRecTypeToContactLabel.keySet()) {
    		ID rcId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
    		if(rcId == recordTypeId) {
    			String fieldLabel = mapAccRecTypeToContactLabel.get(recTypeName);
    			String fieldName = contactLabelNames.get(fieldLabel);
    			return fieldName;
    		}
		}
		return null;
    }
    
    /*******************************************************************************************************
    * @description Tells caller if Account record type needs Academic Record auto-creation.
    * @param accountRecordType The name of the Account record type as entered in the Affiliation Mappings.
    * @return Boolean Whether the Account record type has been flagged as needing Academic Record auto-creation.
    ********************************************************************************************************/
    public Boolean needsAcademicRecord(String accountRecordType) {
    	if(accountRecordType != null) {
    		return mapAccRecTypeToAcadAutoCreate.get(accountRecordType);
    	}
    	return false;
    }
}