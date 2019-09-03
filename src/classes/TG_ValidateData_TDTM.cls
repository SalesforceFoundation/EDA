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
* @group
* @group-content ../../ApexDocContent/TermGrades.htm
* @description This class ensures that the chosen Course Connection matches the 
* chosen Contact and Course Offering. It attempts to populate the missing data based
* on the data provided.
*/
public with sharing class TG_ValidateData_TDTM extends TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description This class ensures that the chosen Course Connection matches the 
    * chosen Contact and Course Offering. It attempts to populate the missing data based
    * on the data provided.
    * @param newlist the list of Accounts from trigger new.
    * @param oldlist the list of Accounts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, BeforeUpdate).
    * @param objResult the describe for Term Frade
    * @return NULL.
    ********************************************************************************************************/
    
    public override DmlWrapper run(List<SObject> newList, List<SObject> oldList, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    
        if (triggerAction == TDTM_Runnable.Action.BeforeInsert || triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
        
            List<Term_Grade__c> findCourseConnectionList = new List<Term_Grade__c>();
            List<Term_Grade__c> checkCourseContactList = new List<Term_Grade__c>();
            List<Term_Grade__c> findContactList = new List<Term_Grade__c>();
            List<Term_Grade__c> findCourseOfferingList = new List<Term_Grade__c>();
            List<Term_Grade__c> findContactCourseOfferingList = new List<Term_Grade__c>();
            
            List<Id> termGradeContacts = new List<Id>();
            List<Id> termGradeCourseOffering = new List<Id>();
            Map<Id, List<Term_Grade__c>> contactTermGradeMap = new Map<Id, List<Term_Grade__c>>();
            
            for (SObject so : newlist) {
            
                Term_Grade__c termGrade = (Term_Grade__c)so;
        
                // No Course Connection, Contact and Course Offering
        
                if (termGrade.Course_Connection__c == NULL && termGrade.Contact__c == NULL && termGrade.Course_Offering__c == NULL) {
        
                    termGrade.addError(Label.NoFieldsPopulated);
        
                }
        
                // Only Contact is populated
        
                else if (termGrade.Course_Connection__c == NULL && termGrade.Contact__c != NULL && termGrade.Course_Offering__c == NULL) {
        
                    termGrade.addError(Label.OnlyContactPopulated);
        
                }
        
                // Only Course Offering is populated
        
                else if (termGrade.Course_Connection__c == NULL && termGrade.Contact__c == NULL && termGrade.Course_Offering__c != NULL) {
        
                    termGrade.addError(Label.OnlyCourseOfferingPopulated);
        
                }
        
                // Contact and Course Offering is populated with no Course Connection

                else if (termGrade.Course_Connection__c == NULL && termGrade.Contact__c != NULL && termGrade.Course_Offering__c != NULL) {
            
                    findCourseConnectionList.add(termGrade);                    
                    termGradeContacts.add(termGrade.contact__c);
                    termGradeCourseOffering.add(termGrade.course_offering__c);
                    
                    if(contactTermGradeMap.containsKey(termGrade.contact__c)) {

                        contactTermGradeMap.get(termGrade.contact__c).add(termGrade);

                    }else {

                        contactTermGradeMap.put(termGrade.contact__c, new List<Term_Grade__c>{termGrade});
                    }

                }
        
                // Course Connection, Contact and Course Offering are populated
        
                else if (termGrade.Course_Connection__c != NULL && termGrade.Contact__c != NULL && termGrade.Course_Offering__c != NULL) {

                    checkCourseContactList.add(termGrade);
                    
                }
        
                // Course Connection, Course Offering are populated with no Contact
        
                else if (termGrade.Course_Connection__c != NULL && termGrade.Contact__c == NULL && termGrade.Course_Offering__c != NULL) {
            
                    findContactList.add(termGrade);
                    
                }
        
                // Course Connection, Contact is populated with no COurse Offering
        
                else if (termGrade.Course_Connection__c != NULL && termGrade.Contact__c != NULL && termGrade.Course_Offering__c == NULL) {
            
                    findCourseOfferingList.add(termGrade); 
                }
        
                // Only Course Connection is populated with no Contact and Course Offering
        
                else if (termGrade.Course_Connection__c != NULL && termGrade.Contact__c == NULL && termGrade.Course_Offering__c == NULL) {
            
                    findContactCourseOfferingList.add(termGrade); 
        
                }
               
            }
        
        
            if (findCourseConnectionList != NULL && findCourseConnectionList.size() > 0) {
            
                findCourseConnection(findCourseConnectionList, termGradeContacts, termGradeCourseOffering, contactTermGradeMap);
        
            }
        
        
            if (checkCourseContactList != NULL && checkCourseContactList.size() > 0) {
            
                validateCourseContact(checkCourseContactList);
        
            }       
        
        
            if (findContactList != NULL && findContactList.size() > 0) {
                                
                findContact(findContactList);
            }
        
        
            if (findCourseOfferingList != NULL && findCourseOfferingList.size() > 0) {
        
                findCourseOffering(findCourseOfferingList);     
        
            }
        
        
            if (findContactCourseOfferingList != NULL && findContactCourseOfferingList.size() > 0) {
            
                findContactCourseOffering(findContactCourseOfferingList);
        
            }
        
       }
    
        return NULL;

    }
    
    /*******************************************************************************************************
    * @description Queries for a Course Connection for the Term Grade based on the Contact and Course Offering.
    * Updates the Term Grade if a Course Connection is found and throws an error if no Course Connection is found
    * or more than 1 Course Connections are found.
    * @param termGrades A List of Term Grades with no Course Connection.
    ********************************************************************************************************/
    
    private void findCourseConnection(List<Term_Grade__c> termGrades, List<Id> termGradeContacts, List<Id> termGradeCourseOffering, Map<Id, List<Term_Grade__c>> contactTermGradeMap) {
            
        Map<Id, List<Term_Grade__c>> courseOfferTermGrade = new Map<Id, List<Term_Grade__c>>();
        Map<Term_Grade__c, List<Course_Enrollment__c>> termGradeEnrollmentMap = new Map<Term_Grade__c, List<Course_Enrollment__c>>();
        Map<Term_Grade__c, List<Course_Enrollment__c>> termGradeEnrollmentTermMap = new Map<Term_Grade__c, List<Course_Enrollment__c>>();
    
        for (Course_Enrollment__c eachEnrollment: [SELECT Id, Contact__c, Course_Offering__c FROM Course_Enrollment__c WHERE Contact__c IN:termGradeContacts AND Course_Offering__c IN:termGradeCourseOffering]) { 
        
            if (eachEnrollment != NULL){ 
                
                for(Term_Grade__c tg : contactTermGradeMap.get(eachEnrollment.Contact__c)) {
            
                    if (eachEnrollment.course_offering__c == tg.course_offering__c) {
                
                        if(termGradeEnrollmentMap.containsKey(tg)) {

                            termGradeEnrollmentMap.get(tg).add(eachEnrollment);

                        }else {

                            termGradeEnrollmentMap.put(tg, new List<Course_Enrollment__c>{eachEnrollment});
                        }
                
                    }  
            
                }    
            }          
        }
        
        Set<Term_grade__c> allTermGrades = new Set<Term_grade__c>();
        allTermGrades.addAll(termGrades);
                     
        if (!termGradeEnrollmentMap.isEmpty()) {
        
            Set<Term_grade__c> termGradeWEnrollments = new Set<Term_grade__c>();
                
            termGradeWEnrollments = termGradeEnrollmentMap.KeySet();
            
        
            for (Term_grade__c each: termGradeWEnrollments) {
        
                if (allTermGrades.contains(each)) {
            
                    allTermGrades.remove(each);    
            
                }
        
            }
        }  
        
        if (allTermGrades.size() > 0) {
        
            for (Term_grade__c each: allTermGrades) {
        
                each.addError(Label.NoCourseConnection);
        
            }
        } 
        
        for (Term_Grade__c tg : termGradeEnrollmentMap.keySet()) {
                       
            if (termGradeEnrollmentMap.get(tg).size() == 1) {
            
                tg.Course_Connection__c = termGradeEnrollmentMap.get(tg)[0].Id;    
            
            } else {
                            
                tg.addError(Label.MultipleCourseConnection);
                                   
            }    
        }
    
        
    }    
    
    /*******************************************************************************************************
    * @description Checks if the Contact and Course Connection of the Term Grade matches with the
    * Contact and Course Offering of its Course Connection and throws an error if they don't match
    * @param termGrades A List of Term Grades with Contact, Course Offering and Course Connection.
    ********************************************************************************************************/
     
    private void validateCourseContact(List<Term_Grade__c> termGrades) {
    
        Map<Id, List<Term_Grade__c>> courseConnIdTermGradeMap = createCourseConnTermGradeMap(termGrades);
        
        for (Course_Enrollment__c eachEnrollment: [SELECT Id, Contact__c, Course_Offering__c FROM Course_Enrollment__c WHERE Id IN:courseConnIdTermGradeMap.keySet()]) {             
       
            for (Term_Grade__c tg : courseConnIdTermGradeMap.get(eachEnrollment.id)) {
                
               if (((eachEnrollment.contact__c != NULL && eachEnrollment.contact__c != tg.Contact__c) || (eachEnrollment.Course_Offering__c != NULL && eachEnrollment.Course_Offering__c != eachEnrollment.Course_Offering__c)) || (eachEnrollment.contact__c == NULL || eachEnrollment.Course_Offering__c == NULL)) {
                
                    tg.addError(Label.NoDataMatch);
                          
                    
                } 
            }
    
        }
                
    }
    
    /*******************************************************************************************************
    * @description Queries for Contact and updates the Term Grades if found.
    * If the values are not found, then throws an error.
    * @param termGrades A List of Term Grades with no Contact.
    ********************************************************************************************************/
    
    private void findContact(List<Term_Grade__c> termGrades) {
    
        Map<Id, List<Term_Grade__c>> courseConnIdTermGradeMap = createCourseConnTermGradeMap(termGrades);
        
        for (Course_Enrollment__c eachEnrollment: [SELECT Id, Contact__c, Course_Offering__c FROM Course_Enrollment__c WHERE Id IN:courseConnIdTermGradeMap.keySet()]) {
        
            for (Term_Grade__c tg : courseConnIdTermGradeMap.get(eachEnrollment.id)) {
            
                if (tg.Course_Offering__c == eachEnrollment.Course_Offering__c && eachEnrollment.Contact__c != NULL) {
                
                    tg.Contact__c = eachEnrollment.Contact__c;
                                
                } else {
                
                    tg.addError(Label.NoContactFound);
                
                }
            
            }
        
        }
        
    }
    
    /*******************************************************************************************************
    * @description Queries for Course Offering and updates the Term Grades if found.
    * If the values are not found, then throws an error.
    * @param termGrades A List of Term Grades with no Course Offering.
    ********************************************************************************************************/
    
    private void findCourseOffering(List<Term_Grade__c> termGrades) {
    
        Map<Id, List<Term_Grade__c>> courseConnIdTermGradeMap = createCourseConnTermGradeMap(termGrades);
        
        for (Course_Enrollment__c eachEnrollment: [SELECT Id, Contact__c, Course_Offering__c FROM Course_Enrollment__c WHERE Id IN:courseConnIdTermGradeMap.keySet()]) {
        
            for (Term_Grade__c tg : courseConnIdTermGradeMap.get(eachEnrollment.id)) {
            
                if (tg.Contact__c == eachEnrollment.Contact__c && eachEnrollment.Course_Offering__c != NULL) {
                
                    tg.Course_Offering__c = eachEnrollment.Course_Offering__c;
                                
                } else {
                
                    tg.addError(Label.NoCourseOffering);
                
                }
            
            }
        
        }
    
    }
    
        
   /*******************************************************************************************************
    * @description Queries for Contact and Course Offering, if found updates the Term Grades.
    * If the values are not found, then throws an error.
    * @param termGrades A List of Term Grades with no Contact and Course Offering
    ********************************************************************************************************/
    private void findContactCourseOffering(List<Term_Grade__c> termGrades) {
    
        Map<Id, List<Term_Grade__c>> courseConnIdTermGradeMap = createCourseConnTermGradeMap(termGrades);
    
        for (Course_Enrollment__c eachEnrollment: [SELECT Id, Contact__c, Course_Offering__c FROM Course_Enrollment__c WHERE Id IN:courseConnIdTermGradeMap.keySet()]) {             
       
            for (Term_Grade__c tg : courseConnIdTermGradeMap.get(eachEnrollment.id )) {
                
                if (eachEnrollment.contact__c != NULL && eachEnrollment.Course_Offering__c != NULL) {
                
                    tg.Contact__c = eachEnrollment.Contact__c;
                    tg.Course_Offering__c = eachEnrollment.Course_Offering__c;
                    
                } else {
                    
                    tg.addError(Label.OnlyCourseConnectionPopulated);
                    
                }
            }
    
        }
    
    }
    
   
    /*******************************************************************************************************
    * @description Returns a map with Course Connection and List of Term Grades as Key Value pairs.
    * @param termGrades A List of Term Grades to create a Map from.
    * @return createCourseConnTermGradeMap
    ********************************************************************************************************/    
    private Map<Id, List<Term_Grade__c>> createCourseConnTermGradeMap(List<Term_Grade__c> termGrades) {
    
        Map<Id, List<Term_Grade__c>> createCourseConnTermGradeMap = new Map<Id, List<Term_Grade__c>>();
    
        for (Term_Grade__c each: termGrades) {
        
            if (createCourseConnTermGradeMap.containsKey(each.Course_Connection__c)) {

                createCourseConnTermGradeMap.get(each.Course_Connection__c).add(each);

            }else {

                createCourseConnTermGradeMap.put(each.Course_Connection__c, new List<Term_Grade__c>{each});
            }

        }
        
        return createCourseConnTermGradeMap;
    }    

}