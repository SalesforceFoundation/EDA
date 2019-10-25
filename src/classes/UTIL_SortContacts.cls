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
* @description Utility for Sorting Contact
*/
public class UTIL_SortContact implements Comparable {
    public String FirstName;
    public String LastName;
    public Contact contactRecord;
    private static final Integer SORT_BEFORE = -1;
    private static final Integer SORT_AFTER = 1;
    private static final Integer SORT_SAME = 0;

    /*******************************************************************************************************
    * @description Constructor that sets the Contact's First and Last Name and the Contact record itself.
    * @param c is the Contact record
    */
    public UTIL_SortContact(Contact c) {
        FirstName = c.FirstName;
        LastName = c.LastName;
        contactRecord = c;
    }

    /*******************************************************************************************************
    * @description method that returns an Integer value based on LastName/FirstName comparison.
    * @param compareTo is the object that is being passed for comparison.
    * @return Integer
    */
    public Integer compareTo(Object compareTo) {
        return sortByLastNameFirstName(compareTo);
    }

    /*******************************************************************************************************
    * @description sorts Contact by LastName and FirstName.
    * @param compareTo is the object that is being passed for comparison.
    * @return Integer
    */
    private Integer sortByLastNameFirstName(Object compareTo) {
        UTIL_SortContact contactToCompare = (UTIL_SortContact)compareTo;

        if (this.LastName == contactToCompare.LastName) {
            return sortByFirstName(contactToCompare);
        } else {
            return sortByLastName(contactToCompare);
        }

    }

    /*******************************************************************************************************
    * @description sorts Contact by FirstName.
    * @param contactToCompare is the record that needs to be compared
    * @return Integer
    */
    private Integer sortByFirstName(UTIL_SortContact contactToCompare) {
        if (this.FirstName == contactToCompare.FirstName) {
            return SORT_SAME;
        } else if (this.FirstName > contactToCompare.FirstName) {
            return SORT_AFTER;
        } else {
            return SORT_BEFORE;
        }
    }

    /*******************************************************************************************************
    * @description sorts Contact by LastName.
    * @param contactToCompare is the record that needs to be compared
    * @return Integer
    */
    private Integer sortByLastName(UTIL_SortContact contactToCompare) {
        if (this.LastName == contactToCompare.LastName) {
            return SORT_SAME;
        } else if (this.LastName > contactToCompare.LastName) {
            return SORT_AFTER;
        } else {
            return SORT_BEFORE;
        }
    }
}