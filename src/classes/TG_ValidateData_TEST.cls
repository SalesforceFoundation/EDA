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
* @group Contacts
* @group-content ../../ApexDocContent/TermGrades.htm
* @description Unit tests for Term Grades data validation
*/


@isTest
private class TG_ValidateData_TEST {
    
    @testSetup
    static void dataSetup() { 
    
        Contact student = new Contact(lastName = 'studentTest');
        insert student;       
        Account department = new Account(name = 'Literature', RecordTypeId = UTIL_Describe_API.getAcademicAccRecTypeID());
        insert department; 
        Course__c course = new Course__c(Name = 'English', Account__c = department.id);
        insert course;     
        Term__c term = new Term__c(Name = 'Fall 19', Account__c = department.id);
        insert term;       
        Course_Offering__c courseOffering = new Course_Offering__c(Course__c = course.id, Term__c = term.id, Name = 'ENG-101');
        insert courseOffering;
    }
    
    // Test for error when Term Grade has no Contact, Course Offering and Course Connection
    
    @isTest 
    static void testNoFieldsPopulated() {
        
        try {
            Term_Grade__c termGrade = new Term_Grade__c();
            Test.startTest();
            insert termGrade; 
            Test.stopTest();          
        }catch(Exception error) {
             System.assert(error.getMessage().contains(Label.NoFieldsPopulated));
        }    
    
    }
    
     // Test for error when Term Grade has only Contact
    
    @isTest 
    static void testOnlyContactPopulated() {
        
        Contact student = [SELECT id FROM Contact LIMIT 1];
        
        try {
            Term_Grade__c termGrade = new Term_Grade__c(Contact__c = student.id);
            Test.startTest();
            insert termGrade;
            Test.stopTest();            
        }catch(Exception error) {
             System.assert(error.getMessage().contains(Label.OnlyContactPopulated));
        }    
    
    }
    
    // Test for error when Term Grade has only Course Offering
    
    @isTest 
    static void testOnlyCourseOfferingPopulated() {
        
        Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
        
        try {
            Term_Grade__c termGrade = new Term_Grade__c(Course_Offering__c = courseOffering.id);
            Test.startTest();
            insert termGrade;    
            Test.stopTest();        
        }catch(Exception error) {
             System.assert(error.getMessage().contains(Label.OnlyCourseOfferingPopulated));
        }    
    
    }
    
    // Test auto-population of Contact and Course Offering when only Course Connection is populated 
    
    @isTest 
    static void testPositiveOnlyCourseConnectionPopulated() {
        
        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {  

            Contact student = [SELECT id FROM Contact LIMIT 1];     
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Contact__c = student.id, Course_Offering__c = courseOffering.Id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
            Term_Grade__c termGrade = new Term_Grade__c(Course_Connection__c = courseEnrollment.id);
            Test.startTest();
            insert termGrade;
            Test.stopTest();          
            Term_Grade__c updatedTermGrade = [SELECT contact__c, Course_Offering__c FROM Term_Grade__c LIMIT 1];
            
            System.assertEquals(updatedTermGrade.contact__c, student.id);
            System.assertEquals(updatedTermGrade.Course_Offering__c, courseOffering.id);
            
        }
     } 
     
     // Test for error when no Contact and Course Offering is found for a Course Connection
    
    @isTest 
    static void testNegativeOnlyCourseConnectionPopulated() {

        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 
        
            Contact student = [SELECT id FROM Contact LIMIT 1];       
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];        
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c();
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
        
