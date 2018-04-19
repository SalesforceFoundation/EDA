/**
* @author Salesforce.org
* @date 2018
* @group API
* @group-content ../../ApexDocContent/API.htm
* @description API class that exposes the Namespace Utility methods.
*/
global class UTIL_Namespace_API {

    /*******************************************************************************************************
    * @description Finds the namespace for the current context.
    * @return string The current namespace as a string, or a blank string if we're not in a namespaced context.
    */
    global static String getNamespace() {
        return UTIL_Namespace.getNamespace();
    }

    /*******************************************************************************************************
    * @description Static method adds the current namespace to a string if we're in a managed context,
    * with double underscore notation. If we're not in a managed context, returns the string itself.
    * @param str Token name.
    * @return Token name, with namespace prefix and double underscore if in a managed package.
    */
    global static String StrTokenNSPrefix(String str) {
        return UTIL_Namespace.StrTokenNSPrefix(str);
    }
    
    /*******************************************************************************************************
    * @description Static method adds the current namespace to a string if we're in a managed context,
    * with dot notation. If we're not in a managed context, returns the string itself.
    * @param str Token name.
    * @return Token name, with namespace prefix and dot notation if in a managed package.
    */
    global static String StrTokenNSPrefixDotNotation(String str) {
        return UTIL_Namespace.StrTokenNSPrefixDotNotation(str);
    }

    /*******************************************************************************************************
    * @description If we are in a managed package, tokens in dynamic SOQL must include the package namespace
    * prefix, bit field describes don't include namespace prefix fields within the package. This method can
    * be used in our describe code to remove an incorrect namespace prefix.
    * Removes package prefix, then removes dynamic prefix if one is detected.
    * @param str token name
    * @return token name, with namespace prefix removed, if present.
    */
    global static String StrTokenRemoveNSPrefix(String str) {
        return UTIL_Namespace.StrTokenRemoveNSPrefix(str);
    }

    /*******************************************************************************************************
    * @description Static method that takes a string of a multiple potential field names or object names.
    * If it is a custom object or field (name ends with __c), it prepends the namespace prefix if required.
    * If we are in a managed package, tokens in dynamic SOQL must include the package namespace prefix.
    * If you ever deploy this package as unmanaged, this routine will do nothing!
    * @param str string that contains 0 or more token names
    * @return same string with token names, namespace prefixed, if required.
    */
    global static String StrAllNSPrefix(String str) {
        return UTIL_Namespace.StrAllNSPrefix(str);
    }

    /*******************************************************************************************************
    * @description Static method that detects if we are running in a sandbox.
    * @return true if running in sandbox. false otherwise.
    */
    global static Boolean isSandbox() {
        return UTIL_Namespace.isSandbox();
    }

    /*******************************************************************************************************
    * @description Static method that returns the real email if it's a sandbox email.
    * @return string with user's email.
    */
    global static String sandboxEmailToRealEmail(String email) {
        return UTIL_Namespace.sandboxEmailToRealEmail(email);
    }

}