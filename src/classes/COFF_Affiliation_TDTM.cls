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
    * @description Handles Affiliation management for Course Offering.
                   Populates Start and End Date from Term, if fields are empty.
    * @param listNew the list of Course Offerings from trigger new.
    * @param listOld the list of Course Offerings from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Course Offering.
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        DmlWrapper dmlWrapper = new DmlWrapper();
        // prevent recursion
        if (!TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM)) {

            List<Course_Offering__c> offsWithNewFaculty = new List<Course_Offering__c>();
            Set<Id> offsWithChangedFaculty = new Set<Id>();
            Set<Id> offsWithRemovedFaculty = new Set<Id>();

            List<ID> newFacultyIDs = new List<ID>();
            List<ID> updatedFacultyIDs = new List<ID>();
            List<ID> outdatedFacultyIDs = new List<ID>();
            List<ID> removedFacultyIDs = new List<ID>();
            List<ID> facultyCleanupIDs = new List<ID>();

            List<SObject> objectsToInsert = new List<SObject>();
            List<SObject> objectsToUpdate = new List<SObject>();
            List<SObject> objectsToDelete = new List<SObject>();

            List<Course_Enrollment__c> courseEnrllsToInsert = new List<Course_Enrollment__c>();

            Map<Id, Course_Offering__c> mapNewFacultyIdToNewCourseOffering = new Map<Id, Course_Offering__c>();

            if(newlist != null) {
                
                if (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                    //Query fields not available in the trigger
                    newList = [SELECT Course__c
                                      , Faculty__c
                                      , Start_Date__c
                                      , End_Date__c
                                      , Course__r.Account__c
                                      , Term__r.Start_Date__c
                                      , Term__r.End_Date__c 
                               FROM Course_Offering__c 
                               WHERE ID IN :newlist];
                }
                
                for (Integer i=0; i<newlist.size(); i++) {
                    Course_Offering__c newOff = (Course_Offering__c)newlist[i];

                    if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                        //Course Offering with Faculty has been created
                        //   --> create Affl if no other Affl to Dpt exists
                        //   --> create Course Enrollment
                        if (newOff.Faculty__c != null) {
                            UTIL_Debug.debug('****Course Offering with Faculty has been created');
                            newFacultyIDs.add(newOff.Faculty__c);
                            offsWithNewFaculty.add(newOff);
                            Course_Enrollment__c newEnroll = new Course_Enrollment__c(Contact__c = newOff.Faculty__c,
                                                                                        Account__c = newOff.Course__r.Account__c,
                                                                                        Course_Offering__c = newOff.Id);
                            if (UTIL_CustomSettingsFacade.courseConnectionsEnabled()) {
                                // Course Connections is enabled, set RecordType and Primary__c
                                newEnroll.put('RecordTypeId', UTIL_Describe.getFacultyConnectionRecType());
                                newEnroll.Primary__c = true;
                            }
                            courseEnrllsToInsert.add(newEnroll);
                        }

                        Boolean dateCopied = false;
                        //Copy Start Date from parent Term, if no value entered
                        if (String.isBlank(String.valueOf(newOff.Start_Date__c)) && !String.isBlank(String.valueOf(newOff.Term__r.Start_Date__c))) {
                            UTIL_Debug.debug('****Copying term start date to course offering: ' +  newOff.Term__r.Start_Date__c);
                            newOff.Start_Date__c = newOff.Term__r.Start_Date__c;
                            dateCopied = true;
                        }
                        //Copy End Date from parent Term, if no value entered
                        if (String.isBlank(String.valueOf(newOff.End_Date__c)) && !String.isBlank(String.valueOf(newOff.Term__r.End_Date__c))) {
                            UTIL_Debug.debug('****Copying term start date to course offering: ' +  newOff.Term__r.Start_Date__c);
                            newOff.End_Date__c = newOff.Term__r.End_Date__c;
                            dateCopied = true;
                        }

                        //Nowhere else in this class are Course Offerings added to dmlWrapper.objectsToUpdate. If they were, we
                        //should put all those changes together to avoid adding those records to dmlWrapper.objectsToUpdate more
                        //than once.
                        if (dateCopied) {
                            dmlWrapper.objectsToUpdate.add(newOff);
                        }

                    } else if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                        Course_Offering__c oldOff = (Course_Offering__c)oldlist[i];

                        //Faculty member has been added to existing Course Offering
                        //   --> create Affl if no other Affl to Dpt exists
                        //   --> create Course Enrollment
                        //     --> Create without recordtype if course connections disabled
                        //     --> Create with recordtype and as primary if course connections enabled
                        if (oldOff.Faculty__c == null && newOff.Faculty__c != null) {
                            UTIL_Debug.debug('****Faculty member has been added to existing Course Offering');
                            newFacultyIDs.add(newOff.Faculty__c);
                            offsWithNewFaculty.add(newOff);
                            // Do not perform adding new Course Enrollments if Course Connections is enabled.
                            // Logic for if Course Connections is enabled is handled below.
                            if (!UTIL_CustomSettingsFacade.courseConnectionsEnabled()) {
                                Course_Enrollment__c enroll = new Course_Enrollment__c(Contact__c = newOff.Faculty__c,
                                                                                        Account__c = newOff.Course__r.Account__c,
                                                                                        Course_Offering__c = newOff.Id);
                                courseEnrllsToInsert.add(enroll);
                            }

                        //Faculty member has been changed
                        //   --> update Affiliation to Dpt to point it to the new Faculty
                        } else if (oldOff.Faculty__c != null && newOff.Faculty__c != null && oldOff.Faculty__c != newOff.Faculty__c) {
                            UTIL_Debug.debug('****Faculty member has been changed');
                            offsWithChangedFaculty.add(newOff.Id);
                            outdatedFacultyIDs.add(oldOff.Faculty__c);
                            updatedFacultyIDs.add(newOff.Faculty__c);
                            mapNewFacultyIdToNewCourseOffering.put(newOff.Faculty__c, newOff);

                        //Faculty member has been removed from existing Course Offering
                        //   --> delete related Affiliation
                        //   --> delete Course Enrollment
                        } else if (oldOff.Faculty__c != null && newOff.Faculty__c == null) {
                            UTIL_Debug.debug('****Faculty member has been removed from existing Course Offering');
                            removedFacultyIDs.add(oldOff.Faculty__c);
                            offsWithRemovedFaculty.add(newOff.Id);
                        }
                    }
                }
            }

            if (oldlist != null) {
                for (Integer i=0; i<oldlist.size(); i++) {
                    Course_Offering__c oldOff = (Course_Offering__c)oldlist[i];

                    if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {

                        //Course Offering has been deleted
                        //     --> delete related Affiliation, if the faculty field had a value
                        //     --> delete the Course Enrollment, if the faculty field had a value
                        if (oldOff.Faculty__c != null) {
                            UTIL_Debug.debug('****Course Offering with faculty has been deleted');
                            facultyCleanupIDs.add(oldOff.Faculty__c);
                            offsWithRemovedFaculty.add(oldOff.Id);
                        }
                    }
                }
            }
            // If new faculty added to existing Course Offering
            if (offsWithNewFaculty.size() > 0) {
                if (UTIL_CustomSettingsFacade.courseConnectionsEnabled()) {
                    updateConnectionsOnFacultyAdd(offsWithNewFaculty, objectsToInsert, objectsToUpdate);
                } else {
                    createOrLinkAffls(offsWithNewFaculty, newFacultyIDs, courseEnrllsToInsert);
                }
                dmlWrapper.objectsToInsert.addAll((List<SObject>)courseEnrllsToInsert);
            }

            if (updatedFacultyIDs.size() > 0) {
                if (UTIL_CustomSettingsFacade.courseConnectionsEnabled()) {
                    // Course connections is enabled. Handle updating of objects
                    updateConnectionsOnFacultyChange(outdatedFacultyIDs, updatedFacultyIDs, offsWithChangedFaculty, objectsToInsert, objectsToUpdate);
                } else {
                    List<Affiliation__c> newAffls = getAfflsToUpdate(outdatedFacultyIDs, updatedFacultyIDs, mapNewFacultyIdToNewCourseOffering);
                    for (Affiliation__c newAffl : newAffls) {
                        if (newAffl.Id != null) {
                            dmlWrapper.objectsToUpdate.add(newAffl);
                        } else {
                            dmlWrapper.objectsToInsert.add(newAffl);
                        }
                    }
                    // Course connections is not enabled. Handle deletion and creation of course enrollments
                    updateEnrollments(outdatedFacultyIDs, updatedFacultyIDs, offsWithChangedFaculty, dmlWrapper); //Passing dmlWrapper because there's more than one DML to perform
               }
            }

            if (removedFacultyIDs.size() > 0) {
                if (UTIL_CustomSettingsFacade.courseConnectionsEnabled()) {
                    updateConnectionsOnFacultyRemove(removedFacultyIDs, offsWithRemovedFaculty, objectsToUpdate);
                } else {
                    deleteAfflsEnrolls(removedFacultyIDs, offsWithRemovedFaculty, dmlWrapper); //Passing dmlWrapper because there's more than one DML to perform
                }
            }

            if (facultyCleanupIDs.size() > 0) {
                deleteAfflsEnrolls(facultyCleanupIDs, offsWithRemovedFaculty, dmlWrapper); //Passing dmlWrapper because there's more than one DML to perform
            }

            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, true);

            dmlWrapper.objectsToUpdate.addAll(objectsToUpdate);
            dmlWrapper.objectsToInsert.addAll(objectsToInsert);
            dmlWrapper.objectsToDelete.addAll(objectsToDelete);
        }

        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        dmlWrapper = null;
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
        return dmlWrapper;
    }

   /*******************************************************************************************************
    * @description Creates Affiliation records for Faculty members assigned to Course Offerings, if no Affiliation
    * existed for the department the Course Offering belongs to. Also, it links the automatically created Course
    * Enrollments to the automatically created Affiliations.
    ********************************************************************************************************/
    private void createOrLinkAffls(List<Course_Offering__c> offsWithNewFaculty, List<Id> newFacultyIDs, List<Course_Enrollment__c> courseEnrllsToInsert) {
         //Find all Affls for all Faculty members in the trigger.
         Map<Id, List<Affiliation__c>> facultyIDtoAffls = getAfflsForContact(newFacultyIDs);
         //Automatically create an Affiliation record if a Course Offering record with a value in the Faculty field has been created,
         //and no Affl to the parent Department exists.
         Map<String, Affiliation__c> affiliationsToInsertByContactAccountString = new Map<String, Affiliation__c>();
         List<Affiliation__c> afflsTemp = new List<Affiliation__c>();
         for (Integer i = 0 ; i < offsWithNewFaculty.size(); i++) {
             Course_Offering__c offering = offsWithNewFaculty[i];
             Affiliation__c afflToDpt = affiliationToAccount(offering, facultyIDtoAffls);
             
             if (afflToDpt == null) {
                UTIL_Debug.debug('****Affl to Dpt does not exist');
                Affiliation__c afflToInsert;
                
                String contactAccountKey = offering.Faculty__c + '' + offering.Course__r.Account__c;
                // Is the Affiliation already being inserted? If so, do not insert a duplicate.
                if (affiliationsToInsertByContactAccountString.containsKey(contactAccountKey)) {
                    afflToInsert = affiliationsToInsertByContactAccountString.get(contactAccountKey);
                } else {
                    afflToInsert = createAffiliationFromCourseOffering(offering);
                    affiliationsToInsertByContactAccountString.put(contactAccountKey, afflToInsert);
                }
                afflsTemp.add(afflToInsert);
             } else {
                 UTIL_Debug.debug('****Affl to Dpt exists: ' + afflToDpt.Id);
                 afflsTemp.add(afflToDpt); // Add existing affl to link to Course Enrollment
             }
         }
         insert affiliationsToInsertByContactAccountString.values();

         //Link Course Enrollments to Affiliations
         for (Integer i = 0; i < afflsTemp.size(); i++) {
              if (afflsTemp[i] != null) {
                  courseEnrllsToInsert[i].Affiliation__c = afflsTemp[i].Id;
              }
         }
    }

   /*******************************************************************************************************
    * @description Sets each Affiliation pointing to the new Faculty member that is teaching the Course Offering.
    ********************************************************************************************************/
    private List<SObject> getAfflsToUpdate(List<ID> outdatedFacultyIDs, List<ID> updatedFacultyIDs, Map<Id, Course_Offering__c> mapNewFacultyIdToNewCourseOffering) {
        List<Affiliation__c> afflsWithContact = [SELECT Contact__c FROM Affiliation__c WHERE Contact__c IN :outdatedFacultyIDs AND Role__c = 'Faculty'];
        Map<String, Affiliation__c> affiliationsToInsertByContactAccountString = new Map<String, Affiliation__c>();

        Map<ID, Affiliation__c> oldFacultyToAfflMap = new Map<ID, Affiliation__c>();
        for (Affiliation__c affl : afflsWithContact) {
            oldFacultyToAfflMap.put(affl.Contact__c, affl);
        }

        //We have to make sure we are updating the correct Affiliations.
        for (Integer i = 0; i < outdatedFacultyIDs.size() ; i++) {
            Id outdatedFacultyID = outdatedFacultyIDs[i];
            Id updatedFacultyID = updatedFacultyIDs[i];
            if (oldFacultyToAfflMap.keySet().contains(outdatedFacultyID)) {
                Affiliation__c oldAffl = oldFacultyToAfflMap.get(outdatedFacultyID);
                oldAffl.Contact__c = updatedFacultyID;
            } else {
                if (mapNewFacultyIdToNewCourseOffering.keySet().contains(updatedFacultyID)
                    && mapNewFacultyIdToNewCourseOffering.get(updatedFacultyID) != null) {
                    
                    Course_Offering__c offering = mapNewFacultyIdToNewCourseOffering.get(updatedFacultyID);
                    String contactAccountKey = offering.Faculty__c + '' + offering.Course__r.Account__c;
                    // Is the Affiliation already being inserted? If so, do not insert a duplicate.
                    if (affiliationsToInsertByContactAccountString.containsKey(contactAccountKey)) {
                        continue;
                    }

                    Affiliation__c newAffl = createAffiliationFromCourseOffering(offering);
                    affiliationsToInsertByContactAccountString.put(contactAccountKey, newAffl);
                }
            }
        }

        afflsWithContact.addAll(affiliationsToInsertByContactAccountString.values());
        return afflsWithContact;
    }

    /*******************************************************************************************************
    * @description Creates and returns a new Faculty Affiliation record from the given Course Offering.
    * @return Affiliation__c The new Faculty Affiliation record.
    ********************************************************************************************************/
    private Affiliation__c createAffiliationFromCourseOffering(Course_Offering__c offering) {
        return new Affiliation__c(Contact__c = offering.Faculty__c,
                                  Account__c = offering.Course__r.Account__c,
                                  Role__c = 'Faculty',
                                  StartDate__c = offering.Term__r.Start_Date__c,
                                  EndDate__c = offering.Term__r.End_Date__c
        );
    }

   /*******************************************************************************************************
    * @description Updates each Course Enrollment from the old Faculty member to the new Faculty member. A Faculty
    * member should not be at the same time teaching and attending a course if the course connection is disabled. 
    * However, it still allows users to replace the course enrollment with the new faculty member.
    ********************************************************************************************************/
    private void updateEnrollments(List<ID> outdatedFacultyIDs, List<ID> updatedFacultyIDs, Set<Id> offsWithChangedFaculty, DmlWrapper dmlWrapper) {      
        List<Course_Enrollment__c> newEnrolls = new List<Course_Enrollment__c>();
        List<Course_Enrollment__c> oldEnrolls = [SELECT Affiliation__c, Account__c, Course_Offering__c, Course_Offering__r.Faculty__c
                                                 FROM Course_Enrollment__c 
                                                 WHERE Contact__c in :outdatedFacultyIDs
                                                    AND Course_Offering__c in :offsWithChangedFaculty];
        for (Course_Enrollment__c enroll : oldEnrolls){
            newEnrolls.add(new Course_Enrollment__c(Contact__c = enroll.Course_Offering__r.Faculty__c, Account__c = enroll.Account__c,
                                                        Course_Offering__c = enroll.Course_Offering__c,
                                                        Affiliation__c = enroll.Affiliation__c));
            
        }

        dmlWrapper.objectsToDelete.addAll((List<SObject>)oldEnrolls);
        dmlWrapper.objectsToInsert.addAll((List<SObject>)newEnrolls);
    }

   /*******************************************************************************************************
    * @description Updates each Course Connection to mark old as not Primary and new as Primary. A Faculty
    * member may already have a Course Connection that may need to be marked primary or may need to be created
    * if a connection for the Faculty member does not exist.
    ********************************************************************************************************/
    @testVisible
    private void updateConnectionsOnFacultyChange(List<ID> outdatedFacultyIDs, List<ID> updatedFacultyIDs, Set<Id> offsWithChangedFaculty, List<SObject> objectsToInsert, List<SObject> objectsToUpdate) {
        Id facultyRecordTypeId = UTIL_Describe.getFacultyConnectionRecType();
        Map<Id, Map<Id, Course_Enrollment__c>> offeringFacultyConnIds = getOfferingIdFacultyIdConnection(offsWithChangedFaculty, facultyRecordTypeId);
        String queryString = 'SELECT Id, Affiliation__c, Account__c, Course_Offering__c, Primary__c FROM Course_Enrollment__c';
        queryString += ' WHERE Contact__c IN :outdatedFacultyIDs';
        queryString += ' AND Course_Offering__c IN :offsWithChangedFaculty';
        //Record type of course enrollment not in the package
        if (UTIL_Describe.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId') && facultyRecordTypeId != null) {
            queryString += ' AND RecordTypeId = :facultyRecordTypeId';
        }
        List<Course_Enrollment__c> oldConns = Database.query(queryString);

        for (Integer i = 0; i < oldConns.size(); i++) {
            if (offeringFacultyConnIds.containsKey(oldConns[i].Course_Offering__c)
                    && offeringFacultyConnIds.get(oldConns[i].Course_Offering__c) != null
                    && offeringFacultyConnIds.get(oldConns[i].Course_Offering__c).containsKey(updatedFacultyIDs[i])) {
                
                Course_Enrollment__c existingConn = offeringFacultyConnIds.get(oldConns[i].Course_Offering__c).get(updatedFacultyIDs[i]);
                if (!existingConn.Primary__c) {
                    // Current Course Connection exists on Course Offering with Contact, mark as Primary
                    existingConn.Primary__c = true;
                    objectsToUpdate.add((SObject)existingConn);
                }
            } else {
                // No current Course Connection exists on Course Offering with Contact, create a new one
                Course_Enrollment__c conn = new Course_Enrollment__c(Contact__c = updatedFacultyIDs[i], Account__c = oldConns[i].Account__c,
                                                                        Course_Offering__c = oldConns[i].Course_Offering__c,
                                                                        Affiliation__c = oldConns[i].Affiliation__c,
                                                                        Primary__c = true);
                if (UTIL_Describe.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
                    conn.put('RecordTypeId', facultyRecordTypeId);
                }
                objectsToInsert.add((SObject)conn);
            }

            Course_Enrollment__c oldConn = oldConns[i];
            if (oldConn.Primary__c) {
                oldConn.Primary__c = false;
                objectsToUpdate.add((SObject)oldConn);
            }
        }
    }

   /*******************************************************************************************************
    * @description Updates or adds a Course Connection for each added to a Course Offering. A Faculty
    * member may already have a Course Connection that may need to be marked primary or may need to be created
    * if a Course Connection for the Faculty member does not exist.
    ********************************************************************************************************/
    @testVisible
    private void updateConnectionsOnFacultyAdd(List<Course_Offering__c> courseOfferings, List<SObject> objectsToInsert, List<SObject> objectsToUpdate) {
        Id facultyRecordTypeId = UTIL_Describe.getFacultyConnectionRecType();

        Set<Id> offIds = (new Map<Id,Course_Offering__c>(courseOfferings)).keySet();

        Map<Id, Map<Id, Course_Enrollment__c>> offeringFacultyConnIds = getOfferingIdFacultyIdConnection(offIds, facultyRecordTypeId);

        for (Course_Offering__c offering : courseOfferings){
            if (offeringFacultyConnIds.containsKey(offering.Id) &&
                offeringFacultyConnIds.get(offering.Id).containsKey(offering.Faculty__c)) {
                
                Course_Enrollment__c existingConn = offeringFacultyConnIds.get(offering.Id).get(offering.Faculty__c);
                if (!existingConn.Primary__c) {
                    // Current Course Connection exists on Course Offering with Contact, mark as Primary
                    objectsToUpdate.add(new Course_Enrollment__c(Id = existingConn.Id, Primary__c = true));
                }
            } else {
                // No current Course Connection exists on Course Offering with Contact, create a new one
                Course_Enrollment__c conn = new Course_Enrollment__c(Contact__c = offering.Faculty__c,
                                                                        Account__c = offering.Course__r.Account__c,
                                                                        Course_Offering__c = offering.Id,
                                                                        Primary__c = true
                                                                        );
                if (UTIL_Describe.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
                    conn.put('RecordTypeId', facultyRecordTypeId);
                }
                objectsToInsert.add(conn);
            }
        }
    }

    /*******************************************************************************************************
    * @description Updates each Course Connection as not Primary for all Course Connections tied to Faculty 
    * that are no longer the Primary Faculty for the given Course Offerings.
    ********************************************************************************************************/
    @testVisible
    private void updateConnectionsOnFacultyRemove(List<ID> removedFacultyIDs, Set<Id> offsWithRemovedFaculty, List<SObject> objectsToUpdate) {
        List<Course_Enrollment__c> oldConns = [SELECT Id
                                                      , Course_Offering__c
                                                      , Primary__c
                                               FROM Course_Enrollment__c
                                               WHERE Contact__c IN :removedFacultyIDs
                                               AND Course_Offering__c IN :offsWithRemovedFaculty];

        for (Course_Enrollment__c conn : oldConns) {
            if (conn.Primary__c && offsWithRemovedFaculty.contains(conn.Course_Offering__c)) {
                conn.Primary__c = false;
                objectsToUpdate.add(conn);
            }
        }
    }

   /*******************************************************************************************************
    * @description Deletes the Affiliations that had been automatically created from the Course Enrollments with
    * assigned Faculty members but only if those Affiliations would no longer have any Course Enrollments
    * linked to them. Also deletes the Course Enrollments themselves.
    ********************************************************************************************************/
    private void deleteAfflsEnrolls(List<ID> removedFacultyIds, Set<Id> offsWithRemovedFaculty, DmlWrapper dmlWrapper) {
        Set<Id> afflIds = new Set<Id>();
        Set<Id> afflsToDeleteIds = new Set<Id>();

        List<Course_Enrollment__c> oldEnrolls = [select Id, Affiliation__c from Course_Enrollment__c where Contact__c in :removedFacultyIds and Course_Offering__c in :offsWithRemovedFaculty];

        for (Course_Enrollment__c enroll : oldEnrolls){
            afflIds.add(enroll.Affiliation__c);
        }

        Map<Id, Affiliation__c> affls = new Map<Id, Affiliation__c>([select Id, (select Id from Course_Enrollment__r where Course_Offering__c not in :offsWithRemovedFaculty) from Affiliation__c where Id in :afflIds]);

        for (Course_Enrollment__c enroll : oldEnrolls) {
            if (affls.get(enroll.Affiliation__c) != null) {
                if (affls.get(enroll.Affiliation__c).Course_Enrollment__r.size() == 0) {
                    afflsToDeleteIds.add(enroll.Affiliation__c);
                }
            }
        }

        if (afflsToDeleteIds.size() > 0) {
            dmlWrapper.objectsToDelete.addAll((List<SObject>)[select Id from Affiliation__c where Id in :afflsToDeleteIds]);
        }
        dmlWrapper.objectsToDelete.addAll((List<SObject>)oldEnrolls);
    }

   /*******************************************************************************************************
    * @description Returns a map with the Contact ID of each faculty member as the key, and all its Affiliations
    * as the values.
    ********************************************************************************************************/
    @testVisible
    private Map<ID, List<Affiliation__c>> getAfflsForContact(List<ID> newFacultyIDs) {
        UTIL_Debug.debug('****Number of newly assigned faculty: ' + newFacultyIDs.size());
        //Find all Affls for all Faculty members in the trigger.
        Map<ID, List<Affiliation__c>> facultyIDtoAffls = new Map<ID, List<Affiliation__c>>();
        List<Affiliation__c> affls = [SELECT Id, Account__c, Contact__c 
                                      FROM Affiliation__c 
                                      WHERE Contact__c IN :newFacultyIDs 
                                      ORDER BY Contact__c];
        UTIL_Debug.debug('****Number of affls for existing faculty: ' + affls.size());

        if (affls.size() > 0) {
            //Set initial values, to compare against
            Affiliation__c affl = affls[0];
            ID contactID = affls[0].Contact__c;
            List<Affiliation__c> facultyAffls = new Affiliation__c[] {affl};
            facultyIDtoAffls.put(contactID, facultyAffls);

            //Iterate through the rest of the affiliations
            for (Integer i = 1; i < affls.size(); i++) {
                if (affls[i].Contact__c == contactID) {
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
    * @description Returns a map with Course Offering Id as key and a value as a Map of Contact Id as
    * key with the corresponding Course Connection as value.
    ********************************************************************************************************/
    private Map<Id, Map<Id, Course_Enrollment__c>> getOfferingIdFacultyIdConnection(Set<Id> offeringIds, Id facultyRecordTypeId) {
        // Map with Course Offering Id as key and a value as a Map of Contact Id as key with the corresponding Course Connection as value
        Map<Id, Map<Id, Course_Enrollment__c>> connToOfferingIdMap = new Map<Id, Map<Id, Course_Enrollment__c>>();
        String queryString = 'SELECT Id, Course_Offering__c, Contact__c, Primary__c FROM Course_Enrollment__c WHERE Course_Offering__c IN :offeringIds';
        if (UTIL_Describe.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId') && facultyRecordTypeId != null) {
            queryString += ' AND RecordTypeId = :facultyRecordTypeId';
        }
        List<Course_Enrollment__c> conns = Database.query(queryString);
        UTIL_Debug.debug('****Number of Faculty Course Connections for Course Offerings: ' + conns.size());

        for (Course_Enrollment__c conn : conns){
            if (!connToOfferingIdMap.containsKey(conn.Course_Offering__c)) {
                connToOfferingIdMap.put(conn.Course_Offering__c, new Map<Id, Course_Enrollment__c>());
            }
            connToOfferingIdMap.get(conn.Course_Offering__c).put(conn.Contact__c, conn);
        }

        return connToOfferingIdMap;
    }

   /*******************************************************************************************************
    * @description Determines whether an Affiliation to the Account the Course Offering belongs to already
    * exists for each faculty member. Will return null if no Affiliation exists.
    * @return Affiliation__c Affiliation to the Account or null
    ********************************************************************************************************/
    @testVisible
    private Affiliation__c affiliationToAccount(Course_Offering__c offering, Map<ID, List<Affiliation__c>> facultyIDtoAffls) {
        List<Affiliation__c> facultyMemberAffls = facultyIDtoAffls.get(offering.Faculty__c);
        if (facultyMemberAffls != null && facultyMemberAffls.size() > 0) {
            for (Affiliation__c affl : facultyMemberAffls) {
                if (affl.Account__c == offering.Course__r.Account__c) {
                    return affl;
                }
            }
        }

        return null;
    }
}
