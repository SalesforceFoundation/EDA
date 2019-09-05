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
* @description This class is used along TG_ValidateData_TDTM to check for 
* Contact, Course Offering and Course Connection fields on Term Grade record.
*/
public class TermGradeValidator  { 

    private String errorMsg;
    private Boolean isValid;
    private String contactId;
    private String courseConnectionId;
    private String courseOfferingId;

    public TermGradeValidator(Term_Grade__c termGrade) {
        this.contactId = termGrade.Contact__c;
        this.courseConnectionId = termGrade.Course_Connection__c;
        this.courseOfferingId = termGrade.Course_Offering__c;
    }

    public String getError() {
        return this.errorMsg;
    }

    public Boolean hasValidFields() {

        if (this.courseConnectionId == NULL && this.contactId == NULL && this.courseOfferingId == NULL) {        
            this.errorMsg = Label.NoFieldsPopulated;
            return false;
        } else if (this.courseConnectionId == NULL && this.contactId != NULL && this.courseOfferingId == NULL) {
            // Only Contact is populated
            this.errorMsg = Label.OnlyContactPopulated;
            return false;
        } else if (this.courseConnectionId == NULL && this.contactId == NULL && this.courseOfferingId != NULL) {
            // Only Course Offering is populated
            this.errorMsg = Label.OnlyCourseOfferingPopulated;
            return false;
        }

        return true;
    }

    public Boolean needsCourseConnection() {
        return this.courseConnectionId == NULL && this.contactId != NULL && this.courseOfferingId != NULL;
    }

    public Boolean needsContact() {
        return this.courseConnectionId != NULL && this.contactId == NULL && this.courseOfferingId != NULL;
    }

    public Boolean needsCourseOffering() {
        return this.courseConnectionId != NULL && this.contactId != NULL && this.courseOfferingId == NULL;
    }

    public Boolean needsContactAndCourseOffering() {
        return this.courseConnectionId != NULL && this.contactId == NULL && this.courseOfferingId == NULL;
    }

    public Boolean hasAllFields() {
        return this.courseConnectionId != NULL && this.contactId != NULL && this.courseOfferingId != NULL;
    }

}