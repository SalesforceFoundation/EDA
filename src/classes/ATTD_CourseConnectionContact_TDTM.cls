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
* @group Attendance Events
* @group-content ../../ApexDocContent/AttendanceEvents.htm
* @description Makes sure that linked course connection's contact matches contact lookup field
*/
public with sharing class ATTD_CourseConnectionContact_TDTM extends TDTM_Runnable {
    /*******************************************************************************************************
    * @description Makes sure that linked course connection's contact matches contact lookup field
    * @param listNew the list of Attendance Events from trigger new. 
    * @param listOld the list of Attendance Events from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Attendance Events 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        DmlWrapper dmlWrapper = new DmlWrapper();

        boolean recursionFlag = TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.ATTD_CourseConnectionContact_TDTM);

        Map<ID, SObject> newmap = new Map<ID, SObject>(newlist);
        
        if (triggerAction == TDTM_Runnable.Action.AfterInsert
                || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                    
            if (!recursionFlag) {
                for (Attendance_Event__c attd : [SELECT Id,
                                                        Contact__c,
                                                        Course_Connection__c,
                                                        Course_Connection__r.Contact__c
                                                FROM Attendance_Event__c 
                                                WHERE Id IN :newlist]) {
                    if (attd.Course_Connection__c != null
                        && attd.Course_Connection__r.Contact__c != null
                        && attd.Course_Connection__r.Contact__c != attd.Contact__c) {
                        if (attd.Contact__c == null) {
                            //Auto-populdate contact lookup field on attendance event
                            attd.Contact__c = attd.Course_Connection__r.Contact__c;
                            dmlWrapper.objectsToUpdate.add(attd);
                        } else {
                            //If contact not null, throw an error and guide users to correct their data
                            Attendance_Event__c attdInContext = (Attendance_Event__c)newmap.get(attd.ID);
                            attdInContext.Contact__c.addError(Label.AttendanceCourseConnectionContactMismatch);
                        }
                    }
                }
            }     
        }
        
        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        
        //Reset recursion flag
        dmlWrapper = null;
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ATTD_CourseConnectionContact_TDTM, false);

        return new DmlWrapper();
    }
}