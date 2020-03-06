BEGIN TRANSACTION;
CREATE TABLE "Account" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	parent_id VARCHAR(255), 
	hed__current_address__c VARCHAR(255), 
	hed__primary_contact__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Account" VALUES('001170000157ve2AAA','Columbia University','01217000001U89HAAS','','','');
INSERT INTO "Account" VALUES('001170000157ve3AAA','Barnard College','01217000001U89HAAS','','','');
INSERT INTO "Account" VALUES('001170000157ve4AAA','Masters in Social Work','01217000001U89EAAS','001170000157ve2AAA','','');
INSERT INTO "Account" VALUES('001170000157ve5AAA','Bachelors in Social Work','01217000001U89EAAS','001170000157ve2AAA','','');
INSERT INTO "Account" VALUES('001170000157ve6AAA','Psychology Department','01217000001U89KAAS','','','');
INSERT INTO "Account" VALUES('001170000157ve7AAA','Social Work Department','01217000001U89KAAS','','','');
INSERT INTO "Account" VALUES('001170000157ve8AAA','Soccer Club','01217000001U89JAAS','','','');
INSERT INTO "Account" VALUES('001170000157ve9AAA','Fencing Club','01217000001U89JAAS','','','');
INSERT INTO "Account" VALUES('001170000157veAAAQ','Bernie''s Café','01217000001U89GAAS','','','');
INSERT INTO "Account" VALUES('001170000157veBAAQ','Ambiance Boutique','01217000001U89GAAS','','','');
INSERT INTO "Account" VALUES('001170000157veCAAQ','School of Hard Knox','01217000001U89HAAS','','','');
INSERT INTO "Account" VALUES('001170000157veDAAQ','Brakebills Academy','01217000001U89HAAS','','','');
INSERT INTO "Account" VALUES('001170000157veEAAQ','Physical Magic','01217000001U89KAAS','001170000157veDAAQ','','');
INSERT INTO "Account" VALUES('001170000157veFAAQ','Psychic (Mental) Magic','01217000001U89KAAS','001170000157veDAAQ','','');
INSERT INTO "Account" VALUES('001170000157veGAAQ','Natural Magic','01217000001U89KAAS','001170000157veDAAQ','','');
INSERT INTO "Account" VALUES('001170000157veHAAQ','Illusions','01217000001U89KAAS','001170000157veDAAQ','','');
INSERT INTO "Account" VALUES('001170000157veIAAQ','Healing','01217000001U89KAAS','001170000157veDAAQ','','');
INSERT INTO "Account" VALUES('001170000157veJAAQ','Department of Paranormal Activity','01217000001U89KAAS','001170000157veCAAQ','','');
INSERT INTO "Account" VALUES('001170000157veKAAQ','Ghost Hunting Program','01217000001U89EAAS','001170000157veJAAQ','','');
INSERT INTO "Account" VALUES('001170000157veLAAQ','X-Files Program','01217000001U89EAAS','001170000157veJAAQ','','');
INSERT INTO "Account" VALUES('001170000157vjAAAQ','Coldwater Administrative Account','01217000001U89FAAS','','','00317000011OSztAAG');
INSERT INTO "Account" VALUES('001170000157vjBAAQ','Wicker Administrative Account','01217000001U89FAAS','','','00317000011OSzuAAG');
INSERT INTO "Account" VALUES('001170000157vjMAAQ','der Weghe Administrative Account','01217000001U89FAAS','','','00317000011OT05AAG');
INSERT INTO "Account" VALUES('001170000157vjNAAQ','Mulder Administrative Account','01217000001U89FAAS','','','00317000011OT06AAG');
INSERT INTO "Account" VALUES('001170000157vjCAAQ','Quinn Administrative Account','01217000001U89FAAS','','','00317000011OSzvAAG');
INSERT INTO "Account" VALUES('001170000157vjDAAQ','Waugh Administrative Account','01217000001U89FAAS','','','00317000011OSzwAAG');
INSERT INTO "Account" VALUES('001170000157vjEAAQ','Hoberman Administrative Account','01217000001U89FAAS','','','00317000011OSzxAAG');
INSERT INTO "Account" VALUES('001170000157vjFAAQ','Schroeder Administrative Account','01217000001U89FAAS','','','00317000011OSzyAAG');
INSERT INTO "Account" VALUES('001170000157vjGAAQ','Orloff-Diaz Administrative Account','01217000001U89FAAS','','','00317000011OSzzAAG');
INSERT INTO "Account" VALUES('001170000157vjHAAQ','Quinn Administrative Account','01217000001U89FAAS','','','00317000011OT00AAG');
INSERT INTO "Account" VALUES('001170000157vjIAAQ','Quinn Administrative Account','01217000001U89FAAS','','','00317000011OT01AAG');
INSERT INTO "Account" VALUES('001170000157vjJAAQ','Diaz Administrative Account','01217000001U89FAAS','','','00317000011OT02AAG');
INSERT INTO "Account" VALUES('001170000157vjKAAQ','Fogg Administrative Account','01217000001U89FAAS','','','00317000011OT03AAG');
INSERT INTO "Account" VALUES('001170000157vjLAAQ','Mayakovsky Administrative Account','01217000001U89FAAS','','','00317000011OT04AAG');
INSERT INTO "Account" VALUES('001170000157vjOAAQ','Scully Administrative Account','01217000001U89FAAS','','','00317000011OT07AAG');
INSERT INTO "Account" VALUES('001170000157vjPAAQ','Doggett Administrative Account','01217000001U89FAAS','','','00317000011OT08AAG');
INSERT INTO "Account" VALUES('001170000157vjQAAQ','Reyes Administrative Account','01217000001U89FAAS','','','00317000011OT09AAG');
INSERT INTO "Account" VALUES('001170000157vjRAAQ','Skinner Administrative Account','01217000001U89FAAS','','','00317000011OT0AAAW');
INSERT INTO "Account" VALUES('001170000157vjSAAQ','Krycek Administrative Account','01217000001U89FAAS','','','00317000011OT0BAAW');
INSERT INTO "Account" VALUES('001170000157veqAAA','Injury Treatment Program','01217000001U89EAAS','001170000157veIAAQ','','');
INSERT INTO "Account" VALUES('001170000157verAAA','Endocronology Program','01217000001U89EAAS','001170000157veIAAQ','','');
INSERT INTO "Account" VALUES('001170000157vesAAA','Quaeromancy Program','01217000001U89EAAS','001170000157veHAAQ','','');
INSERT INTO "Account" VALUES('001170000157vetAAA','Probability Magic Program','01217000001U89EAAS','001170000157veHAAQ','','');
INSERT INTO "Account" VALUES('001170000157veuAAA','Sense Magic Program','01217000001U89EAAS','001170000157veHAAQ','','');
INSERT INTO "Account" VALUES('001170000157vevAAA','Horomancy Program','01217000001U89EAAS','001170000157veHAAQ','','');
INSERT INTO "Account" VALUES('001170000157vewAAA','Herbalism Program','01217000001U89EAAS','001170000157veGAAQ','','');
INSERT INTO "Account" VALUES('001170000157vexAAA','Plant Manipulation Program','01217000001U89EAAS','001170000157veGAAQ','','');
INSERT INTO "Account" VALUES('001170000157veyAAA','Weather Manipulation Program','01217000001U89EAAS','001170000157veGAAQ','','');
INSERT INTO "Account" VALUES('001170000157vezAAA','Telepathy Program','01217000001U89EAAS','001170000157veFAAQ','','');
INSERT INTO "Account" VALUES('001170000157vf0AAA','Mind Control Program','01217000001U89EAAS','001170000157veFAAQ','','');
INSERT INTO "Account" VALUES('001170000157vf1AAA','Memory Magic Program','01217000001U89EAAS','001170000157veFAAQ','','');
INSERT INTO "Account" VALUES('001170000157vf2AAA','Dream Manipulation Program','01217000001U89EAAS','001170000157veFAAQ','','');
INSERT INTO "Account" VALUES('001170000157vf3AAA','Traveling Programg','01217000001U89EAAS','001170000157veFAAQ','','');
INSERT INTO "Account" VALUES('001170000157vf4AAA','Precognition Program','01217000001U89EAAS','001170000157veFAAQ','','');
INSERT INTO "Account" VALUES('001170000157vf5AAA','Premonition Program','01217000001U89EAAS','001170000157veFAAQ','','');
INSERT INTO "Account" VALUES('001170000157vf6AAA','Telekenisis Program','01217000001U89EAAS','001170000157veEAAQ','','');
INSERT INTO "Account" VALUES('001170000157vf7AAA','Temperature Manipulation Program','01217000001U89EAAS','001170000157veEAAQ','','');
INSERT INTO "Account" VALUES('001170000157vf8AAA','Phosphoromancy Program','01217000001U89EAAS','001170000157veEAAQ','','');
INSERT INTO "Account" VALUES('001170000157vf9AAA','Mending Program','01217000001U89EAAS','001170000157veEAAQ','','');
INSERT INTO "Account" VALUES('001170000157vfAAAQ','Portal Creation Program','01217000001U89EAAS','001170000157veEAAQ','','');
INSERT INTO "Account" VALUES('001170000157vfBAAQ','Mixology Program','01217000001U89EAAS','001170000157veEAAQ','','');
INSERT INTO "Account" VALUES('001170000157vfCAAQ','Flight Program','01217000001U89EAAS','001170000157veEAAQ','','');
CREATE TABLE "Account_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Account_rt_mapping" VALUES('01217000001U89EAAS','Academic_Program');
INSERT INTO "Account_rt_mapping" VALUES('01217000001U89FAAS','Administrative');
INSERT INTO "Account_rt_mapping" VALUES('01217000001U89GAAS','Business_Organization');
INSERT INTO "Account_rt_mapping" VALUES('01217000001U89HAAS','Educational_Institution');
INSERT INTO "Account_rt_mapping" VALUES('01217000001U89IAAS','HH_Account');
INSERT INTO "Account_rt_mapping" VALUES('01217000001U89JAAS','Sports_Organization');
INSERT INTO "Account_rt_mapping" VALUES('01217000001U89KAAS','University_Department');
CREATE TABLE "Case" (
	sf_id VARCHAR(255) NOT NULL, 
	"IsEscalated" VARCHAR(255), 
	"IsSelfServiceClosed" VARCHAR(255), 
	"IsStopped" VARCHAR(255), 
	"IsVisibleInSelfService" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"hed__Category__c" VARCHAR(255), 
	"hed__Location__c" VARCHAR(255), 
	"hed__Occurrence_Date__c" VARCHAR(255), 
	account_id VARCHAR(255), 
	contact_id VARCHAR(255), 
	parent_id VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "Case_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
CREATE TABLE "Contact" (
	sf_id VARCHAR(255) NOT NULL, 
	"FirstName" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"CanAllowPortalSelfReg" VARCHAR(255), 
	"DoNotCall" VARCHAR(255), 
	"HasOptedOutOfEmail" VARCHAR(255), 
	"HasOptedOutOfFax" VARCHAR(255), 
	"hed__AlternateEmail__c" VARCHAR(255), 
	"hed__Chosen_Full_Name__c" VARCHAR(255), 
	"hed__Citizenship__c" VARCHAR(255), 
	"hed__Country_of_Origin__c" VARCHAR(255), 
	"hed__Deceased__c" VARCHAR(255), 
	"hed__Do_Not_Contact__c" VARCHAR(255), 
	"hed__Dual_Citizenship__c" VARCHAR(255), 
	"hed__Ethnicity__c" VARCHAR(255), 
	"hed__Exclude_from_Household_Formal_Greeting__c" VARCHAR(255), 
	"hed__Exclude_from_Household_Informal_Greeting__c" VARCHAR(255), 
	"hed__Exclude_from_Household_Name__c" VARCHAR(255), 
	"hed__FERPA__c" VARCHAR(255), 
	"hed__Financial_Aid_Applicant__c" VARCHAR(255), 
	"hed__Gender__c" VARCHAR(255), 
	"hed__HIPAA_Detail__c" VARCHAR(255), 
	"hed__HIPAA__c" VARCHAR(255), 
	"hed__Military_Background__c" VARCHAR(255), 
	"hed__Military_Service__c" VARCHAR(255), 
	"hed__Naming_Exclusions__c" VARCHAR(255), 
	"hed__PreferredPhone__c" VARCHAR(255), 
	"hed__Preferred_Email__c" VARCHAR(255), 
	"hed__Primary_Address_Type__c" VARCHAR(255), 
	"hed__Race__c" VARCHAR(255), 
	"hed__Religion__c" VARCHAR(255), 
	"hed__Secondary_Address_Type__c" VARCHAR(255), 
	"hed__Social_Security_Number__c" VARCHAR(255), 
	"hed__UniversityEmail__c" VARCHAR(255), 
	"hed__WorkEmail__c" VARCHAR(255), 
	"hed__WorkPhone__c" VARCHAR(255), 
	"hed__is_Address_Override__c" VARCHAR(255), 
	account_id VARCHAR(255), 
	primary_academic_program__c VARCHAR(255), 
	primary_department__c VARCHAR(255), 
	primary_educational_institution__c VARCHAR(255), 
	primary_sports_organization__c VARCHAR(255), 
	reports_to_id VARCHAR(255), 
	hed__current_address__c VARCHAR(255), 
	hed__primary_household__c VARCHAR(255), 
	hed__primary_language__c VARCHAR(255), 
	hed__primary_organization__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Contact" VALUES('00317000011OSztAAG','Quentin','Coldwater','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjAAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OSzuAAG','Julia','Wicker','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjBAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OSzvAAG','Alice','Quinn','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjCAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OSzwAAG','Eliot','Waugh','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjDAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OSzxAAG','Josh','Hoberman','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjEAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OSzyAAG','Penny','Schroeder','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjFAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OSzzAAG','Kady','Orloff-Diaz','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjGAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OT00AAG','Daniel','Quinn','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjHAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OT01AAG','Stephanie','Quinn','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjIAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OT02AAG','Hannah','Diaz','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjJAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OT03AAG','Henry','Fogg','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjKAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OT04AAG','Mayakovsky','Mayakovsky','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjLAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OT05AAG','Melanie','der Weghe','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjMAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OT06AAG','Fox','Mulder','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjNAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OT07AAG','Dana','Scully','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjOAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OT08AAG','John','Doggett','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjPAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OT09AAG','Monica','Reyes','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjQAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OT0AAAW','Walter','Skinner','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjRAAQ','','','','','','','','','');
INSERT INTO "Contact" VALUES('00317000011OT0BAAW','Alex','Krycek','false','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','001170000157vjSAAQ','','','','','','','','','');
CREATE TABLE "hed__Address__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Address_Type__c" VARCHAR(255), 
	"hed__Default_Address__c" VARCHAR(255), 
	"hed__Latest_End_Date__c" VARCHAR(255), 
	"hed__Latest_Start_Date__c" VARCHAR(255), 
	"hed__MailingCity__c" VARCHAR(255), 
	"hed__MailingCountry__c" VARCHAR(255), 
	"hed__MailingPostalCode__c" VARCHAR(255), 
	"hed__MailingState__c" VARCHAR(255), 
	"hed__MailingStreet2__c" VARCHAR(255), 
	"hed__MailingStreet__c" VARCHAR(255), 
	"hed__Seasonal_End_Day__c" VARCHAR(255), 
	"hed__Seasonal_End_Month__c" VARCHAR(255), 
	"hed__Seasonal_End_Year__c" VARCHAR(255), 
	"hed__Seasonal_Start_Day__c" VARCHAR(255), 
	"hed__Seasonal_Start_Month__c" VARCHAR(255), 
	"hed__Seasonal_Start_Year__c" VARCHAR(255), 
	hed__parent_account__c VARCHAR(255), 
	hed__parent_contact__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Affiliation__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Description__c" VARCHAR(255), 
	"hed__EndDate__c" VARCHAR(255), 
	"hed__Primary__c" VARCHAR(255), 
	"hed__Role__c" VARCHAR(255), 
	"hed__StartDate__c" VARCHAR(255), 
	"hed__Status__c" VARCHAR(255), 
	hed__account__c VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Affiliation__c" VALUES('a011700000Ae3SPAAZ','','','false','Faculty','','Current','001170000157veJAAQ','00317000011OT06AAG');
INSERT INTO "hed__Affiliation__c" VALUES('a011700000Ae3SQAAZ','','','false','Faculty','','Current','001170000157veJAAQ','00317000011OT07AAG');
INSERT INTO "hed__Affiliation__c" VALUES('a011700000Ae3SRAAZ','','','false','Faculty','','Current','001170000157veJAAQ','00317000011OT0AAAW');
CREATE TABLE "hed__Application__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Applicant_Decision_Date__c" VARCHAR(255), 
	"hed__Application_Date__c" VARCHAR(255), 
	"hed__Application_Decision_Date__c" VARCHAR(255), 
	"hed__Application_Status__c" VARCHAR(255), 
	"hed__Application_Type__c" VARCHAR(255), 
	hed__applicant__c VARCHAR(255), 
	hed__applying_to__c VARCHAR(255), 
	hed__preparer__c VARCHAR(255), 
	hed__term__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Attendance_Event__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Arrival_Time__c" VARCHAR(255), 
	"hed__Attendance_Type__c" VARCHAR(255), 
	"hed__Date__c" VARCHAR(255), 
	"hed__End_Time__c" VARCHAR(255), 
	"hed__Reason_Description__c" VARCHAR(255), 
	"hed__Reason__c" VARCHAR(255), 
	"hed__Start_Time__c" VARCHAR(255), 
	"hed__Unexcused__c" VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	hed__course_connection__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Attribute__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"hed__Attribute_Type__c" VARCHAR(255), 
	"hed__Description__c" VARCHAR(255), 
	"hed__End_Date__c" VARCHAR(255), 
	"hed__Start_Date__c" VARCHAR(255), 
	"hed__Subject_Area__c" VARCHAR(255), 
	hed__agency__c VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Attribute__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
CREATE TABLE "hed__Behavior_Involvement__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Description__c" VARCHAR(255), 
	"hed__Role__c" VARCHAR(255), 
	hed__case__c VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Behavior_Response__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Description__c" VARCHAR(255), 
	"hed__End_Date__c" VARCHAR(255), 
	"hed__Start_Date__c" VARCHAR(255), 
	"hed__Status__c" VARCHAR(255), 
	"hed__Type__c" VARCHAR(255), 
	hed__behavior_involvement__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Contact_Language__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Fluency__c" VARCHAR(255), 
	"hed__Primary_Language__c" VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	hed__language__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Course_Enrollment__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"RecordTypeId" VARCHAR(255), 
	"hed__Credits_Attempted__c" VARCHAR(255), 
	"hed__Credits_Earned__c" VARCHAR(255), 
	"hed__Grade__c" VARCHAR(255), 
	"hed__Primary__c" VARCHAR(255), 
	"hed__Status__c" VARCHAR(255), 
	hed__account__c VARCHAR(255), 
	hed__affiliation__c VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	hed__course_offering__c VARCHAR(255), 
	hed__program_enrollment__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Course_Enrollment__c" VALUES('a0917000009E0ujAAC','01217000001U89ZAAS','','','','true','Current','001170000157veJAAQ','a011700000Ae3SPAAZ','00317000011OT06AAG','a0B17000004T8NWEA0','');
INSERT INTO "hed__Course_Enrollment__c" VALUES('a0917000009E0ukAAC','01217000001U89ZAAS','','','','true','Current','001170000157veJAAQ','a011700000Ae3SQAAZ','00317000011OT07AAG','a0B17000004T8NXEA0','');
INSERT INTO "hed__Course_Enrollment__c" VALUES('a0917000009E0ulAAC','01217000001U89ZAAS','','','','true','Current','001170000157veJAAQ','a011700000Ae3SPAAZ','00317000011OT06AAG','a0B17000004T8NYEA0','');
INSERT INTO "hed__Course_Enrollment__c" VALUES('a0917000009E0umAAC','01217000001U89ZAAS','','','','true','Current','001170000157veJAAQ','a011700000Ae3SQAAZ','00317000011OT07AAG','a0B17000004T8NZEA0','');
INSERT INTO "hed__Course_Enrollment__c" VALUES('a0917000009E0unAAC','01217000001U89ZAAS','','','','true','Current','001170000157veJAAQ','a011700000Ae3SRAAZ','00317000011OT0AAAW','a0B17000004T8NaEAK','');
CREATE TABLE "hed__Course_Enrollment__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "hed__Course_Enrollment__c_rt_mapping" VALUES('01217000001U89YAAS','Default');
INSERT INTO "hed__Course_Enrollment__c_rt_mapping" VALUES('01217000001U89ZAAS','Faculty');
INSERT INTO "hed__Course_Enrollment__c_rt_mapping" VALUES('01217000001U89aAAC','Student');
CREATE TABLE "hed__Course_Offering_Schedule__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__End_Time__c" VARCHAR(255), 
	"hed__Friday__c" VARCHAR(255), 
	"hed__Monday__c" VARCHAR(255), 
	"hed__Saturday__c" VARCHAR(255), 
	"hed__Start_Time__c" VARCHAR(255), 
	"hed__Sunday__c" VARCHAR(255), 
	"hed__Thursday__c" VARCHAR(255), 
	"hed__Tuesday__c" VARCHAR(255), 
	"hed__Wednesday__c" VARCHAR(255), 
	hed__course_offering__c VARCHAR(255), 
	hed__facility__c VARCHAR(255), 
	hed__time_block__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Course_Offering__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__Capacity__c" VARCHAR(255), 
	"hed__End_Date__c" VARCHAR(255), 
	"hed__Section_ID__c" VARCHAR(255), 
	"hed__Start_Date__c" VARCHAR(255), 
	hed__course__c VARCHAR(255), 
	hed__facility__c VARCHAR(255), 
	hed__faculty__c VARCHAR(255), 
	hed__term__c VARCHAR(255), 
	hed__time_block__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Course_Offering__c" VALUES('a0B17000004T8NWEA0','X-Files 101 — The Truth is Out There!','','2020-06-30','','2020-04-01','a0C17000004gpWUEAY','a0E17000006uvKqEAI','00317000011OT06AAG','a0O17000003hU12EAE','a0R17000006k3kvEAA');
INSERT INTO "hed__Course_Offering__c" VALUES('a0B17000004T8NXEA0','X-Files 102 — Deny Everything.','','2020-06-30','','2020-04-01','a0C17000004gpWVEAY','a0E17000006uvL0EAI','00317000011OT07AAG','a0O17000003hU12EAE','a0R17000006k3l0EAA');
INSERT INTO "hed__Course_Offering__c" VALUES('a0B17000004T8NYEA0','X-Files 203 — Believe the Lie.','','2020-09-30','','2020-07-01','a0C17000004gpWWEAY','a0E17000006uvKqEAI','00317000011OT06AAG','a0O17000003hU13EAE','a0R17000006k3kvEAA');
INSERT INTO "hed__Course_Offering__c" VALUES('a0B17000004T8NZEA0','X-Files 204 — All Lies Lead to the Truth.','','2020-09-30','','2020-07-01','a0C17000004gpWXEAY','a0E17000006uvL5EAI','00317000011OT07AAG','a0O17000003hU13EAE','a0R17000006k3l0EAA');
INSERT INTO "hed__Course_Offering__c" VALUES('a0B17000004T8NaEAK','GHB 202 - Advanced Ghostbusting','','2020-09-30','','2020-07-01','a0C17000004gpWYEAY','a0E17000006uvKvEAI','00317000011OT0AAAW','a0O17000003hU13EAE','a0R17000006k3lCEAQ');
CREATE TABLE "hed__Course__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__Course_ID__c" VARCHAR(255), 
	"hed__Credit_Hours__c" VARCHAR(255), 
	"hed__Description__c" VARCHAR(255), 
	"hed__Extended_Description__c" VARCHAR(255), 
	hed__account__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Course__c" VALUES('a0C17000004gpWUEAY','X-Files 101 — The Truth is Out There!','X-Files 101','','','','001170000157veJAAQ');
INSERT INTO "hed__Course__c" VALUES('a0C17000004gpWVEAY','X-Files 102 — Deny Everything.','X-Files 102','','','','001170000157veJAAQ');
INSERT INTO "hed__Course__c" VALUES('a0C17000004gpWWEAY','X-Files 203 — Believe the Lie.','X-Files 203','','','','001170000157veJAAQ');
INSERT INTO "hed__Course__c" VALUES('a0C17000004gpWXEAY','X-Files 204 — All Lies Lead to the Truth.','X-Files 204','','','','001170000157veJAAQ');
INSERT INTO "hed__Course__c" VALUES('a0C17000004gpWYEAY','GHB 202 - Advanced Ghostbusting','GHB (Adv) 202','','','','001170000157veJAAQ');
CREATE TABLE "hed__Error__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Context_Type__c" VARCHAR(255), 
	"hed__Datetime__c" VARCHAR(255), 
	"hed__Email_Sent__c" VARCHAR(255), 
	"hed__Error_Type__c" VARCHAR(255), 
	"hed__Full_Message__c" VARCHAR(255), 
	"hed__Object_Type__c" VARCHAR(255), 
	"hed__Posted_in_Chatter__c" VARCHAR(255), 
	"hed__Record_URL__c" VARCHAR(255), 
	"hed__Stack_Trace__c" VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Facility__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__Capacity__c" VARCHAR(255), 
	"hed__Description__c" VARCHAR(255), 
	"hed__Facility_Type__c" VARCHAR(255), 
	hed__account__c VARCHAR(255), 
	hed__parent_facility__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvKbEAI','Altschul Atrium','70.0','','Lecture Hall','','a0E17000006uvKWEAY');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvL0EAI','Neitherlands Library','','','Library','','');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvKWEAY','ALTSCHUL HALL','','','Building','','');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvL5EAI','Fillory','','','','','');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvKSEAY','Tunnel Gallery','','','Library','','a0E17000006uvKWEAY');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvKTEAY','Brakebills South','','','','','');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvKREAY','James Room','500.0','','Lecture Hall','001170000157ve3AAA','a0E17000006uvKMEAY');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvKMEAY','Barnard Hall','','','Building','001170000157ve3AAA','');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvKNEAY','Millicent Carey McIntosh Student Dining Room','','','Cafeteria/Food Hall','','');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvKOEAY','ELLIOTT HALL','','','Building','','');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvKvEAI','Futter Parlor','20.0','','Classroom','','a0E17000006uvKOEAY');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvKqEAI','Bella & Elsa S. Mehler Parlor','20.0','','Classroom','','a0E17000006uvKOEAY');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvKlEAI','McIntosh Student Dining Room - Buffet (60)','60.0','','Cafeteria/Food Hall','','a0E17000006uvKNEAY');
