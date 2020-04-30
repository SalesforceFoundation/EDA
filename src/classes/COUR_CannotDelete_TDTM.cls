/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group Course
* @group-content ../../ApexDocContent/Course.htm
* @description Stops a Course from being deleted if it has any Course Offering or Plan Requirement child records.
*/
public with sharing class COUR_CannotDelete_TDTM extends TDTM_Runnable {
    /*******************************************************************************************************
    * @description Get the setting of preventing Course deletion
    */
    private static Boolean enabledPreventCourseDeletion = UTIL_CustomSettingsFacade.getSettings().Prevent_Course_Deletion__c;
    
    /*******************************************************************************************************
    * @description Stops a Course from being deleted if it has any Course Offering 
    * or Plan Requirement child records.
    * @param listNew the list of Courses from trigger new.
    * @param listOld the list of Courses from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Courses
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        if (!COUR_CannotDelete_TDTM.enabledPreventCourseDeletion) {
            return new DmlWrapper(); 
        }

        Map<Id, Course__c> oldMap = new Map<Id, Course__c>((List<Course__c>)oldList);

        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            for (Course__c course : [SELECT ID,
                        (SELECT ID FROM Course__c.Course_Offerings__r LIMIT 1),
                        (SELECT ID FROM Course__c.Plan_Requirements__r LIMIT 1)
                        FROM Course__c
                        WHERE ID IN :oldlist])
            {
                if (this.hasChildRecords(course)) {
                    Course__c courseInContext = oldmap.get(course.ID);
                    courseInContext.addError(Label.CannotDelete);
                }
            }
        }

    return new DmlWrapper();
    }

    /*******************************************************************************************************
    * @description Evaluates whether the Course has any child related records.
    * @param course is the current Course record.
    * @return Boolean.
    ********************************************************************************************************/
    @testVisible
    private Boolean hasChildRecords(Course__c course) {
        return (!course.Course_Offerings__r.isEmpty() || !course.Plan_Requirements__r.isEmpty());
    }
}
