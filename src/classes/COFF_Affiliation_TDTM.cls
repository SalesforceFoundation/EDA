/*
    Copyright (c) 2014, Salesforce.org
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
* @group Course Offering
* @group-content ../../ApexDocContent/CourseOfferings.htm
* @description Keeps Course Offering and Affiliation records for a Contact in sync. 
*/
public class COFF_Affiliation_TDTM extends TDTM_Runnable {

   /*******************************************************************************************************
    * @description static flag to prevent recursive call 
    */
    public static boolean hasRunCoffTrigger = false;
    
   /*******************************************************************************************************
    * @description Handles Affiliation management for Course Offering.
                   Populates Start and End Date from Term, if fields are empty.
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Course Offering.
    * @return dmlWrapper.  
    ********************************************************************************************************/
	public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

    	DmlWrapper dmlWrapper = new DmlWrapper(); 
        
        // prevent recursion
        if (!hasRunCoffTrigger) {
	        List<Course_Offering__c> offsWithNewFaculty = new List<Course_Offering__c>();
	        
	        List<ID> newFacultyIDs = new List<ID>();
	        List<ID> updatedFacultyIDs = new List<ID>();
	        List<ID> outdatedFacultyIDs = new List<ID>();
	        List<ID> removedFacultyIDs = new List<ID>();
	                
	        List<Course_Enrollment__c> courseEnrllsToInsert = new List<Course_Enrollment__c>();
	            
	        if(newlist != null) {
	            if (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
	                //Query fields not available in the trigger
	                newList = [select Course__c, Faculty__c, Start_Date__c, End_Date__c, Course__r.Account__c, Term__r.Start_Date__c, 
	                            Term__r.End_Date__c from Course_Offering__c where ID in :newlist];
	            }
		        for (integer i=0; i<newlist.size(); i++) {
		        	Course_Offering__c newOff = (Course_Offering__c)newlist[i];
		        	
			        if(triggerAction == TDTM_Runnable.Action.AfterInsert) {
			        	//Course Offering with Faculty has been created 
			        	//   --> create Affl if no other Affl to Dpt exists
			        	//   --> create Course Enrollment
			    		if(newOff.Faculty__c != null) {
			    		    UTIL_Debug.debug('****Course Offering with Faculty has been created');
			    			newFacultyIDs.add(newOff.Faculty__c);
			    			offsWithNewFaculty.add(newOff);
			    			courseEnrllsToInsert.add(new Course_Enrollment__c(Contact__c = newOff.Faculty__c, Account__c = newOff.Course__r.Account__c, 
			    			                                                    Course_Offering__c = newOff.Id));
			    		}
			    		
			    		Boolean dateCopied = false;
	                    //Copy Start Date from parent Term, if no value entered
	                    if(String.isBlank(String.valueOf(newOff.Start_Date__c)) && !String.isBlank(String.valueOf(newOff.Term__r.Start_Date__c))) {
	                        UTIL_Debug.debug('****Copying term start date to course offering: ' +  newOff.Term__r.Start_Date__c);
	                        newOff.Start_Date__c = newOff.Term__r.Start_Date__c;
	                        dateCopied = true;
	                    }
	                    //Copy End Date from parent Term, if no value entered
	                    if(String.isBlank(String.valueOf(newOff.End_Date__c)) && !String.isBlank(String.valueOf(newOff.Term__r.End_Date__c))) {
	                        UTIL_Debug.debug('****Copying term start date to course offering: ' +  newOff.Term__r.Start_Date__c);
	                        newOff.End_Date__c = newOff.Term__r.End_Date__c;
	                        dateCopied = true;
	                    }
	                    
	                    //Nowhere else in this class are Course Offerings added to dmlWrapper.objectsToUpdate. If they were, we 
	                    //should put all those changes together to avoid adding those records to dmlWrapper.objectsToUpdate more
	                    //than once. 
	                    if(dateCopied) dmlWrapper.objectsToUpdate.add(newOff);
			        	
			        } else if(triggerAction == TDTM_Runnable.Action.AfterUpdate) {
			        	Course_Offering__c oldOff = (Course_Offering__c)oldlist[i];
			        	
			        	//Faculty member has been added to existing Course Offering 
	                    //   --> create Affl if no other Affl to Dpt exists
	                    //   --> create Course Enrollment
	                    if(oldOff.Faculty__c == null && newOff.Faculty__c != null) {
	                        UTIL_Debug.debug('****Faculty member has been added to existing Course Offering');
	                        newFacultyIDs.add(newOff.Faculty__c);
	                        offsWithNewFaculty.add(newOff);
	                        courseEnrllsToInsert.add(new Course_Enrollment__c(Contact__c = newOff.Faculty__c, Account__c = newOff.Course__r.Account__c, 
	                                                                            Course_Offering__c = newOff.Id));
	                        
	                    //Faculty member has been changed 
	                    //   --> update Affiliation to Dpt to point it to the new Faculty
	                    } else if(oldOff.Faculty__c != null && newOff.Faculty__c != null && oldOff.Faculty__c != newOff.Faculty__c) {
	                        UTIL_Debug.debug('****Faculty member has been changed');
	                        outdatedFacultyIDs.add(oldOff.Faculty__c);
	                        updatedFacultyIDs.add(newOff.Faculty__c);
	                    
			        	//Faculty member has been removed from existing Course Offering 
			        	//   --> delete related Affiliation
			        	//   --> delete Course Enrollment
	                    } else if(oldOff.Faculty__c != null && newOff.Faculty__c == null) {
			        	    UTIL_Debug.debug('****Faculty member has been removed from existing Course Offering');
							removedFacultyIDs.add(oldOff.Faculty__c);
			        	}
			        }
		        }
	        }
	        
	        if(oldlist != null) {
		        for (integer i=0; i<oldlist.size(); i++) {
		            Course_Offering__c oldOff = (Course_Offering__c)oldlist[i];
		            
		            if(triggerAction == TDTM_Runnable.Action.AfterDelete) {             
	
		                //Course Offering has been deleted
		                //     --> delete related Affiliation, if the faculty field had a value
		                //     --> delete the Course Enrollment, if the faculty field had a value
		                if(oldOff.Faculty__c != null) {
		                    UTIL_Debug.debug('****Course Offering with faculty has been deleted');
		                    removedFacultyIDs.add(oldOff.Faculty__c);
		                }
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
	               deleteAfflsEnrolls(removedFacultyIDs, dmlWrapper); //Passing dmlWrapper because there's more than one DML to perform
	        }
        }
        return dmlWrapper;
    }
    
   /*******************************************************************************************************
    * @description Creates Affiliation records for Faculty members assigned to Course Offerings, if no Affiliation
    * existed for the department the Course Offering belongs to. Also, it links the automatically created Course
    * Enrollments to the automatically created Affiliations.
    ********************************************************************************************************/
    private void createAffls(List<Course_Offering__c> offsWithNewFaculty, List<ID> newFacultyIDs, List<Course_Enrollment__c> courseEnrllsToInsert) { 		
 		//Find all Affls for all Faculty members in the trigger.
 		Map<ID, List<Affiliation__c>> facultyIDtoAffls = getAfflsForContact(newFacultyIDs);
 		
 		//Automatically create an Affiliation record if a Course Offering record with a value in the Faculty field has been created,
 		//and no Affl to the parent Department exists.
 		List<Affiliation__c> afflsToInsert = new List<Affiliation__c>();
 		List<Affiliation__c> afflsTemp = new List<Affiliation__c>();
 		for(Integer i = 0 ; i < offsWithNewFaculty.size(); i++) {
 			Course_Offering__c offering = offsWithNewFaculty[i];
 			Boolean afflToDptExists = afflToDptExists(offering, facultyIDtoAffls);
 			UTIL_Debug.debug('****Affl to Dpt already exists: ' + afflToDptExists);
 			if(!afflToDptExists) {
 			    Affiliation__c afflToInsert = new Affiliation__c(Contact__c = offering.Faculty__c, Account__c = offering.Course__r.Account__c,
                                         Role__c = 'Faculty', StartDate__c = offering.Term__r.Start_Date__c, EndDate__c = offering.Term__r.End_Date__c);
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
    
   /*******************************************************************************************************
    * @description Sets each Affiliation pointing to the new Faculty member that is teaching the Course Offering. 
    ********************************************************************************************************/
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
    
   /*******************************************************************************************************
    * @description Updates each Course Enrollment from the old Faculty member to the new Faculty member. A Faculty 
    * member should not be at the same time teaching and attending a course, so querying for all outdatedFacultyIDs 
    * should be ok. 
    ********************************************************************************************************/
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
    
    
   /*******************************************************************************************************
    * @description Deletes the Affiliations that had been automatically created from the Course Enrollments with
    * assigned Faculty members. Also deletes the Course Enrollments themselves.
    ********************************************************************************************************/
    private void deleteAfflsEnrolls(List<ID> removedFacultyIDs, DmlWrapper dmlWrapper) {
        List<Course_Enrollment__c> oldEnrolls = [select ID, Affiliation__c from Course_Enrollment__c where Contact__c in :removedFacultyIDs];
        List<ID> afflsToDeleteIDs = new List<ID>();
        for(Course_Enrollment__c enroll : oldEnrolls) {
            afflsToDeleteIDs.add(enroll.Affiliation__c);
        }
        dmlWrapper.objectsToDelete.addAll((List<SObject>)[select ID from Affiliation__c where ID in :afflsToDeleteIDs]);
        dmlWrapper.objectsToDelete.addAll((List<SObject>)oldEnrolls);
    }
    
   /*******************************************************************************************************
    * @description Returns a map with the Contact ID of each faculty member as the key, and all its Affiliations
    * as the values. Public only so it can be called from the tests.
    ********************************************************************************************************/
    public Map<ID, List<Affiliation__c>> getAfflsForContact(List<ID> newFacultyIDs) {
    	UTIL_Debug.debug('****Number of newly assigned faculty: ' + newFacultyIDs.size());
    	//Find all Affls for all Faculty members in the trigger.
        Map<ID, List<Affiliation__c>> facultyIDtoAffls = new Map<ID, List<Affiliation__c>>();
        List<Affiliation__c> affls = [select Account__c, Contact__c from Affiliation__c where Contact__c in :newFacultyIDs 
                                        order by Contact__c];
        UTIL_Debug.debug('****Number of affls for existing faculty: ' + affls.size());
        
        if(affls.size() > 0) {
	        //Set initial values, to compare against
	        Affiliation__c affl = affls[0];
	        ID contactID = affls[0].Contact__c;
	        List<Affiliation__c> facultyAffls = new Affiliation__c[] {affl};
	        facultyIDtoAffls.put(contactID, facultyAffls);
	        
	        //Iterate through the rest of the affiliations
	        for(Integer i = 1; i < affls.size(); i++) { 
	            if(affls[i].Contact__c == contactID) {
	                facultyAffls.add(affls[i]);   
	            } else {
	                contactID = affls[i].Contact__c;
                    facultyAffls = new List<Affiliation__c>();
                    facultyAffls.add(affls[i]);
                    facultyIDtoAffls.put(contactID, facultyAffls);
	            }
	        }
        }
        return facultyIDtoAffls;
    }
    
   /*******************************************************************************************************
    * @description Determins whether an Affiliation to the Department the Course Offering belongs to already
    * exists for each faculty member. Public only so it can be called from the tests.
    ********************************************************************************************************/
    public Boolean afflToDptExists(Course_Offering__c offering, Map<ID, List<Affiliation__c>> facultyIDtoAffls) {
    	List<Affiliation__c> facultyMemberAffls = facultyIDtoAffls.get(offering.Faculty__c);
        Boolean afflToDptExists = false;
        if(facultyMemberAffls != null && facultyMemberAffls.size() > 0) {
            for(Affiliation__c affl : facultyMemberAffls) {
                if(affl.Account__c == offering.Course__r.Account__c) {
                    afflToDptExists = true;
                    break;
                }
            }
        }
        return afflToDptExists;
    }
}