INSERT INTO "hed__Facility__c" VALUES('a0E17000006uvKgEAI','McIntosh Student Dining Room - Standard (100)','100.0','','Cafeteria/Food Hall','','a0E17000006uvKNEAY');
CREATE TABLE "hed__Language__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaCEAX','English');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaDEAX','Estonian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaEEAX','Espanol');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaFEAX','Fante');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaGEAX','Farsi');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaHEAX','Finnish');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaIEAX','Flemish');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaJEAX','French');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaKEAX','Fukienese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaLEAX','Fula');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaMEAX','Fulani');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaNEAX','Fuzhou');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaOEAX','Gaddang');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaPEAX','Gaelic');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaQEAX','Gaelic-irish');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaREAX','Gaelic-scottish');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaSEAX','Georgian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaTEAX','German');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaUEAX','Gorani');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaVEAX','Greek');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaWEAX','Gujarati');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaXEAX','Haitian Creole');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaYEAX','Hakka');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaZEAX','Hakka-chinese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaaEAH','Hausa');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPabEAH','Hebrew');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPacEAH','Hindi');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPadEAH','Hmong');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaeEAH','Hungarian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPafEAH','Ibanag');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPagEAH','Icelandic');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPahEAH','Igbo');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaiEAH','Ilocano');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPajEAH','Indonesian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPakEAH','Inuktitut');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPalEAH','Italian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPamEAH','Jakartanese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPanEAH','Japanese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaoEAH','Javanese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPapEAH','Kanjobal');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaqEAH','Karen');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBParEAH','Karenni');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPasEAH','Kashmiri');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPatEAH','Kazakh');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPauEAH','Kikuyu');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPavEAH','Kinyarwanda');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPawEAH','Kirundi');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaxEAH','Korean');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPayEAH','Kosovan');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPazEAH','Kotokoli');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPb0EAH','Krio');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPb1EAH','Kurdish');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPb2EAH','Kurmanji');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPb3EAH','Kyrgyz');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPb4EAH','Lakota');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPb5EAH','Laotian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPb6EAH','Latvian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPb7EAH','Lingala');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPb8EAH','Lithuanian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPb9EAH','Luganda');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbAEAX','Maay');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbBEAX','Macedonian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbCEAX','Malay');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbDEAX','Malayalam');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbEEAX','Maltese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbFEAX','Mandarin');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbGEAX','Mandingo');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbHEAX','Mandinka');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbIEAX','Marathi');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbJEAX','Marshallese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbKEAX','Mirpuri');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbLEAX','Mixteco');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbMEAX','Moldavan');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbNEAX','Mongolian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbOEAX','Montenegrin');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbPEAX','Navajo');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbQEAX','Neapolitan');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbREAX','Nepali');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbSEAX','Nigerian Pidgin');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbTEAX','Norwegian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbUEAX','Oromo');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbVEAX','Pahari');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbWEAX','Papago');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbXEAX','Papiamento');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbYEAX','Pashto');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbZEAX','Patois');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbaEAH','Pidgin English');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbbEAH','Polish');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbcEAH','Portug.creole');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbdEAH','Portuguese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbeEAH','Pothwari');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbfEAH','Pulaar');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbgEAH','Punjabi');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbhEAH','Putian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbiEAH','Quichua');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbjEAH','Romanian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbkEAH','Russian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPblEAH','Samoan');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbmEAH','Serbian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbnEAH','Shanghainese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPboEAH','Shona');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbpEAH','Sichuan');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbqEAH','Sicilian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbrEAH','Sinhalese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbsEAH','Slovak');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbtEAH','Somali');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbuEAH','Sorani');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbvEAH','Spanish');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbwEAH','Sudanese Arabic');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbxEAH','Sundanese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbyEAH','Susu');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPbzEAH','Swahili');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPc0EAH','Swedish');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPc1EAH','Sylhetti');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPc2EAH','Tagalog');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPc3EAH','Taiwanese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPc4EAH','Tajik');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPc5EAH','Tamil');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPc6EAH','Telugu');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPc7EAH','Thai');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPc8EAH','Tibetan');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPc9EAH','Tigre');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcAEAX','Tigrinya');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcBEAX','Toishanese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcCEAX','Tongan');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcDEAX','Toucouleur');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcEEAX','Trique');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcFEAX','Tshiluba');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcGEAX','Turkish');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcHEAX','Ukrainian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcIEAX','Urdu');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcJEAX','Uyghur');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcKEAX','Uzbek');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcLEAX','Vietnamese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcMEAX','Visayan');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcNEAX','Welsh');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcOEAX','Wolof');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcPEAX','Yiddish');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcQEAX','Yoruba');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPcREAX','Yupik');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZdEAP','Acholi');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZeEAP','Afrikaans');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZfEAP','Albanian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZgEAP','Amharic');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZhEAP','Arabic');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZiEAP','Ashante');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZjEAP','Assyrian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZkEAP','Azerbaijani');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZlEAP','Azeri');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZmEAP','Bajuni');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZnEAP','Basque');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZoEAP','Behdini');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZpEAP','Belorussian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZqEAP','Bengali');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZrEAP','Berber');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZsEAP','Bosnian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZtEAP','Bravanese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZuEAP','Bulgarian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZvEAP','Burmese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZwEAP','Cakchiquel');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZxEAP','Cambodian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZyEAP','Cantonese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPZzEAP','Catalan');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPa0EAH','Chaldean');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPa1EAH','Chamorro');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPa2EAH','Chao-chow');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPa3EAH','Chavacano');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPa4EAH','Chuukese');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPa5EAH','Croatian');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPa6EAH','Czech');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPa7EAH','Danish');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPa8EAH','Dari');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPa9EAH','Dinka');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaAEAX','Diula');
INSERT INTO "hed__Language__c" VALUES('a0G1700000NBPaBEAX','Dutch');
CREATE TABLE "hed__Plan_Requirement__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__Category__c" VARCHAR(255), 
	"hed__Credits__c" VARCHAR(255), 
	"hed__Description__c" VARCHAR(255), 
	"hed__Sequence__c" VARCHAR(255), 
	hed__course__c VARCHAR(255), 
	hed__plan_requirement__c VARCHAR(255), 
	hed__program_plan__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Program_Enrollment__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Admission_Date__c" VARCHAR(255), 
	"hed__Application_Submitted_Date__c" VARCHAR(255), 
	"hed__Class_Standing__c" VARCHAR(255), 
	"hed__Credits_Attempted__c" VARCHAR(255), 
	"hed__Credits_Earned__c" VARCHAR(255), 
	"hed__Eligible_to_Enroll__c" VARCHAR(255), 
	"hed__End_Date__c" VARCHAR(255), 
	"hed__Enrollment_Status__c" VARCHAR(255), 
	"hed__GPA__c" VARCHAR(255), 
	"hed__Graduation_Year__c" VARCHAR(255), 
	"hed__Start_Date__c" VARCHAR(255), 
	hed__account__c VARCHAR(255), 
	hed__affiliation__c VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	hed__program_plan__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Program_Plan__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__Description__c" VARCHAR(255), 
	"hed__End_Date__c" VARCHAR(255), 
	"hed__Is_Primary__c" VARCHAR(255), 
	"hed__Start_Date__c" VARCHAR(255), 
	"hed__Status__c" VARCHAR(255), 
	"hed__Total_Required_Credits__c" VARCHAR(255), 
	"hed__Version__c" VARCHAR(255), 
	hed__account__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Relationship__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Description__c" VARCHAR(255), 
	"hed__Emergency_Contact__c" VARCHAR(255), 
	"hed__SYSTEM_SystemCreated__c" VARCHAR(255), 
	"hed__Status__c" VARCHAR(255), 
	"hed__Type__c" VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	hed__reciprocal_relationship__c VARCHAR(255), 
	hed__related_contact__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Term_Grade__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Credits_Attempted__c" VARCHAR(255), 
	"hed__Credits_Earned__c" VARCHAR(255), 
	"hed__Letter_Grade__c" VARCHAR(255), 
	"hed__Numerical_Grade__c" VARCHAR(255), 
	"hed__Percent_Grade__c" VARCHAR(255), 
	"hed__Result__c" VARCHAR(255), 
	"hed__Term_Grade_Type__c" VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	hed__course_connection__c VARCHAR(255), 
	hed__course_offering__c VARCHAR(255), 
	hed__term__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Term__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__End_Date__c" VARCHAR(255), 
	"hed__Grading_Period_Sequence__c" VARCHAR(255), 
	"hed__Instructional_Days__c" VARCHAR(255), 
	"hed__Start_Date__c" VARCHAR(255), 
	"hed__Type__c" VARCHAR(255), 
	hed__account__c VARCHAR(255), 
	hed__parent_term__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU10EAE','2020 - Year','','','','','School Year','001170000157veCAAQ','');
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU11EAE','2020 Winter','2020-03-30','','','2020-01-01','Quarter','001170000157veCAAQ','a0O17000003hU10EAE');
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU12EAE','2020 Spring','2020-06-30','','','2020-04-01','Quarter','001170000157veCAAQ','a0O17000003hU10EAE');
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU13EAE','2020 Summer','2020-09-30','','','2020-07-01','Quarter','001170000157veCAAQ','a0O17000003hU10EAE');
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU14EAE','2020 Fall','2020-12-31','','','2020-10-01','Quarter','001170000157veCAAQ','a0O17000003hU10EAE');
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU15EAE','First Quarter 2021','2021-03-03','','','2021-01-01','Quarter','001170000157veDAAQ','a0O17000003hU19EAE');
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU16EAE','Second Quarter 2021','2021-06-30','','','2021-04-01','Quarter','001170000157veDAAQ','a0O17000003hU19EAE');
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU17EAE','Third Quarter 2021','2021-09-30','','','2021-07-01','Quarter','001170000157veDAAQ','a0O17000003hU19EAE');
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU18EAE','Fourth Quarter 2021','2021-12-01','','','2021-10-01','Quarter','001170000157veDAAQ','a0O17000003hU19EAE');
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU19EAE','2021 - Year','','','','','School Year','001170000157veDAAQ','');
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU0gEAE','March 2020','2020-03-31','','','2020-03-01','Part of Term','001170000157ve2AAA','');
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU1AEAU','First Semester 2020','2020-06-30','','','2020-01-01','Semester','001170000157ve2AAA','a0O17000003hU10EAE');
INSERT INTO "hed__Term__c" VALUES('a0O17000003hU1FEAU','Second Semester 2020','2020-12-31','','','2020-07-01','Semester','001170000157ve2AAA','a0O17000003hU10EAE');
CREATE TABLE "hed__Test_Score__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Percentile__c" VARCHAR(255), 
	"hed__Score__c" VARCHAR(255), 
	"hed__Subject_Area__c" VARCHAR(255), 
	hed__test__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Test__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Date_Received__c" VARCHAR(255), 
	"hed__Source__c" VARCHAR(255), 
	"hed__Test_Date__c" VARCHAR(255), 
	"hed__Test_Type__c" VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Time_Block__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__End_Time__c" VARCHAR(255), 
	"hed__Start_Time__c" VARCHAR(255), 
	hed__educational_institution__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Time_Block__c" VALUES('a0R17000006k3lAEAQ','Lunch','12:50:00.000Z','12:00:00.000Z','');
