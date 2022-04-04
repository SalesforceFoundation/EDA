/*
    Copyright (c) 2020, Salesforce.org
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
 * @date 2020
 * @group Utilities
 * @description TDTM helper class
 */
public with sharing class TDTM_Utility {
    /**
     * @description disable TDTM triggers for address
     */
    public static void disableAddressTriggers() {
        disableTriggersForClasses(new Set<String>{ 'ADDR_Contact_TDTM', 'ADDR_Account_TDTM', 'ADDR_Addresses_TDTM' });
    }

    /**
     * @description enable TDTM triggers for address
     */
    public static void enableAddressTriggers() {
        enableTriggersForClasses(new Set<String>{ 'ADDR_Contact_TDTM', 'ADDR_Account_TDTM', 'ADDR_Addresses_TDTM' });
    }

    /**
     * @description enable TDTM triggers for the specified trigger classes
     * @param  classNames a set of TDTM trigger class names
     */
    public static void enableTriggersForClasses(Set<String> classNames) {
        setTriggerActive(classNames, null, null, true);
    }

    /**
     * @description disable TDTM triggers for the specified trigger classes
     * @param  classNames a set of TDTM trigger class names
     */
    public static void disableTriggersForClasses(Set<String> classNames) {
        setTriggerActive(classNames, null, null, false);
    }

    /**
     * @description enable TDTM triggers for the specified objects
     * @param  objectNames a set of object names
     */
    public static void enableTriggersForObjects(Set<String> objectNames) {
        setTriggerActive(null, objectNames, null, true);
    }

    /**
     * @description disable TDTM triggers for the specified objects
     * @param  objectNames a set of object names
     */
    public static void disableTriggersForObjects(Set<String> objectNames) {
        setTriggerActive(null, objectNames, null, false);
    }

    /**
     * @description enable TDTM triggers for the specified namespace
     * @param  namespace TDTM namespace
     */
    public static void enableTriggersForNamespace(String namespace) {
        setTriggerActive(null, null, namespace, true);
    }

    /**
     * @description disable TDTM triggers for the specified namespace
     * @param  namespace TDTM namespace
     */
    public static void disableTriggersForNamespace(String namespace) {
        setTriggerActive(null, null, namespace, false);
    }

    /**
     * @description enable/disable TDTM triggers for the specified objects/classes/namespace
     * @param  classNames  a set of TDTM trigger class names
     * @param  objectNames a set of object names
     * @param  namespace   TDTM namespace
     * @param  active      TDTM token active value
     */
    private static void setTriggerActive(
        Set<String> classNames,
        Set<String> objectNames,
        String namespace,
        Boolean active
    ) {
        for (%%%NAMESPACE_DOT%%%TDTM_Global_API.TdtmToken tdtmToken : %%%NAMESPACE_DOT%%%TDTM_Global_API.getTdtmConfig()) {
            // disable for a specific trigger handler class
            if (classNames != null && classNames.contains(tdtmToken.className)) {
                tdtmToken.active = active;
            }
            // disable for an entire object
            if (objectNames != null && objectNames.contains(tdtmToken.targetObject)) {
                tdtmToken.active = active;
            }
            // disable all trigger handlers for the specified namespace
            if (namespace != null && tdtmToken.ownedByNamespace == namespace) {
                tdtmToken.active = active;
            }
        }
    }
}
