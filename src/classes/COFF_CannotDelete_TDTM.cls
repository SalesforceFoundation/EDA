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
* @group Course Offering
* @group-content ../../ApexDocContent/CourseOfferings.htm
* @description This class prevents the Course Offering record from being deleted if it has any associated Term Grades. 
*/
public with sharing class COFF_CannotDelete_TDTM extends TDTM_Runnable{
	/*******************************************************************************************************
    * @description Stops a Course Offering from being deleted if it has any associated Term Grades.  
    * @param listNew the list of Course Offering from trigger new. 
    * @param listOld the list of Course Offering from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).  
    * @param objResult the describe for Course Offering
    * @return dmlWrapper.  
    ********************************************************************************************************/
     public override DmlWrapper run(List<SObject> newList, List<SObject> oldList, 
     TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        Map<ID, SObject> oldmap = new Map<ID, SObject>(oldlist);
         
        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            for(Course_Offering__c co : [SELECT Id, 
                                        (SELECT Id FROM Term_Grades__r LIMIT 1)
                                        FROM Course_Offering__c WHERE Id in : oldlist]) {
				    if(co.Term_Grades__r.size() > 0) {
					    Course_Offering__c courseOfferingInContext = (Course_Offering__c)oldmap.get(co.Id); 
              courseOfferingInContext.addError(Label.CannotDelete);
            }   
          }
        }
      return new DmlWrapper();
    }
}