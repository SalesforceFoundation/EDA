/*
    Copyright (c) 2014 Salesforce.org
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
* @group Utilities
* @description Class which holds static methods for common utilities, 
* such as detecting whether we are in a managed package, and some string helpers.
*/

public class UTIL_Namespace { 

    /******************************************************************************************************
    * @description String helper property for getNamespace() method.
    *******************************************************************************************************/
    private static string plainNamespace;
    /*******************************************************************************************************
    * @description Finds the namespace for the current context.
    * @return string The current namespace as a string, or a blank string if we're not in a namespaced context.
    ********************************************************************************************************/
    public static string getNamespace() {       
        if (plainNamespace == null) {
            string withDotNotation = UTIL_Namespace.class.getName();  
        
            if (withDotNotation.contains('.')) {
                plainNamespace = withDotNotation.substringBefore('.');
            } else {
                plainNamespace = '';
            }
        }
        return plainNamespace;   
    }

    /*******************************************************************************************************
    * @description Static method adds the current namespace to a string if we're in a managed context, 
    * with double underscore notation. If we're not in a managed context, returns the string itself.
    * @param str Token name.
    * @return Token name, with namespace prefix and double underscore if in a managed package.
    ********************************************************************************************************/
    public static string StrTokenNSPrefix(string str) {
        if (getNamespace() == '') return str;
        return getNamespace() + '__' + str;
    }
    
    /*******************************************************************************************************
    * @description Static method adds the current namespace to a string if we're in a managed context, 
    * with dot notation. If we're not in a managed context, returns the string itself.
    * @param str Token name.
    * @return Token name, with namespace prefix and dot notation if in a managed package.
    ********************************************************************************************************/
    public static string StrTokenNSPrefixDotNotation(string str) {
        if (getNamespace() == '') return str;
        return getNamespace() + '.' + str;
    }

    /*******************************************************************************************************
    * @description If we are in a managed package, tokens in dynamic SOQL must include the package namespace
    * prefix, bit field describes don't include namespace prefix fields within the package. This method can
    * be used in our describe code to remove an incorrect namespace prefix.
    * Removes package prefix, then removes dynamic prefix if one is detected.
    * @param str token name 
    * @return token name, with namespace prefix removed, if present.
    ********************************************************************************************************/
    public static string StrTokenRemoveNSPrefix(string str) {
        String namespace = getNamespace();
        if(str.startsWith(namespace + '__'))
            str = str.replaceFirst(namespace + '__', '');
        if (namespace != '' && str.startsWith(namespace + '__'))
            str = str.replaceFirst(namespace + '__', '');
        return str;
    }
    
    /*******************************************************************************************************
    * @description Static method that takes a string of a multiple potential field names or object names.  
    * If it is a custom object or field (name ends with __c), it prepends the namespace prefix if required.
    * If we are in a managed package, tokens in dynamic SOQL must include the package namespace prefix.
    * If you ever deploy this package as unmanaged, this routine will do nothing!
    * @param str string that contains 0 or more token names 
    * @return same string with token names, namespace prefixed, if required.
    ********************************************************************************************************/
    public static string StrAllNSPrefix(string str) {
        if (getNamespace() == '') return str;
        Pattern pat = Pattern.Compile('[a-zA-z0-9]*__c');
        Matcher match = pat.matcher(str);
        return match.replaceAll(getNamespace()+'__$0');
    }
    
    /*******************************************************************************************************
    * @description Static method that detects if we are running in a sandbox.
    * @return true if running in sandbox. false otherwise.
    ********************************************************************************************************/
    public static Boolean isSandbox() {
	    return URL.getSalesforceBaseUrl().getHost().left(2).equalsignorecase('cs');
	}
	
	/*******************************************************************************************************
    * @description Static method that returns the real email if it's a sandbox email.
    * @return string with user's email.
    ********************************************************************************************************/
    public static String sandboxEmailToRealEmail(String email) {
        if((isSandbox() || Test.isRunningTest()) && email.contains('=')) {
          email = email.substring(0, email.indexOf('@'));
          email = email.replace('=', '@');
        }
        return email;
    }
    
    /*******************************************************************************************************
    * @description We need this method because labels that are nowhere in the codebase are now not included in
    * the package, even if explicitly listed in package.xml.
    * @return void.
    ********************************************************************************************************/
    public static void hack() {
        String l1 = Label.noAfflMappings;
        String l2 = Label.noAutoCreateSettings;
        String l3 = Label.noRecSettings;
    }
}