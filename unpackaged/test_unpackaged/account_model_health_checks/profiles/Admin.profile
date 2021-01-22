<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldPermissions>
        <editable>true</editable>
        <field>Contact.Primary_Active_Account__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Contact.Primary_Address_Type__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Account.An_Active_Record_Type</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities> 
        <default>false</default>
        <recordType>Account.An_Inactive_Record_Type</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <layoutAssignments>
        <layout>Account-HEDA Organization Layout</layout>
        <recordType>Account.An_Active_Record_Type</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-HEDA Organization Layout</layout>
        <recordType>Account.An_Inactive_Record_Type</recordType>
    </layoutAssignments>
</Profile>

