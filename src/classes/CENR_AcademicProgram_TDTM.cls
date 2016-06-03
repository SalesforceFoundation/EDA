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
* @group CourseEnrollments
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
         
         Set<Id> pEnrollIDsToQuery = new Set<Id>();
         
         if(newlist != null && newlist.size() > 0) {
            
            for (Integer i = 0; i < newlist.size(); i++) {
                Course_Enrollment__c enroll = (Course_Enrollment__c)newlist[i];
                
                //BEFORE INSERT AND BEFORE UPDATE
                if(triggerAction == TDTM_Runnable.Action.BeforeInsert 
                || triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
                    //set Academic Program if we can get it through Program Enrollment
                    if(enroll.Program_Enrollment__c != null) {
                        pEnrollIDsToQuery.add(enroll.Program_Enrollment__c);
                    }
                }
            }
            
            List<Program_Enrollment__c> pEnrollments = [select Account__c from Program_Enrollment__c 
                                                    where Account__c != null and ID in :pEnrollIDsToQuery];

            Map<Id, Program_Enrollment__c> pEnrollmentsMap = new Map<Id, Program_Enrollment__c>(pEnrollments); 
            
            for (Integer i = 0; i < newlist.size(); i++) {
                Course_Enrollment__c enroll = (Course_Enrollment__c)newlist[i];
                
                //BEFORE INSERT
                if(triggerAction == TDTM_Runnable.Action.BeforeInsert) {
                    //set Academic Program if we can get it through Program Enrollment
                    if(enroll.Program_Enrollment__c != null) {
                        Program_Enrollment__c pEnroll = pEnrollmentsMap.get(enroll.Program_Enrollment__c);
                        enroll.Account__c = pEnroll.Account__c; 
                    }
                }
                
                //BEFORE UPDATE
                if(triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
                    Course_Enrollment__c oldEnroll = (Course_Enrollment__c)oldList[i];
                    //set Academic Program if we can get it through Program Enrollment
                    if(oldEnroll.Program_Enrollment__c == null && enroll.Program_Enrollment__c != null) {
                        Program_Enrollment__c pEnroll = pEnrollmentsMap.get(enroll.Program_Enrollment__c);
                        enroll.Account__c = pEnroll.Account__c;
                    }
                }
            }
         }
         return dmlWrapper;
    }
}