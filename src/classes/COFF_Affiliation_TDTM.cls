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
        
        List<ID> newFacultyIDs = new List<ID>();
        List<ID> updatedFacultyIDs = new List<ID>();
        List<ID> outdatedFacultyIDs = new List<ID>();
        List<ID> removedFacultyIDs = new List<ID>();
        
        List<ID> afflsToUpdateIDs = new List<ID>();
        List<ID> afflsToDeleteIDs = new List<ID>();
        
        List<Course_Enrollment__c> courseEnrllsToInsert = new List<Course_Enrollment__c>();
        List<Course_Enrollment__c> courseEnrllsToUpdate = new List<Course_Enrollment__c>();
        List<Course_Enrollment__c> courseEnrllsToDelete = new List<Course_Enrollment__c>();
        
        for (integer i=0; i<newlist.size(); i++) {
        	Course_Offering__c newOff = (Course_Offering__c)newlist[i];
        	
	        if(triggerAction == TDTM_Runnable.Action.BeforeInsert) {
	        	//Course Offering with Faculty has been created 
	        	//   --> create Affl if no other Affl to Dpt exists
	        	//   --> create Course Enrollment
	    		if(newOff.Faculty__c != null) {
	    		    UTIL_Debug.debug('****Course Offering with Faculty has been created');
	    			newFacultyIDs.add(newOff.Faculty__c);
	    			offsWithNewFaculty.add(newOff);
	    			courseEnrllsToInsert.add(new Course_Enrollment__c(Contact__c = newOff.Faculty__c, Account__c = newOff.Department__c, 
	    			                                                    Course_Offering__c = newOff.Id));
	    		}
	        } else if(triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
			    Course_Offering__c oldOff = (Course_Offering__c)oldlist[i];
        	   UTIL_Debug.debug('****Old Affl ID in BeforeUpdate:' + oldOff.Affiliation__c);
	        	//Faculty member has been added to existing Course Offering 
	        	//   --> create Affl if no other Affl to Dpt exists
	        	//   --> create Course Enrollment
	        	if(oldOff.Faculty__c == null && newOff.Faculty__c != null) {
	        	    UTIL_Debug.debug('****Faculty member has been added to existing Course Offering');
	        	    newFacultyIDs.add(newOff.Faculty__c);
	        		offsWithNewFaculty.add(newOff);
	        		courseEnrllsToInsert.add(new Course_Enrollment__c(Contact__c = newOff.Faculty__c, Account__c = newOff.Department__c, 
	        		                                                    Course_Offering__c = newOff.Id));
	        		
	        	//Faculty member has been changed 
	        	//   --> update Affiliation to Dpt to point it to the new Faculty
	        	} else if(oldOff.Faculty__c != null && newOff.Faculty__c != null && oldOff.Faculty__c != newOff.Faculty__c) {
	        		UTIL_Debug.debug('****Faculty member has been changed');
	        		outdatedFacultyIDs.add(oldOff.Faculty__c);
	        		updatedFacultyIDs.add(newOff.Faculty__c);
	        	}
	        } else if(triggerAction == TDTM_Runnable.Action.AfterUpdate) {
	        	Course_Offering__c oldOff = (Course_Offering__c)oldlist[i];
	        	
	        	//Faculty member has been removed from existing Course Offering 
	        	//   --> delete related Affiliation
	        	//   --> delete Course Enrollment
	        	if(oldOff.Faculty__c != null && newOff.Faculty__c == null) {
	        	    UTIL_Debug.debug('****Faculty member has been removed from existing Course Offering');
					UTIL_Debug.debug('****Old Affl ID in AfterUpdate:' + oldOff.Affiliation__c);
					afflsToDeleteIDs.add(oldOff.Affiliation__c);
					removedFacultyIDs.add(oldOff.Faculty__c);
					//courseEnrllsToDelete.add();
	        	}
	        }
        }
        
        if(newFacultyIDs.size() > 0) {
        	   createAffls(offsWithNewFaculty, newFacultyIDs, courseEnrllsToInsert);
               dmlWrapper.objectsToInsert.addAll((List<SObject>)courseEnrllsToInsert);
        }   
        if(updatedFacultyIDs.size() > 0) {
        	   dmlWrapper.objectsToUpdate.addAll(getAfflsToUpdate(outdatedFacultyIDs, updatedFacultyIDs));
        	   updateEnrollments(outdatedFacultyIDs, updatedFacultyIDs, dmlWrapper); //Passing dmlWrapper because there's more than one DML to perform
        }
        if(removedFacultyIDs.size() > 0) {
        	   dmlWrapper.objectsToDelete.addAll((List<SObject>)[select ID from Affiliation__c where ID in :afflsTodeleteIDs]);
        	   dmlWrapper.objectsToDelete.addAll((List<SObject>)courseEnrllsToDelete);
        }
        return dmlWrapper;
    }
    
    private void createAffls(List<Course_Offering__c> offsWithNewFaculty, List<ID> newFacultyIDs, List<Course_Enrollment__c> courseEnrllsToInsert) {
	    List<Term__c> terms = queryTermDates(offsWithNewFaculty);
 		
 		//Find all Affls for all Faculty members in the trigger.
 		Map<ID, List<Affiliation__c>> facultyIDtoAffls = getAfflsForContact(newFacultyIDs);
 		
 		//Automatically create an Affiliation record if a Course Offering record with a value in the Faculty field has been created,
 		//and no Affl to the parent Deparment exists.
 		List<Affiliation__c> afflsToInsert = new List<Affiliation__c>();
 		List<Affiliation__c> afflsTemp = new List<Affiliation__c>();
 		for(Integer i = 0 ; i < offsWithNewFaculty.size(); i++) {
 			Course_Offering__c offering = offsWithNewFaculty[i];
 			Boolean afflToDptExists = afflToDptExists(offering, facultyIDtoAffls);
 			UTIL_Debug.debug('****Affl to Dpt already exists: ' + afflToDptExists);
 			if(!afflToDptExists) {
 			    Affiliation__c afflToInsert = new Affiliation__c(Contact__c = offering.Faculty__c, Account__c = offering.Department__c,
                                         Role__c = 'Faculty', StartDate__c = terms[i].Start_Date__c, EndDate__c = terms[i].End_Date__c);
				afflsToInsert.add(afflToInsert);
				afflsTemp.add(afflToInsert);
 			} else {
 			    afflsTemp.add(null); //Just so afflsToInsert has the same # of records as courseEnrllsToInsert
 			}
 		}
 		insert afflsToInsert;
 		
 		//Link Course Enrollments to Affiliations
 		for(Integer i = 0; i < afflsTemp.size(); i++) {
 		     if(afflsTemp[i] != null) {
 		         courseEnrllsToInsert[i].Affiliation__c = afflsTemp[i].ID; 
 		     }    
 		}
    }
    
    /** 
     * Update each Affiliation to an old Faculty member, and point it to the new Faculty member. 
     */
    private List<SObject> getAfflsToUpdate(List<ID> outdatedFacultyIDs, List<ID> updatedFacultyIDs) {
    	List<Affiliation__c> afflsWithContact = [select Contact__c from Affiliation__c where Contact__r.ID in :outdatedFacultyIDs and Role__c = 'Faculty'];
    	
    	Map<ID, Affiliation__c> oldFacultyToAfflMap = new Map<ID, Affiliation__c>();
    	for(Affiliation__c affl : afflsWithContact) {
    	    oldFacultyToAfflMap.put(affl.Contact__c, affl);
    	}
    	
    	//We have to make sure we are updating the correct Affiliations.
    	for(Integer i = 0; i < outdatedFacultyIDs.size() ; i++) {
    		Affiliation__c oldAffl = oldFacultyToAfflMap.get(outdatedFacultyIDs[i]);
    		oldAffl.Contact__c = updatedFacultyIDs[i];
    	}
    	return afflsWithContact;
    }
    
    /** 
     * Update each Course Enrollment of an old Faculty member to the new Faculty member. A Faculty member should not be
     * at the same time teaching and attending a course, so querying for all outdatedFacultyIDs should be ok. 
     */
    private void updateEnrollments(List<ID> outdatedFacultyIDs, List<ID> updatedFacultyIDs, DmlWrapper dmlWrapper) {
        List<Course_Enrollment__c> oldEnrolls = [select Affiliation__c, Account__c, Course_Offering__c 
                                                 from Course_Enrollment__c where Contact__c in :outdatedFacultyIDs];
        UTIL_Debug.debug('****Number of old enrollments: ' + oldEnrolls.size()); 
        List<Course_Enrollment__c> newEnrolls = new List<Course_Enrollment__c>();
        for(Integer i = 0; i < oldEnrolls.size(); i++) {
            newEnrolls.add(new Course_Enrollment__c(Contact__c = updatedFacultyIDs[i], Account__c = oldEnrolls[i].Account__c, 
                                                    Course_Offering__c = oldEnrolls[i].Course_Offering__c, 
                                                    Affiliation__c = oldEnrolls[i].Affiliation__c));   
        }
        dmlWrapper.objectsToDelete.addAll((List<SObject>)oldEnrolls);
        dmlWrapper.objectsToInsert.addAll((List<SObject>)newEnrolls);
    }
    
    private List<Term__c> queryTermDates(List<Course_Offering__c> offsWithNewFaculty) {
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
        return terms;
    }
    
    public Map<ID, List<Affiliation__c>> getAfflsForContact(List<ID> newFacultyIDs) {
    	UTIL_Debug.debug('****Number of newly assigned faculty: ' + newFacultyIDs.size());
    	//Find all Affls for all Faculty members in the trigger.
        Map<ID, List<Affiliation__c>> facultyIDtoAffls = new Map<ID, List<Affiliation__c>>();
        List<Affiliation__c> affls = [select Account__c, Contact__c from Affiliation__c where Contact__c in :newFacultyIDs order by Contact__c];
        UTIL_Debug.debug('****Number of affls for existing faculty: ' + affls.size());
        if(affls.size() > 0) {
	        //Set initial values, to compare against
	        Affiliation__c affl = affls[0];
	        ID contactID = affls[0].Contact__c;
	        List<Affiliation__c> facultyAffls = new Affiliation__c[] {affl};
	        facultyIDtoAffls.put(contactID, facultyAffls);
	        //Iterate through the other values
	        for(Integer i = 1; i < affls.size(); i++) { 
	            if(affls[i].Contact__c != contactID) {
	                facultyAffls = new List<Affiliation__c>();
	                facultyIDtoAffls.put(affls[i].Contact__c, facultyAffls);
	            } else {
	                facultyAffls.add(affls[i]);
	            }
	            contactID = affls[i].Contact__c;
	        }
        }
        return facultyIDtoAffls;
    }
    
    public Boolean afflToDptExists(Course_Offering__c offering, Map<ID, List<Affiliation__c>> facultyIDtoAffls) {
    	List<Affiliation__c> facultyMemberAffls = facultyIDtoAffls.get(offering.Faculty__c);
        Boolean afflToDptExists = false;
        if(facultyMemberAffls != null && facultyMemberAffls.size() > 0) {
            for(Affiliation__c affl : facultyMemberAffls) {
                if(affl.Account__c == offering.Department__c) {
                    afflToDptExists = true;
                    break;
                }
            }
        }
        return afflToDptExists;
    }
}