/*
    Copyright (c) 2019, Salesforce.org
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
* @date 2019
* @group Course Offerings
* @group-content ../../ApexDocContent/CourseOfferings.htm
* @description This class prevents changes to the Course lookup field on 
* Course Offering if there are Term Grades associated with it.
*/
public with sharing class COFF_PreventUpdate_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description This class prevents changes to the Course lookup field on 
    * Course Offering if there are Term Grades associated with it.
    * @param listNew the list of Course Connections from trigger new.
    * @param listOld the list of Course Connections from trigger old.
    * @param triggerAction which trigger event (BeforeUpdate).
    * @param objResult the describe for Course Offerings.
    * @return dmlWrapper
    ********************************************************************************************************/
    
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        Map<ID, sObject> newMap = new Map<ID, sObject>(newList);
        
        if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
            for (Course_Offering__c courseOffering: [SELECT Id, Course__c, (SELECT Id FROM Term_Grades__r LIMIT 1) FROM Course_Offering__c WHERE Id IN :newlist]) {
                
                Boolean courseChanged = (courseOffering.Course__c != ((Course_Offering__c)newMap.get(courseOffering.Id)).Course__c);
                Boolean hasTermGrades = (courseOffering.Term_Grades__r.size() > 0);

                // Prevent changes to Course if there are Term Grades assciated with the record 

                if (courseChanged && hasTermGrades) {
                    Course_Offering__c courseOfferingInContext = ((Course_Offering__c)newMap.get(courseOffering.Id));
                    courseOfferingInContext.addError(Label.CannotChangeCourse);                               
                }
            }           
        }          
        return new DmlWrapper();    
    }

}