/*
    Copyright (c) 2016 Salesforce.org
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
* @description Batch class for Course Connections Backfill.
*
* Batch process looks at all Course Offerings and their related Course
* Connections. It assigns all current Faculty attached to Course Offerings
* to the Default Faculty RecordType and marks it as Primary. After it attaches
* all Faculty it will convert all other Course Connections without a RecordType
* to the Default Student RecordType.
*
*/
public class CCON_ConnectionBackfill_BATCH implements Database.Batchable<sObject> {

	private String query;

    private List<Course_Enrollment__c> connsToUpdate;
    private Boolean facultyConverted;

	public CCON_ConnectionBackfill_BATCH() {
        query = 'SELECT Id, Name, Faculty__c, ( SELECT Id, Name, Contact__c';
        if (recordTypesExist()) {
            query += ', RecordTypeId ';
        }
        query += ' FROM Course_Enrollment__r ) FROM Course_Offering__c';
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext bc, List<Course_Offering__c> offerings) {
        List<Course_Enrollment__c> connsToUpdate = new List<Course_Enrollment__c>();

        if (UTIL_CustomSettingsFacade.courseConnectionsEnabled()) {

            for(Course_Offering__c offering : offerings) {
                facultyConverted = false;
                if (offering.Course_Enrollment__r.size() > 0) {
                    for(Course_Enrollment__c connection : offering.Course_Enrollment__r) {
                        if (recordTypesExist()) {
                            if (connection.get('RecordTypeId') == noRecordType()) {
                                if (!facultyConverted && connection.Contact__c == offering.Faculty__c) {
                                    connection.put('RecordTypeId', UTIL_Describe.getFacultyConnectionRecType());
                                    connection.Primary__c = true;
                                    facultyConverted = true;
                                } else {
                                    connection.put('RecordTypeId', UTIL_Describe.getStudentConnectionRecType());
                                }
                                connsToUpdate.add(connection);
                            }
                        }
                    }
                }
            }
        }
        if (connsToUpdate.size() > 0) {
            update connsToUpdate;
        }
	}

    private String noRecordType() {
        if (Test.isRunningTest()) {
            return UTIL_Describe.getDefaultConnectionRecTypeID();
        }
        return null;
    }

    private Boolean recordTypesExist() {
        return UTIL_Describe.isValidField('Course_Enrollment__c','RecordTypeId');
    }

	public void finish(Database.BatchableContext bc) {}

}