/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
* @date 2021
* @group 
* @group-content ../../ApexDocContent/
* @description Service class to address String functionality not provided out of the box.
*/
public with sharing class StringHandlingService {
    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static StringHandlingService instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    public StringHandlingService() {}

    /******************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of StringHandlingService.
    ******************************************************************************/
    public static StringHandlingService getInstance() {
        if (instance == null) {
            instance = new StringHandlingService();
        }

        return instance;
    }

    /**************************************************************************************************
    * @description Prepends an apostrophe (') character to escape existing apostrophes in a string and 
    * substitutes parameters with values provided.
    * @param  stringToFormat A string with apostrophes to escape and parameters to substitute
    * @param  stringParameterList A list of string parameters
    * @return A formatted string with apostrophes escaped and parameters populated.
    **************************************************************************************************/
    public String formatStringWithApostrophesAndParameters(
        String stringToFormat, 
        List<Object> stringParameterList
    ) {
        String unescapedSingleQuote = '\'';
        String escapedSingleQuote = '\'\'';

        String stringWithEscapedSingleQuotes = 
            stringToFormat.replace(unescapedSingleQuote, escapedSingleQuote);

        String stringWithEscapedQuotesAndParameters = 
            String.format(
                stringWithEscapedSingleQuotes,
                stringParameterList
            );

        return stringWithEscapedQuotesAndParameters;
    }
}