INSERT INTO "hed__Time_Block__c" VALUES('a0R17000006k3lBEAQ','Fourth Period','13:50:00.000Z','13:00:00.000Z','');
INSERT INTO "hed__Time_Block__c" VALUES('a0R17000006k3lCEAQ','Sixth Period','15:50:00.000Z','15:00:00.000Z','');
INSERT INTO "hed__Time_Block__c" VALUES('a0R17000006k3kvEAA','First Period','10:00:00.000Z','09:00:00.000Z','');
INSERT INTO "hed__Time_Block__c" VALUES('a0R17000006k3l5EAA','Third Period','11:50:00.000Z','11:00:00.000Z','');
INSERT INTO "hed__Time_Block__c" VALUES('a0R17000006k3l0EAA','Second Period','10:50:00.000Z','10:00:00.000Z','');
INSERT INTO "hed__Time_Block__c" VALUES('a0R17000006k3lFEAQ','Fifth Period','14:50:00.000Z','14:00:00.000Z','');
CREATE TABLE "hed__Trigger_Handler__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__Active__c" VARCHAR(255), 
	"hed__Asynchronous__c" VARCHAR(255), 
	"hed__Class__c" VARCHAR(255), 
	"hed__Filter_Field__c" VARCHAR(255), 
	"hed__Filter_Value__c" VARCHAR(255), 
	"hed__Load_Order__c" VARCHAR(255), 
	"hed__Object__c" VARCHAR(255), 
	"hed__Owned_by_Namespace__c" VARCHAR(255), 
	"hed__Trigger_Action__c" VARCHAR(255), 
	"hed__User_Managed__c" VARCHAR(255), 
	"hed__Usernames_to_Exclude__c" VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoJEAQ','a0S17000004jpoJ','true','false','REL_Relationships_Con_TDTM','','','3.0','Contact','hed','AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoKEAQ','a0S17000004jpoK','true','false','REL_Relationships_TDTM','','','1.0','Relationship__c','hed','AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoLEAQ','a0S17000004jpoL','true','false','ADDR_Addresses_TDTM','','','1.0','Address__c','hed','BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoMEAQ','a0S17000004jpoM','true','false','ADDR_Contact_TDTM','','','2.0','Contact','hed','BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoNEAQ','a0S17000004jpoN','true','false','ADDR_Account_TDTM','','','1.0','Account','hed','BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoOEAQ','a0S17000004jpoO','true','false','CON_DoNotContact_TDTM','','','2.0','Contact','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoPEAQ','a0S17000004jpoP','true','false','CON_Preferred_TDTM','','','3.0','Contact','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoQEAQ','a0S17000004jpoQ','true','false','CON_PreferredPhone_TDTM','','','4.0','Contact','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoREAQ','a0S17000004jpoR','true','false','CON_PrimaryAffls_TDTM','','','4.0','Contact','hed','AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoSEAQ','a0S17000004jpoS','true','false','PREN_Affiliation_TDTM','','','1.0','Program_Enrollment__c','hed','BeforeInsert;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoTEAQ','a0S17000004jpoT','true','false','COFF_Affiliation_TDTM','','','1.0','Course_Offering__c','hed','BeforeDelete;AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoUEAQ','a0S17000004jpoU','true','false','THAN_Filter_TDTM','','','1.0','Trigger_Handler__c','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoVEAQ','a0S17000004jpoV','true','false','THAN_ClearCache_TDTM','','','2.0','Trigger_Handler__c','hed','AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoWEAQ','a0S17000004jpoW','true','false','TERM_CourseOff_TDTM','','','1.0','Term__c','hed','AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoXEAQ','a0S17000004jpoX','true','false','CON_CannotDelete_TDTM','','','1.0','Contact','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoYEAQ','a0S17000004jpoY','true','false','ACCT_CannotDelete_TDTM','','','1.0','Account','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoZEAQ','a0S17000004jpoZ','true','false','CENR_AcademicProgram_TDTM','','','1.0','Course_Enrollment__c','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoaEAA','a0S17000004jpoa','true','false','CCON_Faculty_TDTM','','','1.0','Course_Enrollment__c','hed','BeforeInsert;AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpobEAA','a0S17000004jpob','true','false','PPlan_Primary_TDTM','','','1.0','Program_Plan__c','hed','AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpocEAA','a0S17000004jpoc','true','false','PPlan_CannotDelete_TDTM','','','1.0','Program_Plan__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpodEAA','a0S17000004jpod','true','false','PReq_CannotDelete_TDTM','','','1.0','Plan_Requirement__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoeEAA','a0S17000004jpoe','true','false','PREN_ProgramPlan_TDTM','','','1.0','Program_Enrollment__c','hed','BeforeInsert','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpofEAA','a0S17000004jpof','true','false','CLAN_PrimaryLanguage_TDTM','','','1.0','Contact_Language__c','hed','AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpogEAA','a0S17000004jpog','true','false','CON_PrimaryLanguage_TDTM','','','5.0','Contact','hed','AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpohEAA','a0S17000004jpoh','true','false','COS_StartEndTime_TDTM','','','1.0','Course_Offering_Schedule__c','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoiEAA','a0S17000004jpoi','true','false','TB_StartEndTime_TDTM','','','1.0','Time_Block__c','hed','AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpojEAA','a0S17000004jpoj','true','false','PREQ_PreventPPlanParent_TDTM','','','1.0','Plan_Requirement__c','hed','AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpokEAA','a0S17000004jpok','true','false','ATTD_CourseConnectionContact_TDTM','','','1.0','Attendance_Event__c','hed','AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpolEAA','a0S17000004jpol','true','false','TGRD_ValidateData_TDTM','','','1.0','Term_Grade__c','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpomEAA','a0S17000004jpom','true','false','TERM_CannotDelete_TDTM','','','1.0','Term__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jponEAA','a0S17000004jpon','true','false','CCON_PreventUpdate_TDTM','','','1.0','Course_Enrollment__c','hed','BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpooEAA','a0S17000004jpoo','true','false','COFF_CannotDelete_TDTM','','','1.0','Course_Offering__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpopEAA','a0S17000004jpop','true','false','CCON_CannotDelete_TDTM','','','1.0','Course_Enrollment__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoqEAA','a0S17000004jpoq','true','false','CASE_CannotDelete_TDTM','','','1.0','Case','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoDEAQ','a0S17000004jpoD','true','false','ACCT_IndividualAccounts_TDTM','','','1.0','Contact','hed','AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoEEAQ','a0S17000004jpoE','true','false','AFFL_AccChange_TDTM','','','2.0','Affiliation__c','hed','AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoFEAQ','a0S17000004jpoF','true','false','AFFL_ContactChange_TDTM','','','2.0','Affiliation__c','hed','AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoGEAQ','a0S17000004jpoG','true','false','AFFL_MultiRecordType_TDTM','','','3.0','Affiliation__c','hed','BeforeInsert;AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoHEAQ','a0S17000004jpoH','true','false','AFFL_AccRecordType_TDTM','','','1.0','Account','hed','AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S17000004jpoIEAQ','a0S17000004jpoI','true','false','REL_Relationships_Cm_TDTM','','','1.0','CampaignMember','hed','AfterInsert;AfterUpdate','false','');
COMMIT;
