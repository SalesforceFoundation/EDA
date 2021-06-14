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
 * @description Model class for a Salesforce User
 */
public with sharing class UserModel {

    public Id id {get; private set;}
    public String name {get; private set;}
    public Boolean isActive {get; private set;}
    public String email {get; private set;}
    public String smallPhotoUrl {get; private set;}

    /******************************************************************************************
     * @description constructor
     * @param  id The id of the user
     * @param  name The name of the user, representing a concatenated first name and last name
     * @param  isActive Whether or not the user is active
     * @param  email The user's email address
     * @param  smallPhotoUrl A url string for the small photo url for the user
     * @return A UserModel with all properties populated.
     ******************************************************************************************/
    public UserModel(
        Id id,
        String name,
        Boolean isActive,
        String email,
        String smallPhotoUrl
    ) {
        this.id = id;
        this.name = name;
        this.isActive = isActive;
        this.email = email;
        this.smallPhotoUrl = smallPhotoUrl;
    }
}
