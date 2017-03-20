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
/**
* @author Salesforce.org
* @date 2016
* @group CourseEnrollments
* @group-content ../../ApexDocContent/CourseEnrollments.htm
* @description This class is to be used as a controller for Course Connections Settings.
*/

public class STG_CourseConnections {
	/*******************************************************************************************************
     * @description Enqueues and returns an Job Id for the Course Connections Backill
     * @return Id of Course Connection Backill Job
     */
    @AuraEnabled
    public static Id getEnqueueCourseConnectionsBackfill() {
        CCON_ConnectionBackfill_BATCH batch = new CCON_ConnectionBackfill_BATCH();
        Id ApexJobId = Database.executeBatch(batch, 200);
        return ApexJobId;
    }

  /*******************************************************************************************************
    * @description Enqueues and returns a Job Id for the Course Description Copy Job
     * @return Id of Course Description Copy Job
    */
    @AuraEnabled
    public static Id courseDescriptionCopy() {
        COUR_DescriptionCopy_BATCH contbatch = new COUR_DescriptionCopy_BATCH();
        Id jobId = Database.executeBatch( contbatch , 200 );
        if(jobId == null) {
            throw new AuraHandledException('There was a problem starting the Job.');
        } else {
            return jobId;
        }
    }
}