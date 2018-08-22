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
* @group Accounts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Stops a Contact from being deleted if it has any Affiliation, 
* Program Enrollment or Course Enrollment children.
*/
public with sharing class CON_CannotDelete_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Stops a Contact from being deleted if it has any Affiliation, 
    * Program Enrollment or Course Enrollment children.
    * @param listNew the list of Contacts from trigger new. 
    * @param listOld the list of Contacts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Accounts 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        Map<ID, SObject> oldmap = new Map<ID, SObject>(oldlist);
        
        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
                        
            for (Contact c : [select ID, (select ID from Contact.Affl_Accounts__r LIMIT 1), 
                                         (select ID from Contact.Program_Enrollments__r LIMIT 1), 
                                         (select ID from Contact.Student_Course_Enrollments__r LIMIT 1) 
                                         from Contact where ID in :oldlist]) {
                
                if(c.Affl_Accounts__r.size() > 0 || c.Program_Enrollments__r.size() > 0 
                || c.Student_Course_Enrollments__r.size() > 0) {

                    Contact contactInContext = (Contact)oldmap.get(c.ID);
                    contactInContext.addError(Label.CannotDelete);
                }
            }     
        }
        
        return new DmlWrapper();
    }
}