            try {
                Term_Grade__c termGrade = new Term_Grade__c(Course_Connection__c = courseEnrollment.id);
                Test.startTest();
                insert termGrade;
                Test.stopTest();
            }catch(Exception error) {
                 System.assert(error.getMessage().contains(Label.OnlyCourseConnectionPopulated));
            
            }  
            
        }

    }     
     
     // Test auto-population of Course-Offering when the Term Grade has Course Connection and Contact
     
     @isTest 
     static void testPoitiveNoCourseOffering() {

        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 

            Contact student = [SELECT id FROM Contact LIMIT 1];       
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];     
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Contact__c = student.id, Course_Offering__c = courseOffering.Id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;       
            Term_Grade__c termGrade = new Term_Grade__c(Course_Connection__c = courseEnrollment.id, contact__c = student.id);
            Test.startTest();
            insert termGrade;
            Test.stopTest();
            Term_Grade__c updatedTermGrade = [SELECT Course_Offering__c FROM Term_Grade__c LIMIT 1];
        
            System.assertEquals(updatedTermGrade.Course_Offering__c, courseOffering.id);

        }   
     }   
     
     // Test for error when no Course Offering is found for a Term Grade with Course Connection and Contact
     
     @isTest 
     static void testNegativeNoCourseOffering() {

        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 

            Contact student = [SELECT id FROM Contact LIMIT 1]; 
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1]; 
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Contact__c = student.id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
        
            try {
                Term_Grade__c termGrade = new Term_Grade__c(Course_Connection__c = courseEnrollment.id, contact__c = student.id);
                Test.startTest();
                insert termGrade;
                Test.stopTest();
            }catch(Exception error) {
                System.assert(error.getMessage().contains(Label.NoCourseOffering));
            
           }  
            
       }

     }      
    
      // Test auto-population of a Contact when the Term Grade has Course Connection and Course Offering 
     
     @isTest 
     static void testPoitiveNoContact() {

     // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 

            Contact student = [SELECT id FROM Contact LIMIT 1];      
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];    
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(contact__c = student.id, Course_Offering__c = courseOffering.Id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment; 
            Term_Grade__c termGrade = new Term_Grade__c(Course_Connection__c = courseEnrollment.id, Course_Offering__c = courseOffering.id);
            Test.startTest();
            insert termGrade;
            Test.stopTest();
            Term_Grade__c updatedTermGrade = [SELECT contact__c FROM Term_Grade__c LIMIT 1];
        
            System.assertEquals(updatedTermGrade.Contact__c, student.id);
           
        }
     }      
     
     // Test for error when no Contact is found for a Term Grade with Course Connection and Course Offering
     
     @isTest 
     static void testNegativeNoContact() {

     // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 

            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];   
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Course_Offering__c = courseOffering.Id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
            try {
                Term_Grade__c termGrade = new Term_Grade__c(Course_Connection__c = courseEnrollment.id, Course_Offering__c = courseOffering.id);
                Test.startTest();
                insert termGrade;
                Test.stopTest();
            }catch(Exception error) {
                System.assert(error.getMessage().contains(Label.NoContactFound));
            
            }  
           
        } 
     }   
     
     // Test for error when Contact and Course Offering on Term Grade do not match with the ones on Course Connection
     
     @isTest 
     static void testDataNoMatch() {
        
        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 

            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1]; 
            Term__c term = [SELECT Id FROM Term__C LIMIT 1]; 
            Course__c course = [SELECT Id FROM Course__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Course_Offering__c = courseOffering.Id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment; 
            Contact newStudent = new Contact(lastName = 'studentTest');
            insert newStudent;  
            Course_Offering__c courseOfferingNew = new Course_Offering__c(Course__c = course.id, Term__c = term.id, Name = 'ENG-201');
            insert courseOfferingNew;
        
            try {
                Term_Grade__c termGrade = new Term_Grade__c(Course_Connection__c = courseEnrollment.id, Course_Offering__c = courseOfferingNew.id, contact__c = newStudent.id);
                Test.startTest();
                insert termGrade;
                Test.stopTest();
            }catch(Exception error) {
                System.assert(error.getMessage().contains(Label.NoDataMatch));
            
            }  
           
        } 
     }  

     // Test for error when Contact and Course Offering on Term Grade do not match with the ones on Course Connection
     
     @isTest 
     static void testDataMatch() {

        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 
 
            ID studentRecTypeId = Schema.SObjectType.Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Term__c term = [SELECT Id FROM Term__C LIMIT 1];
            Course__c course = [SELECT Id FROM Course__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, contact__c = student.id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
                    
            Term_Grade__c termGrade = new Term_Grade__c(Course_Connection__c = courseEnrollment.id, Course_Offering__c = courseOffering.id, contact__c = Student.id);
            Test.startTest();
            insert termGrade;
            Test.stopTest();
            System.assertEquals(termGrade.Course_Connection__c, courseEnrollment.id);
            System.assertEquals(termGrade.Course_Offering__c, courseOffering.id);
            System.assertEquals(termGrade.contact__c, Student.id);
         
        } 
    
           
     }   
    
     // Test auto-populate Course Connection when the Term Grade has Contact and Course Offering populated
     
     @isTest 
     static void testPoitiveNoCourseConnection() {
        
        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 

            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, contact__c = student.id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
        
            Term_Grade__c termGrade = new Term_Grade__c(Course_Offering__c = courseOffering.id, contact__c = Student.id);
            Test.startTest();
            insert termGrade;
            Test.stopTest();
            Term_Grade__c updatedTermGrade = [SELECT Course_Connection__c FROM Term_Grade__c LIMIT 1];
             
            System.assertEquals(updatedTermGrade.Course_Connection__c, courseEnrollment.id);  
           
        }

     }      
    
     // Test for error when more than one Course Connection is found with same Contact and Course Offering for a given Term Grade
     
     @isTest 
     static void testMultipleCourseConnection() {

        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 

            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Term__c term = [SELECT Id FROM Term__C LIMIT 1];
            Account department = [SELECT id FROM Account LIMIT 1];
            Course__c course = [SELECT Id FROM Course__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, contact__c = student.id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
                
            Term__c newTerm = new Term__c(Name = 'Fall 18', Account__c = department.id);
            insert newTerm;  
            Course_Offering__c newCourseOffering = new Course_Offering__c(Course__c = course.id, Term__c = newTerm.id, Name = 'ENG-101');
            insert newCourseOffering; 
            Course_Enrollment__c courseEnrollmentWTerm = new Course_Enrollment__c(Course_Offering__c = CourseOffering.Id, contact__c = student.id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollmentWTerm;
        
            try {
                Term_Grade__c termGrade = new Term_Grade__c(Course_Offering__c = courseOffering.id, contact__c = Student.id, Term__c = newTerm.Id);
                Test.startTest();
                insert termGrade;
                Test.stopTest();
            }catch(Exception error) {
                System.assert(error.getMessage().contains(Label.MultipleCourseConnection));            
            }

        }       
           
     }   
     
     // Test for error when no Course Connection is found with same Contact and Course Offering for a given Term Grade
     
     @isTest 
     static void testNegativeNoCourseConnection() {
        
        Contact student = [SELECT id FROM Contact LIMIT 1];
        Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
       
        try{
            Term_Grade__c termGrade = new Term_Grade__c(Course_Offering__c = CourseOffering.id, contact__c = Student.id);
            Test.startTest();
            insert termGrade;
            Test.stopTest();
        }catch(Exception error) {      
            System.assert(error.getMessage().contains(Label.NoCourseConnection));          
        }        
                   
     } 
    
    // Test insertion of multiple Term Grades with same Course Connection
     
    @isTest 
    static void testOnlyCourseConnectionPopulatedWMultipleTG() {
        
        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 

            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Contact__c = student.id, Course_Offering__c = courseOffering.Id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
            Test.startTest(); 
            List<Term_Grade__c> termGrades = new List<Term_Grade__c>();
            Term_Grade__c termGrade1 = new Term_Grade__c(Course_Connection__c = courseEnrollment.id);
            termGrades.add(termGrade1);
            Term_Grade__c termGrade2 = new Term_Grade__c(Course_Connection__c = courseEnrollment.id);
            termGrades.add(termGrade2); 
            insert termGrades;
            Test.stopTest();
            Term_Grade__c updatedTermGrade = [SELECT contact__c, Course_Offering__c FROM Term_Grade__c LIMIT 1];
            
            System.assertEquals(updatedTermGrade.contact__c, student.id);
            System.assertEquals(updatedTermGrade.Course_Offering__c, courseOffering.id);
            
        }

    }    
     
     // Test insertion of multiple Term Grades with same Contact and different Course Offering
     
     @isTest 
     static void testNoCourseConnectionWMultipleTG() {

        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 

            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, contact__c = student.id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
            Course__c course = [SELECT Id FROM Course__c LIMIT 1];
            Term__c term = [SELECT Id FROM Term__C LIMIT 1];
            Course_Offering__c courseOfferingNew = new Course_Offering__c(Course__c = course.id, Term__c = term.id, Name = 'ENG-201');
            insert courseOfferingNew;
            Course_Enrollment__c courseEnrollmentNew = new Course_Enrollment__c(Course_Offering__c = courseOfferingNew.Id, contact__c = student.id);
            courseEnrollmentNew.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollmentNew;
            Test.startTest();
            List<Term_Grade__c> termGrades = new List<Term_Grade__c>();
            Term_Grade__c termGrade1 = new Term_Grade__c(Course_Offering__c = courseOffering.id, contact__c = Student.id);
            termGrades.add(termGrade1);
            Term_Grade__c termGrade2 = new Term_Grade__c(Course_Offering__c = courseOfferingNew.id, contact__c = Student.id);
            termGrades.add(termGrade2);
            insert termGrades;
            Test.stopTest();
            Term_Grade__c updatedTermGrade = [SELECT Course_Connection__c FROM Term_Grade__c WHERE Course_Offering__c =:courseOffering.id LIMIT 1];
             
            System.assertEquals(updatedTermGrade.Course_Connection__c, courseEnrollment.id);  
           
        }

     }  
    
    // Test TermGradeValidator class for valid fields populated

    @isTest
    static void testTermGradeValidatorHasFieldsPopulated() {
        
        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 
            ID studentRecTypeId = Schema.SObjectType.Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Contact__c = student.id, Course_Offering__c = courseOffering.Id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
            Test.startTest();
            Term_Grade__c tg = new Term_Grade__c(Contact__c = student.id, Course_Connection__c = courseEnrollment.id, Course_Offering__c = courseOffering.id);
            TermGradeValidator tgv = new TermGradeValidator(tg);
            Test.stopTest();
            System.AssertEquals(true, tgv.hasValidFields());
            
        }
    } 
    
    // Test TermGradeValidator class for no fields populated

    @isTest
    static void testTermGradeValidatorNoFieldsPopulated() {
         Test.startTest();
         Term_Grade__c tg = new Term_Grade__c();
         TermGradeValidator tgv = new TermGradeValidator(tg);
         Test.stopTest();
         System.AssertEquals(false, tgv.hasValidFields());
            
    }
    
    // Test TermGradeValidator class for only Contact populated

    @isTest
    static void testTermGradeValidatorOnlyContactPopulated() {
        
        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 
        
            ID studentRecTypeId = Schema.SObjectType.Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Contact__c = student.id, Course_Offering__c = courseOffering.Id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
            Test.startTest();
            Term_Grade__c tg = new Term_Grade__c(Contact__c = student.id);
            TermGradeValidator tgv = new TermGradeValidator(tg);
            Test.stopTest();
            System.AssertEquals(false, tgv.hasValidFields());
            
        }
    }

    // Test TermGradeValidator class for only Course Offering populated
    
    @isTest
    static void testTermGradeValidatorOnlyCourseOfferingPopulated() {
        
        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 
        
            ID studentRecTypeId = Schema.SObjectType.Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Contact__c = student.id, Course_Offering__c = courseOffering.Id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
            Test.startTest();
            Term_Grade__c tg = new Term_Grade__c(Course_Offering__c = courseOffering.Id);
            TermGradeValidator tgv = new TermGradeValidator(tg);
            Test.stopTest();
            System.AssertEquals(false, tgv.hasValidFields());
            
        }
    }
    
    // Test TermGradeValidator class for Contact and Course Offering populated

    @isTest
    static void testTermGradeValidatorNeedsCourseConnection() {
        
        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 
        
            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(contact__c = student.id, Course_Offering__c = courseOffering.Id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
            Test.startTest();
            Term_Grade__c tg = new Term_Grade__c(Course_Connection__c = courseEnrollment.id, Course_Offering__c = courseOffering.id);
            insert tg;
            TermGradeValidator tgv = new TermGradeValidator(tg);
            Test.stopTest();
            System.AssertEquals(true, tgv.hasValidFields());
            
        }
    }

    // Test TermGradeValidator class for Contact and Course Connection populated
    
    @isTest 
    static void testTermGradeValidatorNoCourseOffering() {
        
        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 

            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, contact__c = student.id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
            Test.startTest();
            Term_Grade__c tg = new Term_Grade__c(Course_Connection__c = courseEnrollment.id, contact__c = Student.id);
            insert tg;      
            TermGradeValidator tgv = new TermGradeValidator(tg);
            Test.stopTest();
            System.AssertEquals(true, tgv.hasValidFields());
           
        }

     }
    
    // Test TermGradeValidator class for no Contact and Course Offering populated

    @isTest 
    static void testTermGradeValidatorHasCourseConnection() {
        
        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 

            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, contact__c = student.id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
            Test.startTest();
            Term_Grade__c tg = new Term_Grade__c(Course_Connection__c = courseEnrollment.id);
            insert tg;
            TermGradeValidator tgv = new TermGradeValidator(tg);
            Test.stopTest();
            System.AssertEquals(true, tgv.hasValidFields());
           
        }

     }
    
    // Test TermGradeValidator for all fields populated

    @isTest 
    static void testTermGradeValidatorHasAllFields() {
        
        // Do not run test if record types do not exist 
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) { 

            Contact student = [SELECT id FROM Contact LIMIT 1];
            Course_Offering__c courseOffering = [SELECT id FROM Course_Offering__c LIMIT 1];
            Course_Enrollment__c courseEnrollment = new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, contact__c = student.id);
            courseEnrollment.put('RecordTypeId', UTIL_Describe_API.getStudentConnectionRecType());
            insert courseEnrollment;
            Test.startTest();
            Term_Grade__c tg = new Term_Grade__c(Course_Connection__c = courseEnrollment.id, contact__c = Student.id, Course_Offering__c = courseOffering.id);
            insert tg;
            TermGradeValidator tgv = new TermGradeValidator(tg);
            Test.stopTest();
            System.AssertEquals(true, tgv.hasValidFields());
           
        }

     }
    
    // Test for error on TermGradeValidator
    
    @isTest 
    static void testTermGradeValidatorError() {
        
        Contact student = [SELECT id FROM Contact LIMIT 1];

        try {
            Term_Grade__c tg = new Term_Grade__c(Contact__c = student.id);
            Test.startTest();
            insert tg;       
            TermGradeValidator tgv = new TermGradeValidator(tg);
            Test.stopTest();
            System.AssertEquals(false, tgv.hasValidFields());           
        }catch(Exception error) {
             System.assert(error.getMessage().contains(Label.OnlyContactPopulated));
        }    
        
    }
}