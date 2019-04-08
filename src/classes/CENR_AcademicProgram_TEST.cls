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
* @description Tests for CENR_AcademicProgram_TDTM.
*/
@isTest
public with sharing class CENR_AcademicProgram_TEST {
    
    @isTest
    public static void testInsert() {
        STG_InstallScript.insertMappings();

        Contact c = new Contact(LastName = 'Testerson');
        insert c;
        
        Account academicProgram = new Account(Name = 'BS in Biology', RecordTypeId = UTIL_Describe.getAcademicAccRecTypeID());
        Account department = new Account(Name = 'Biology Department', RecordTypeId = UTIL_Describe.getDepAccRecTypeID());
        insert new Account[]{academicProgram, department};
        
        Program_Enrollment__c pEnroll = new Program_Enrollment__c(Contact__c = c.Id, Account__c = academicProgram.Id);
        insert pEnroll;
        
        Course__c course = new Course__c(Account__c = department.Id);
        insert course;
        
        Term__c term = new Term__c(Account__c = department.Id);
        insert term;
        
        Course_Offering__c cOffering = new Course_Offering__c(Course__c = course.Id, Term__c = term.Id);
        insert cOffering;
        
        Course_Enrollment__c cEnroll = new Course_Enrollment__c(Contact__c = c.Id, Program_Enrollment__c = pEnroll.Id,
                                        Course_Offering__c = cOffering.Id);
        Test.startTest();
        insert cEnroll;
        Test.stopTest();
        
        cEnroll = [select Account__c from Course_Enrollment__c where ID = :cEnroll.Id];
        System.assertEquals(academicProgram.Id, cEnroll.Account__c);
    }
    
    @isTest
    public static void testUpdate() {
        STG_InstallScript.insertMappings();

        Contact c = new Contact(LastName = 'Testerson');
        insert c;
        
        Account academicProgram = new Account(Name = 'BS in Biology', RecordTypeId = UTIL_Describe.getAcademicAccRecTypeID());
        Account department = new Account(Name = 'Biology Department', RecordTypeId = UTIL_Describe.getDepAccRecTypeID());
        insert new Account[]{academicProgram, department};
        
        Program_Enrollment__c pEnroll = new Program_Enrollment__c(Contact__c = c.Id, Account__c = academicProgram.Id);
        insert pEnroll;
        
        Course__c course = new Course__c(Account__c = department.Id);
        insert course;
        
        Term__c term = new Term__c(Account__c = department.Id);
        insert term;
        
        Course_Offering__c cOffering = new Course_Offering__c(Course__c = course.Id, Term__c = term.Id);
        insert cOffering;
        
        Course_Enrollment__c cEnroll = new Course_Enrollment__c(Contact__c = c.Id, Course_Offering__c = cOffering.Id);
        insert cEnroll;
        
        cEnroll.Program_Enrollment__c = pEnroll.Id;
        Test.startTest();
        update cEnroll;
        Test.stopTest();
        
        cEnroll = [select Account__c from Course_Enrollment__c where ID = :cEnroll.Id];
        System.assertEquals(academicProgram.Id, cEnroll.Account__c);
    }
}