/*
    Copyright (c) 2016, Salesforce.org
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
* @date 2016
* @group Course Enrollments
* @group-content ../../ApexDocContent/CourseEnrollments.htm
* @description Automatically populates the Academic Program field in a Course Enrollment.
*/
public with sharing class CENR_AcademicProgram_TDTM extends TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description Updates key affiliation lookups on contact, and any other primary affiliation of the new type.
    * @param listNew the list of Course Enrollments from trigger new. 
    * @param listOld the list of Coursen Enrollments from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Course Enrollments.
    * @return dmlWrapper
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    
        DmlWrapper dmlWrapper = new DmlWrapper();
        List<Course_Enrollment__c> newCourseEnrollments = (List<Course_Enrollment__c>)newlist;
        List<Course_Enrollment__c> oldCourseEnrollments = (List<Course_Enrollment__c>)oldList; 
        
        Boolean affiliationIsEnabled = checkAffiliationEnabled(); 
            
        if (affiliationIsEnabled) {
            
            if (triggerAction == TDTM_Runnable.Action.BeforeInsert || 
                triggerAction == TDTM_Runnable.Action.BeforeUpdate) 
            {
                handleBeforeTrigger(newCourseEnrollments, oldCourseEnrollments, triggerAction); 
            }
         }
            
         return dmlWrapper;
    }
   	
    private Boolean checkAffiliationEnabled() {
        return UTIL_CustomSettingsFacade.getSettings().Populate_Affiliation_on_Couse_Connection__c;
    }
    
    private void handleBeforeTrigger(List<Course_Enrollment__c> newCourseEnrollments, List<Course_Enrollment__c> oldCourseEnrollments, 
                                     TDTM_Runnable.Action triggerAction) {
        Set<Id> pEnrollIDsToQuery = new Set<Id>();
        List<Program_Enrollment__c> pEnrollments = new List<Program_Enrollment__c>(); 
        //Map<Id, Program_Enrollment__c> pEnrollmentsMap = new Map<Id, Program_Enrollment__c>(); 
        if (newCourseEnrollments.size() > 0 && newCourseEnrollments != NULL) {
            for (Integer i = 0; i < newCourseEnrollments.size(); i++) {
                Course_Enrollment__c enroll = (Course_Enrollment__c)newCourseEnrollments[i];
                //Get the ID of each parent Program Enrollment
                if (enroll.Program_Enrollment__c != null) {
                    pEnrollIDsToQuery.add(enroll.Program_Enrollment__c);
                }     
            }
            
            if (pEnrollIDsToQuery.size() > 0) {
                pEnrollments = queryProgramEnrollments(pEnrollIDsToQuery); 
            }
            
            for (Integer i = 0; i < newCourseEnrollments.size(); i++) {
                Map<Id, Program_Enrollment__c> pEnrollmentsMap = new Map<Id, Program_Enrollment__c>(pEnrollments); 
                Course_Enrollment__c enroll = (Course_Enrollment__c)newCourseEnrollments[i];
                
                
                //BEFORE INSERT
                if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
                    processBeforeInsert(enroll, pEnrollmentsMap); 
                }
                
                //BEFORE UPDATE
                if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
                    Course_Enrollment__c oldEnroll = (Course_Enrollment__c)oldCourseEnrollments[i];
                    processBeforeUpdate(enroll, oldEnroll, pEnrollmentsMap); 
                }
            }
        }
        
        
        
    }
    private List<Program_Enrollment__c> queryProgramEnrollments(Set<Id> pEnrollIDsToQuery) {
        //Query the parent Account (Academic Program) of each Program Enrollment, since that field
        //wasn't in the trigger for being two levels up.
        List<Program_Enrollment__c> pEnrollments = [SELECT Account__c, Affiliation__c 
                                                            FROM Program_Enrollment__c 
                                                            WHERE Account__c != NULL AND ID IN :pEnrollIDsToQuery];
        return pEnrollments; 
    }
    
    private void processBeforeInsert(Course_Enrollment__c enroll, Map<Id, Program_Enrollment__c> pEnrollmentsMap) {
        if(enroll.Program_Enrollment__c != null) {
            Program_Enrollment__c pEnroll = pEnrollmentsMap.get(enroll.Program_Enrollment__c);
                if (pEnroll != null) {
                    enroll.Account__c = pEnroll.Account__c; 
                    enroll.Affiliation__c = pEnroll.Affiliation__c; 
                }
        }
    }
    
    private void processBeforeUpdate(Course_Enrollment__c enroll, Course_Enrollment__c oldEnroll,
                                     Map<Id, Program_Enrollment__c> pEnrollmentsMap) {
        if(oldEnroll.Program_Enrollment__c == null && enroll.Program_Enrollment__c != null) {
            Program_Enrollment__c pEnroll = pEnrollmentsMap.get(enroll.Program_Enrollment__c);
                if (pEnroll != null) {
                    enroll.Account__c = pEnroll.Account__c;
                    enroll.Affiliation__c = pEnroll.Affiliation__c; 
                }
        }
    }
}