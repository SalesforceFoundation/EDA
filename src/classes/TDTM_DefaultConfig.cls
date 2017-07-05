/*
    Copyright (c) 2013, Salesforce.org
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
* @date 2014
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description Stores the default TDTM configuration.
**/
public without sharing class TDTM_DefaultConfig {

    /*******************************************************************************************************
    * @description Returns the default TDTM configuration. 
    * @return List<Trigger_Handler__c> a list of trigger handler records with the default values. The records
    *         have not yet been inserted in the database. You can manipulate them, if necessary, and insert 
    *         them. If no Trigger_Handler__c records exist, the application will insert the defaults when any 
    *         of the triggers run. 
    */
    public static List<Trigger_Handler__c> getDefaultRecords() {
        List<Trigger_Handler__c> handlers = new List<Trigger_Handler__c>();

        // Account Management on Contact
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'ACCT_IndividualAccounts_TDTM', Load_Order__c = 1.00, Object__c = 'Contact', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete'));
        
        //Supports changing or deleting Account in existing Affiliation
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'AFFL_AccChange_TDTM', Load_Order__c = 2, Object__c = 'Affiliation__c', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'AfterUpdate'));
        
        //Supports changing or deleting Contact in existing Affiliation
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'AFFL_ContactChange_TDTM', Load_Order__c = 2, Object__c = 'Affiliation__c', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'AfterUpdate'));
                    
        //Multi-Affiliation Type support on Affiliations - populates primary affl fields
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'AFFL_MultiRecordType_TDTM', Load_Order__c = 3, Object__c = 'Affiliation__c', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'BeforeInsert;AfterInsert;AfterUpdate;AfterDelete'));
        
        //Multi-Affiliation Type support on Account - supports account record type change
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'AFFL_AccRecordType_TDTM', Load_Order__c = 1, Object__c = 'Account', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'AfterUpdate'));
                          
        // Relationships on CampaignMember
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Cm_TDTM', Load_Order__c = 1, Object__c = 'CampaignMember', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'AfterInsert;AfterUpdate'));
        
        // Relationships on Contact
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 3, Object__c = 'Contact', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete'));
        
        // Relationships on Relationship__c
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_TDTM', Load_Order__c = 1, Object__c = 'Relationship__c', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete'));
          
        // Addresses on Address object - copies address from Address__c to Contact and Account
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'ADDR_Addresses_TDTM', Load_Order__c = 1, Object__c = 'Address__c', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete'));
                    
        // Addresses on Contact object - creates Address__c record from Contact
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'ADDR_Contact_TDTM', Load_Order__c = 2, Object__c = 'Contact', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate'));
        
        // Addresses on Account object - creates Address__c record from Account
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'ADDR_Account_TDTM', Load_Order__c = 1, Object__c = 'Account', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate'));
        
        // Do Not Contact and related operations on Contact object
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'CON_DoNotContact_TDTM', Load_Order__c = 2, Object__c = 'Contact', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'BeforeInsert;BeforeUpdate'));

        // Preferred fields operations on Contact object
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'CON_Preferred_TDTM', Load_Order__c = 3, Object__c = 'Contact', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'BeforeInsert;BeforeUpdate'));
        
        // Primary Affiliation fields operations on Contact object
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'CON_PrimaryAffls_TDTM', Load_Order__c = 4, Object__c = 'Contact', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'AfterInsert;AfterUpdate'));
              
        // Affiliation management on Program Enrollment record creation
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'PREN_Affiliation_TDTM', Load_Order__c = 1, Object__c = 'Program_Enrollment__c', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'BeforeInsert;AfterDelete'));
        
        // Affiliation and Date management on Course Offering record creation
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false,
              Class__c = 'COFF_Affiliation_TDTM', Load_Order__c = 1, Object__c = 'Course_Offering__c',
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'AfterInsert;AfterUpdate;BeforeDelete'));

        // Validation on Trigger Handler record manipulation
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'THAN_Filter_TDTM', Load_Order__c = 1, Object__c = 'Trigger_Handler__c', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'BeforeInsert;BeforeUpdate'));
              
        // Default dates from Term to Course Offerings
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'TERM_CourseOff_TDTM', Load_Order__c = 1, Object__c = 'Term__c', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'AfterUpdate'));
        
        // Stops a Contact from being deleted if it has any Affiliation, Program Enrollment or Course Enrollment children
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'CON_CannotDelete_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'BeforeDelete'));
                     
        // Stops a Account from being deleted if it has any Affiliation, Program Enrollment or Course Enrollment children
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'ACCT_CannotDelete_TDTM', Load_Order__c = 1, Object__c = 'Account', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'BeforeDelete'));
              
        // Automatically populates the Academic Program field in a Course Enrollment
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'CENR_AcademicProgram_TDTM', Load_Order__c = 1, Object__c = 'Course_Enrollment__c', 
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'BeforeInsert;BeforeUpdate'));

        // Course Connections Faculty Management on Course Enrollment object
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'CCON_Faculty_TDTM', Load_Order__c = 1, Object__c = 'Course_Enrollment__c',
              Owned_by_Namespace__c = 'hed' ,Trigger_Action__c = 'BeforeInsert;AfterInsert;AfterUpdate;AfterDelete'));

        return handlers;
    }
}