/*
    Copyright (c) 2018 Salesforce.org
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
* @group ErrorHandling
* @description A Batch job that detects errors which are more than 90 days old and delete them
*/
public virtual class ERR_DeleteOutdated_BATCH implements Database.Batchable<SObject> {

    /*******************************************************************************************************
    * @description start Method for the Database.Batchable interface
    * @param bc the BatchableContext
    * @return database.Querylocator
    ********************************************************************************************************/
    public database.Querylocator start(Database.BatchableContext bc){

        DateTime ninetyDaysAgo = DateTime.now().addDays(-90);
        String strQuery = 'SELECT Id' +
                        ' FROM Error__c ' +
                        ' where Datetime__c < :ninetyDaysAgo';

        return Database.getQueryLocator(strQuery);
    }
    /*******************************************************************************************************
    * @description execute Method for the Database.Batchable interface
    * @param bc the BatchableContext
    * @param listSobj the list of Error objects to process
    * @return void
    ********************************************************************************************************/
    public void execute(Database.BatchableContext bc, Sobject[] listSobj) {

        TDTM_Runnable.Dmlwrapper dmlWrapper = new TDTM_Runnable.Dmlwrapper();
        dmlWrapper.objectsToDelete.addAll(listSobj);
        // Process DML. We want to parse the errors so the allOrNone boolean is set to false
        ERR_Handler.Errors errors = TDTM_TriggerHandler.processDML(dmlWrapper, false);

        // process results for an error otherwise we can assume success
        if (errors.errorsExist) {
            Map<Id, Error__c> mapIdToError = new Map<Id, Error__c>();
            for (Error__c error : (list<Error__c>)listSobj) {
                mapIdToError.put(error.Id, error);
            }
            for (Error__c error : errors.errorRecords) {
                ID objId = ERR_Handler.getErrorObjectId(error);
                Error__c recordError = mapIdToError.get(objId);
                recordError.addError(error.Full_Message__c);
            }
        }
    }

    /*******************************************************************************************************
    * @description finish Method for the Database.Batchable interface
    * @param bc the BatchableContext
    * @return void
    ********************************************************************************************************/
    public void finish(Database.BatchableContext bc) { }

}