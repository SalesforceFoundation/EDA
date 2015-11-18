/*
    Copyright (c) 2015, Salesforce.com Foundation
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
* @group Term
* @description Copies start and end date from a Term to all children Course Offerings that don't 
* have values in those fields. 
*/
public with sharing class TERM_CourseOff_TDTM extends TDTM_Runnable {

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
        
        //only pertinent for after update, because course offerings cannot be created without a parent term
        if(oldlist != null && oldlist.size() > 0 && triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            List<Term__c> termsWithNewDates = new List<Term__c>();
            
            //find all the terms that didn't have start or end date and now have it
            for (integer i=0; i<newlist.size(); i++) {
                Term__c newTerm = (Term__c)newlist[i];
                Term__c oldTerm = (Term__c)oldlist[i];
                
                if((newTerm.Start_Date__c != null && oldTerm.Start_Date__c == null) || 
                (newTerm.End_Date__c != null && oldTerm.End_Date__c == null)) {
                    termsWithNewDates.add(newTerm);
                }
            }
 
            //find all children course offerings for all these terms
            List<Term__c> termsWithCourseOffs = [select Start_Date__c, End_Date__c, (select Start_Date__c, 
            End_Date__c from Course_Offerings__r) from Term__c where ID IN :termsWithNewDates];
            
            List<SObject> coffsToUpdate = new List<SObject>();
            
            for(Term__c parentTerm : termsWithCourseOffs) {
                List<Course_Offering__c> childCoffs = parentTerm.Course_Offerings__r;
                for(Course_Offering__c childOff : childCoffs) {
                    Boolean childOffModified = false;
		            //in all those cases where the term has a start date but the children course offerings don't,
		            //copy the date from the term.
		            if(parentTerm.Start_Date__c != null && childOff.Start_Date__c == null) {
		                childOff.Start_Date__c = parentTerm.Start_Date__c;
		                childOffModified = true;
		            }
		            //in all those cases where the term has an end date but the children course offerings don't,
		            //copy the date from the term.
                    if(parentTerm.End_Date__c != null && childOff.End_Date__c == null) {
                        childOff.End_Date__c = parentTerm.End_Date__c;
                        childOffModified = true;
                    }
                    
                    if(childOffModified) {
                        coffsToUpdate.add(childOff);
                    }
                }
            }
            dmlWrapper.objectsToUpdate.addAll(coffsToUpdate);
        }
        return dmlWrapper;
    }
}