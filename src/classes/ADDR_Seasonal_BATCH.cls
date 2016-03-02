/*
    Copyright (c) 2015, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
* @author Salesforce.com Foundation
* @date 2015
* @group Addresses
* @group-content ../../ApexDocContent/Addresses.htm
* @description Updates seasonal addresses in batch.
*/ 
public with sharing class ADDR_Seasonal_BATCH implements Database.Batchable<SObject> {
    
    /*******************************************************************************************************
    * @description start Method for the Database.Batchable interface
    * @param bc the BatchableContext
    * @return database.Querylocator  
    ********************************************************************************************************/
    public database.Querylocator start(Database.BatchableContext bc){ 
        integer iMonth = system.today().month();
        integer iDay = system.today().day();
            
        String strQuery = 'select Id, Parent_Account__c, Default_Address__c ' +
            ' from Address__c ' +
            ' where Seasonal_Start_Month__c = \'' + String.valueOf(iMonth) + '\'' +
            ' and Seasonal_Start_Day__c = \'' + String.valueOf(iDay) + '\'';
                      
        return Database.getQueryLocator(strQuery);      
    }
    
    /*******************************************************************************************************
    * @description execute Method for the Database.Batchable interface
    * @param bc the BatchableContext
    * @param listSobj the list of Address objects to process
    * @return void  
    ********************************************************************************************************/
    public void execute(Database.BatchableContext bc, Sobject[] listSobj) {
        ADDR_Addresses_TDTM.batchSeasonalUpdate((list<Address__c>) listSobj);        
    }

    /*******************************************************************************************************
    * @description finish Method for the Database.Batchable interface
    * @param bc the BatchableContext
    * @return void  
    ********************************************************************************************************/
    public void finish(Database.BatchableContext bc) { } 
}