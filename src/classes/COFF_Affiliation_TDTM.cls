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
* @group Program Enrollment
* @description Keeps Course Offering and Affiliation records for a Contact in sync. 
*/
public with sharing class COFF_Affiliation_TDTM extends TDTM_Runnable {

	/*******************************************************************************************************
    * @description Handles Affiliation management for Course Offering.
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Course Offering.
    * @return dmlWrapper.  
    ********************************************************************************************************/
	public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    
    	DmlWrapper dmlWrapper = new DmlWrapper(); 
        
        if(triggerAction == TDTM_Runnable.Action.BeforeInsert && newlist != null && newlist.size() > 0) {	
        	List<ID> termIDs = new List<ID>();
        	List<Course_Offering__c> offeringsWithFaculty = new List<Course_Offering__c>();
	 		
	 		for (SObject so : newlist) {
        		Course_Offering__c offering = (Course_Offering__c)so;
        		if(offering.Faculty__c != null) {
        			offeringsWithFaculty.add(offering);
        			//Storing the IDs so we can query fields in all related Term__c records in one query.
        			termIDs.add(offering.Term__c);
        		}
        		
	 		}
	 		//We need to explicitly query the start and end date fields in term because the data isn't there otherwise.
	 		List<Term__c> terms = new List<Term__c>();
	 		if(termIDs.size() > 0) {
	 			terms = [select Start_Date__c, End_Date__c from Term__c where ID in :termIDs];
	 		}
	 		
	 		for(Integer i = 0 ; i < offeringsWithFaculty.size(); i++) {
	 			Course_Offering__c offering = offeringsWithFaculty[i];
				//Automatically create an Affiliation record if a Course Offering record with a value in the Faculty field has been created.
    			dmlWrapper.objectsToInsert.add(new Affiliation__c(Contact__c = offering.Faculty__c, Account__c = offering.Department__c,
    											Role__c = 'Faculty', StartDate__c = terms[i].Start_Date__c, 
    											EndDate__c = terms[i].End_Date__c));
	 		}
        }
        return dmlWrapper;
    }
}