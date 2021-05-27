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
 * @description Model class for Error Settings in EDA settings
 */
public with sharing class ErrorSettingsModel {
    public Boolean storeErrors { get; private set; }
    public Boolean sendErrorNotifications { get; private set; }
    public Boolean enableDebug { get; private set; }
    public Boolean errorHandling { get; private set; }

    /******************************************************************************************
     * @description constructor
     * @param  storeErrors A boolen indicating whether error storing functionality is enabled
     * @param  sendErrorNotifications A boolen indicating whether send error notifications
     * functionality is enabled
     * @param  enableDebug A boolen indicating whether debug functionality is enabled
     * @param  errorHandling A boolen indicating whether error handling functionality is enabled
     * @return A ErrorSettingsModel with all properties populated.
     ******************************************************************************************/
    public ErrorSettingsModel(
        Boolean storeErrors,
        Boolean sendErrorNotifications,
        Boolean enableDebug,
        Boolean errorHandling
    ) {
        this.storeErrors = storeErrors;
        this.sendErrorNotifications = sendErrorNotifications;
        this.enableDebug = enableDebug;
        this.errorHandling = errorHandling;
    }
}
