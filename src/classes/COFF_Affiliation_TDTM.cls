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
        
        List<Course_Offering__c> offsWithNewFaculty = new List<Course_Offering__c>();
        List<ID> afflsToUpdateIDs = new List<ID>();
        List<ID> updatedFacultyIDs = new List<ID>();
        List<ID> afflsToDeleteIDs = new List<ID>();
        
        for (integer i=0; i<newlist.size(); i++) {
        	Course_Offering__c newOff = (Course_Offering__c)newlist[i];
        	
	        if(triggerAction == TDTM_Runnable.Action.BeforeInsert) {
	        	//Course Offering with Faculty has been created
        		if(newOff.Faculty__c != null) {
        			offsWithNewFaculty.add(newOff);
        		}
	        } else if(triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
	        	Course_Offering__c oldOff = (Course_Offering__c)oldlist[i];
	        	
	        	//Faculty member has been added to existing Course Offering --> create Affiliation
	        	if(oldOff.Faculty__c == null && newOff.Faculty__c != null) {
	        		offsWithNewFaculty.add(newOff);
	        	
	        	//Faculty member has been removed from existing Course Offering - 1st part--> clear Affiliation lookups
	        	} else if(oldOff.Faculty__c != null && newOff.Faculty__c == null) {
	        		newOff.Affiliation__c = null;
	        		
	        	//Faculty member has been changed --> update Affiliation
	        	} else if(oldOff.Faculty__c != null && newOff.Faculty__c != null && oldOff.Faculty__c != newOff.Faculty__c) {
	        		afflsToUpdateIDs.add(oldOff.Affiliation__c);
	        		updatedFacultyIDs.add(newOff.Faculty__c);
	        	}
	        } else if(triggerAction == TDTM_Runnable.Action.AfterUpdate) {
	        	Course_Offering__c oldOff = (Course_Offering__c)oldlist[i];
	        	
	        	//Faculty member has been removed from existing Course Offering - 2nd part --> colect Affiliation IDs
	        	if(oldOff.Faculty__c != null && newOff.Faculty__c == null) {
	        		afflsToDeleteIDs.add(oldOff.Affiliation__c);
	        	}
	        }
        }
        
        if(offsWithNewFaculty.size() > 0) {
        	//We cannot add the new records to the DmlWrapper because we need to update the Course Offering records with the Affiliations just created.
        	createAffls(offsWithNewFaculty);
        }
        
        if(afflsToUpdateIDs.size() > 0) {
        	dmlWrapper.objectsToUpdate.addAll(updateAffiliations(afflsToUpdateIDs, updatedFacultyIDs));
        }
        
        if(afflsToDeleteIDs.size() > 0) {
        	dmlWrapper.objectsToDelete.addAll((List<SObject>)[select ID from Affiliation__c where ID in :afflsTodeleteIDs]);
        }
        
        return dmlWrapper;
    }
    
    private void createAffls(List<Course_Offering__c> offsWithNewFaculty) {
    	List<ID> termIDs = new List<ID>();
    	for(Course_Offering__c offering : offsWithNewFaculty) {
    		//Storing the IDs so we can query fields in all related Term__c records in one query.
        	termIDs.add(offering.Term__c);
    	}
    	
    	//We need to explicitly query the start and end date fields in term because the data isn't there otherwise.
 		List<Term__c> terms = new List<Term__c>();
 		if(termIDs.size() > 0) {
 			terms = [select Start_Date__c, End_Date__c from Term__c where ID in :termIDs];
 		}
 		
 		//Automatically create an Affiliation record if a Course Offering record with a value in the Faculty field has been created.
 		List<Affiliation__c> afflsToInsert = new List<Affiliation__c>();
 		for(Integer i = 0 ; i < offsWithNewFaculty.size(); i++) {
 			Course_Offering__c offering = offsWithNewFaculty[i];
			afflsToInsert.add(new Affiliation__c(Contact__c = offering.Faculty__c, Account__c = offering.Department__c,
											Role__c = 'Faculty', StartDate__c = terms[i].Start_Date__c, 
											EndDate__c = terms[i].End_Date__c));
 		}
 		insert afflsToInsert;
 		
 		//Update the Course Offering Affiliation lookup.
 		for(Integer i = 0 ; i < offsWithNewFaculty.size(); i++) {
 			offsWithNewFaculty[i].Affiliation__c = afflsToInsert[i].ID;
 		}
    }
    
    private List<SObject> updateAffiliations(List<ID> afflsToUpdateIDs, List<ID> updatedFacultyIDs) {
    	List<Affiliation__c> afflsWithContact = [select Contact__c from Affiliation__c where ID in :afflsToUpdateIDs];
    	Map<ID, Affiliation__c> afflsWithContactMap = new Map<ID, Affiliation__c>(afflsWithContact);
    	//We have to make sure we are updating the correct Affiliations.
    	for(Integer i = 0; i < afflsToUpdateIDs.size() ; i++) {
    		Affiliation__c afflWithContact = afflsWithContactMap.get(afflsToUpdateIDs[i]);
    		afflWithContact.Contact__c = updatedFacultyIDs[i];
    	}
    	return afflsWithContact;
    }
}