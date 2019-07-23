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
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description Collects information about the current org and EDA setup information
* and sends it back to the EDA License Management Application to assist with better
* understanding of how our customers use our application. This logic is called on
* every push upgrade by the STG_InstallScript class.
*
* Uses "without sharing" so that it has full rights to query all records in all objects.
* This is needed to ensure a consistent return of telemetry data even if the process is
* called by different users with different permissions. Specifie PII is never queried or
* returned by this class.
*/
public without sharing class UTIL_OrgTelemetry {

    /**
     * @description A complete list of the Telemetry Types (at a high level) that are handled by this service class.
     * These are used by the batch job to process feature parameters in asynchronous groups to avoid governor
     * limit issues. The concept is that by separating each of these into smaller groupings that are processed
     * as separate child batch iterations, the entire process can complete even if for some reason one of the queries
     * against a table were to fail.
     */
    public enum TelemetryBatchCategory {
        EDA_Settings//,
        // TODO: Add more categories here in W-033621
    }

    /**
     * @description Each of these corresponds to the exact name of a FeatureParameter in the managed package.
     */
    public enum TelemetryParameterName {
        IsEnabled_AutomaticHouseholdNaming//,
        // TODO: Add more feature parameters here in W-033621
    }

    /**
     * @description Execute the batch job that will process each telemetry FeatureParameter type one at a time
     * as individual batch iterations. This process has to be asynchronous to handle governor limits against
     * huge queries as well as to avoid MixedDML errors in case a calling process were to modify a record.
     */
    public static void dispatchTelemetryBatchJob() {
        Database.executeBatch(new UTIL_OrgTelemetry_BATCH(), 1);
    }

    /**
     * @description Called by the batch job to process an individual telemetry type.
     * Submits specific feature telemetry statistics back to the License Management Org to assist
     * with understanding how our customers are using EDA functionality.
     * Each feature below must be matched to a SubscriberToLmo feature of the same name.
     * @param telemetryCategory The individual telemetry type to process.
     */
    public void processTelemetryType(TelemetryBatchCategory telemetryCategory) {

        switch on (telemetryCategory) {
            when EDA_Settings {
                // TODO: Finish in W-033621
            }

            // TODO: Finish in W-033621
        }
    }
}