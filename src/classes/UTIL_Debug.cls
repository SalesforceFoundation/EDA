/*
    Copyright (c) 2014 Salesforce.com Foundation
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
* @date 2014
* @group Utilities
* @description Utility class for debug statements to turn them off in a managed context, as well as to display relevant performance information.
*/
public with sharing class UTIL_Debug {

    //enable debug logs in all tests, otherwise get the setting
    public static boolean enabled = test.isRunningTest() ? true : UTIL_CustomSettingsFacade.getSettings().Enable_Debug__c;

    /*******************************************************************************************************
    * @description Prints a debug message to the debug log, if debugging is enabled or a test is being run.
    * @param message The message to print.
    * @return void
    */
    public static void debug (string message) {
        if (enabled) {
            System.debug(message);
        }
    }

    /*******************************************************************************************************
    * @description Prints a debug message to the debug log, if debugging is enabled or a test is being run, at the specified
    *              logging level.
    * @param message The message to print.
    * @param level The level to output the message at.
    * @return void
    */
    public static void debug (System.LoggingLevel level, string message) {
        if (enabled) {
            System.debug(level, message);
        }
    }

    /*******************************************************************************************************
    * @description Prints a debug message to the debug log, if debugging enabled or a test is being run, with additional info, 
                   such as heap, cpu, query, and rows usage.
    * @param message The message to print.
    * @return void
    */
    public static void debugWithInfo (string message) {
        if (enabled) {
            System.debug(
                message + 
                ' Heap:' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize() +
                ' CPU:' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime() + 
                ' Query:' + Limits.getQueries() + '/' + Limits.getLimitQueries() + 
                ' Rows:' + Limits.getDMLRows() + '/' + Limits.getLimitDMLRows()
            );
        }
    }

    /*******************************************************************************************************
    * @description Prints a debug message to the debug log, if debugging is enabled or a test is being run, at the specified logging
    *              level, with additional info, such as heap, cpu, query, and rows usage.
    * @param message The message to print.
    * @param level The level to output the message at.
    * @return void
    */
    public static void debugWithInfo (System.LoggingLevel level, string message) {
        if (enabled) {
            System.debug(
                level,
                message + 
                ' Heap:' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize() +
                ' CPU:' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime() + 
                ' Query:' + Limits.getQueries() + '/' + Limits.getLimitQueries() + 
                ' Rows:' + Limits.getDMLRows() + '/' + Limits.getLimitDMLRows()
            );
        }
    }
}