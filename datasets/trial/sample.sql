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
INSERT INTO "Account" VALUES('0013600000L8eNqAAJ','Brown Administrative Account','01236000000CBUWAA4','','','0033600000DkVdFAAV');
INSERT INTO "Account" VALUES('0013600000L8eNsAAJ','Williams Administrative Account','01236000000CBUWAA4','','','0033600000DkVdHAAV');
INSERT INTO "Account" VALUES('0013600000L8eNuAAJ','Brown Administrative Account','01236000000CBUWAA4','','','');
INSERT INTO "Account" VALUES('0013600000L8ZgyAAF','Williams Administrative Account','01236000000CBUWAA4','','','0033600000DkW5oAAF');
INSERT INTO "Account" VALUES('0013600000L8Zh0AAF','Towne Administrative Account','01236000000CBUWAA4','','','0033600000DkW5qAAF');
INSERT INTO "Account" VALUES('0013600000L8eZ1AAJ','Johnson Administrative Account','01236000000CBUWAA4','','','0033600000DkW5sAAF');
INSERT INTO "Account" VALUES('0013600000L8eZ2AAJ','Chen Administrative Account','01236000000CBUWAA4','','','0033600000DkW5tAAF');
INSERT INTO "Account" VALUES('0013600000L8eZ5AAJ','Andrews Administrative Account','01236000000CBUWAA4','','','0033600000DkW5wAAF');
INSERT INTO "Account" VALUES('0013600000L8eZ6AAJ','Durant Administrative Account','01236000000CBUWAA4','','','0033600000DkW5xAAF');
INSERT INTO "Account" VALUES('0013600000L8ezJAAR','Connected University','01236000000CBUYAA4','','','');
INSERT INTO "Account" VALUES('0013600000L8dxJAAR','BA French Studies','01236000000CBUVAA4','0013600000L8dxRAAR','','');
INSERT INTO "Account" VALUES('0013600000L8dxKAAR','IT Help Desk','01236000000CBUbAAO','','','');
INSERT INTO "Account" VALUES('0013600000L8dxLAAR','Theater Department','01236000000CBUbAAO','0013600000L8dxXAAR','','');
INSERT INTO "Account" VALUES('0013600000L8dxMAAR','Baseball Team','01236000000CBUaAAO','0013600000L8dxeAAB','','');
INSERT INTO "Account" VALUES('0013600000L8dxOAAR','First Graduate','01236000000CBUXAA4','','','');
INSERT INTO "Account" VALUES('0013600000L8dxPAAR','Study Abroad','01236000000CBUbAAO','','','');
INSERT INTO "Account" VALUES('0013600000L8dxQAAR','BS Chemistry','01236000000CBUVAA4','0013600000L8dxXAAR','','');
INSERT INTO "Account" VALUES('0013600000L8dxRAAR','French Department','01236000000CBUbAAO','0013600000L8dxXAAR','','');
INSERT INTO "Account" VALUES('0013600000L8dxSAAR','Basketball Team','01236000000CBUaAAO','0013600000L8dxeAAB','','');
INSERT INTO "Account" VALUES('0013600000L8dxUAAR','Museum of Connected Art','01236000000CBUXAA4','','','');
INSERT INTO "Account" VALUES('0013600000L8dxVAAR','English Department','01236000000CBUbAAO','0013600000L8dxXAAR','','');
INSERT INTO "Account" VALUES('0013600000L8dxXAAR','College of Arts and Sciences','01236000000CBUbAAO','0013600000L8ezJAAR','','');
INSERT INTO "Account" VALUES('0013600000L8dxYAAR','Math Department','01236000000CBUbAAO','0013600000L8dxXAAR','','0033600001knoH0AAI');
INSERT INTO "Account" VALUES('0013600000L8dxZAAR','Bio4Good','01236000000CBUXAA4','','','');
INSERT INTO "Account" VALUES('0013600000L8dxaAAB','MS Applied Mathematics','01236000000CBUVAA4','0013600000L8dxYAAR','','');
INSERT INTO "Account" VALUES('0013600000L8dxbAAB','MA History','01236000000CBUVAA4','0013600000L8dxXAAR','','');
INSERT INTO "Account" VALUES('0013600000L8dxcAAB','MA English Literature','01236000000CBUVAA4','0013600000L8dxVAAR','','');
INSERT INTO "Account" VALUES('0013600000L8dxdAAB','Normal High School','01236000000CBUYAA4','','','');
INSERT INTO "Account" VALUES('0013600000L8dxeAAB','Athletics Department','01236000000CBUbAAO','','','');
INSERT INTO "Account" VALUES('0013600000L9jcxAAB','Williams Household','01236000000CBUZAA4','','','');
INSERT INTO "Account" VALUES('0013600000L9mbHAAR','Brown Administrative Account','01236000000CBUWAA4','','','0033600000DlhrRAAR');
INSERT INTO "Account" VALUES('0011Q000028s0eFQAQ','user Administrative Account','01236000000CBUWAA4','','','');
INSERT INTO "Account" VALUES('0013600000L9GjlAAF','Brown Administrative Account','01236000000CBUWAA4','','','0033600000DlAc1AAF');
INSERT INTO "Account" VALUES('0013600000L9GiEAAV','Brown Administrative Account','01236000000CBUWAA4','','','0033600000DlAa9AAF');
CREATE TABLE "Account_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Account_rt_mapping" VALUES('01236000000CBUVAA4','Academic_Program');
INSERT INTO "Account_rt_mapping" VALUES('01236000000CBUWAA4','Administrative');
INSERT INTO "Account_rt_mapping" VALUES('01236000000CBUXAA4','Business_Organization');
INSERT INTO "Account_rt_mapping" VALUES('01236000000CBUYAA4','Educational_Institution');
INSERT INTO "Account_rt_mapping" VALUES('01236000000CBUZAA4','HH_Account');
INSERT INTO "Account_rt_mapping" VALUES('01236000000CBUaAAO','Sports_Organization');
INSERT INTO "Account_rt_mapping" VALUES('01236000000CBUbAAO','University_Department');
CREATE TABLE "Case" (
	sf_id VARCHAR(255) NOT NULL, 
	"IsEscalated" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"hed__Category__c" VARCHAR(255), 
	"hed__Location__c" VARCHAR(255), 
	"hed__Occurrence_Date__c" VARCHAR(255), 
	account_id VARCHAR(255), 
	contact_id VARCHAR(255), 
	parent_id VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Case" VALUES('5001Q00000rcbPpQAI','false','0121Q000001QHhSQAW','School Code of Conduct','On Campus','2019-09-19T15:00:00.000Z','0013600000L8ezJAAR','0033600000DkW5oAAF','');
CREATE TABLE "Case_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Case_rt_mapping" VALUES('0121Q000001QHhSQAW','Incident');
CREATE TABLE "Contact" (
	sf_id VARCHAR(255) NOT NULL, 
	"FirstName" VARCHAR(255), 
	"LastName" VARCHAR(255), 
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
	primary_student_organization__c VARCHAR(255), 
	reports_to_id VARCHAR(255), 
	hed__current_address__c VARCHAR(255), 
	hed__primary_household__c VARCHAR(255), 
	hed__primary_language__c VARCHAR(255), 
	hed__primary_organization__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Contact" VALUES('0033600000DkVdFAAV','Michael','Brown','false','false','false','','','','','false','false','','','false','false','false','false','false','Male','','false','','false','','','','Home','','','','','','','','false','0013600000L8eNqAAJ','','','','','','','','','a0H1Q00000eJ2GDUA0','');
INSERT INTO "Contact" VALUES('0033600000DkVdHAAV','John','Williams','false','false','false','','','','','false','false','','','false','false','false','false','false','Male','','false','','false','','','','Home','','','','','','','','false','0013600000L8eNsAAJ','0013600000L8dxQAAR','','','','','','','0013600000L9jcxAAB','','0013600000L8dxZAAR');
INSERT INTO "Contact" VALUES('0033600000DkW5oAAF','William','Williams','false','false','false','','','United States','United States','false','false','','','false','false','false','true','false','Male','','false','','false','','Home','University','Work','','','Home','XXX-XX-5555','wwilliams@connectedu.edu','','','true','0013600000L8ZgyAAF','0013600000L8dxaAAB','','','','','','a0036000003iujmAAA','0013600000L9jcxAAB','','0013600000L8dxZAAR');
INSERT INTO "Contact" VALUES('0033600000DkW5qAAF','Thomas','Towne','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','Home','','','','','','','','false','0013600000L8Zh0AAF','','','','','','','','','','');
INSERT INTO "Contact" VALUES('0033600000DkW5sAAF','Jake','Johnson','false','false','false','','','United States','United States','false','false','','','false','false','false','false','false','Male','','false','','false','','Mobile','University','Home','','','','XXX-XX-5555','jjohnson@example.com','','','false','0013600000L8eZ1AAJ','','0013600000L8dxVAAR','','','','','','','','0013600000L8dxOAAR');
INSERT INTO "Contact" VALUES('0033600000DkW5tAAF','William','Chen','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','Home','','','','','','','','false','0013600000L8eZ2AAJ','','','','','','','','','','');
INSERT INTO "Contact" VALUES('0033600000DkW5wAAF','Angela','Andrews','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','Home','','','','','','','','false','0013600000L8eZ5AAJ','','','','','','','','','','');
INSERT INTO "Contact" VALUES('0033600000DkW5xAAF','Tracy','Durant','false','false','false','','','','','false','false','','','false','false','false','false','false','Female','','false','','false','','','','Home','','','','','','','','false','0013600000L8eZ6AAJ','0013600000L8dxQAAR','','','','','','','0013600000L9jcxAAB','','0013600000L8dxZAAR');
INSERT INTO "Contact" VALUES('0033600000DlAc1AAF','Richard','Brown','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','Home','','','','','','','','false','0013600000L9GjlAAF','','','','','','','','','','');
INSERT INTO "Contact" VALUES('0033600000DlAa9AAF','Janet','Brown','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','Home','','','','','','','','false','0013600000L9GiEAAV','','','','','','','','','','');
INSERT INTO "Contact" VALUES('0033600000DlhrRAAR','Robert','Brown','false','false','false','','','United States of America (the)','United States of America (the)','false','false','','','false','false','false','true','false','Male','','false','','false','','','','Home','','','','XXX-XX-5555','','','','false','0013600000L9mbHAAR','0013600000L8dxJAAR','','0013600000L8dxdAAB','','','','','','','0013600000L8dxUAAR');
INSERT INTO "Contact" VALUES('0033600001knoH0AAI','Mary','Jefferson','false','false','false','','','','','false','false','','','false','false','false','false','false','','','false','','false','','','','','','','','','','','','false','0013600000L8dxYAAR','','','','','','','','','','');
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
INSERT INTO "hed__Address__c" VALUES('a0036000003iujlAAA','Home','true','','2016-05-17','Pleasant Grove','United States','84062','Utah','','128 East main street','','','','','','','0013600000L8ZgyAAF','');
INSERT INTO "hed__Address__c" VALUES('a0036000003iujmAAA','Work','false','','2016-05-17','Pleasant Grove','United States','84062','Utah','','128 East main street','','','','','','','0013600000L8ZgyAAF','');
INSERT INTO "hed__Address__c" VALUES('a0036000003iui1AAA','Home','true','','2016-05-17','Beacon','United States of America','12509','NY','','100 Main St','','','','','','','0013600000L8dxdAAB','');
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
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P1a3AAC','','','true','','','Current','0013600000L9jcxAAB','0033600000DkW5oAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P1fiAAC','','','false','Athlete','','Current','0013600000L8dxMAAR','0033600000DkW5sAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P4Z9AAK','','','true','Student','2012-09-03','Current','0013600000L8dxdAAB','0033600000DlhrRAAR');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P1ZtAAK','','','true','','','Current','0013600000L9jcxAAB','0033600000DkVdHAAV');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P4oRAAS','','','true','Student','2016-01-04','Current','0013600000L8dxaAAB','0033600000DkW5oAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P2vNAAS','','','false','Prospect','','Current','0013600000L8dxcAAB','0033600000DkVdFAAV');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P4jVAAS','','','true','Employee','','Current','0013600000L8dxZAAR','0033600000DkW5xAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P1fnAAC','','','false','Employee','2016-03-01','Current','0013600000L8dxKAAR','0033600000DkW5sAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P4jGAAS','','1960-05-11','true','Student','1956-09-04','Alumni','0013600000L8dxQAAR','0033600000DkW5xAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P4dlAAC','','2015-08-21','true','Intern','2015-06-01','Former','0013600000L8dxUAAR','0033600000DlhrRAAR');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P1efAAC','','','true','Student','','Current','0013600000L8dxVAAR','0033600000DkW5sAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P1fxAAC','','','true','Scholarship Recipient','2014-09-01','Current','0013600000L8dxOAAR','0033600000DkW5sAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P2ujAAC','','','true','Employee','','Current','0013600000L8dxZAAR','0033600000DkVdHAAV');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004PCIEAA4','','','false','Teaching Assistant','2015-09-07','Current','0013600000L8dxYAAR','0033600000DkW5oAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004PCQ0AAO','','','true','Employee','','Current','0013600000L8dxZAAR','0033600000DkW5oAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P2vSAAS','','','false','Prospect','','Current','0013600000L8dxbAAB','0033600000DkVdFAAV');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P2u5AAC','','1960-05-11','true','Student','1956-09-04','Alumni','0013600000L8dxQAAR','0033600000DkVdHAAV');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004PCIpAAO','Transfer to MS in Applied Mathematics','2015-12-18','false','Student','2015-09-07','Transfer Out','0013600000L8dxcAAB','0033600000DkW5oAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P1ZyAAK','','','true','','','Current','0013600000L9jcxAAB','0033600000DkW5xAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P1g7AAC','','','false','Applicant','','Current','0013600000L8dxPAAR','0033600000DkW5sAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P4ZEAA0','','','true','Prospect','','Current','0013600000L8dxJAAR','0033600000DlhrRAAR');
INSERT INTO "hed__Affiliation__c" VALUES('a0136000004P1fTAAS','','','false','Athlete','','Current','0013600000L8dxSAAR','0033600000DkW5sAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a013600000nbM08AAE','','','false','Faculty','','Current','0013600000L8dxYAAR','0033600001knoH0AAI');
INSERT INTO "hed__Affiliation__c" VALUES('a011Q00000xdgLSQAY','','','false','Faculty','','Current','0013600000L8dxYAAR','0033600000DkW5oAAF');
INSERT INTO "hed__Affiliation__c" VALUES('a011Q00000xdgLhQAI','','','false','Student','','Current','0013600000L8dxaAAB','0033600000DkW5wAAF');
CREATE TABLE "hed__Application__c" (
	id INTEGER NOT NULL, 
	PRIMARY KEY (id)
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
INSERT INTO "hed__Attendance_Event__c" VALUES('a0M1Q00000EznTmUAJ','','Class Absence','2019-10-28','','Doctors Appointment','Medical','','false','0033600000DkW5wAAF','a031Q00001uNjxxQAC');
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
INSERT INTO "hed__Attribute__c" VALUES('a0N1Q00000WJOlnUAH','Mild Hearing Impairment','','Accommodation','','','','','','0033600000DkW5wAAF');
CREATE TABLE "hed__Attribute__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "hed__Attribute__c_rt_mapping" VALUES('0121Q000001QGWZQA4','Credential');
INSERT INTO "hed__Attribute__c_rt_mapping" VALUES('0121Q000001QGWaQAO','Student_Characteristic');
CREATE TABLE "hed__Behavior_Involvement__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Description__c" VARCHAR(255), 
	"hed__Role__c" VARCHAR(255), 
	hed__case__c VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Behavior_Involvement__c" VALUES('a0O1Q00000KNR1GUAX','','Victim','5001Q00000rcbPpQAI','0033600000DkW5wAAF');
INSERT INTO "hed__Behavior_Involvement__c" VALUES('a0O1Q00000KNR1BUAX','I witnessed the bullying of a student in the campus parking lot.','Witness','5001Q00000rcbPpQAI','0033600000DkW5oAAF');
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
INSERT INTO "hed__Behavior_Response__c" VALUES('a0P1Q00000RNBUXUA5','Have reported incident to administration.','','2019-09-19','In Progress','Other','');
INSERT INTO "hed__Behavior_Response__c" VALUES('a0P1Q00000RNBV1UAP','Reported the incident to administration. I also spoke with the student.','','2019-09-19','In Progress','Other','a0O1Q00000KNR1BUAX');
CREATE TABLE "hed__Contact_Language__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Fluency__c" VARCHAR(255), 
	"hed__Primary_Language__c" VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	hed__language__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Contact_Language__c" VALUES('a0G1Q00000kQ567UAC','Intermediate','false','0033600000DkVdFAAV','a0H1Q00000eJ2GNUA0');
INSERT INTO "hed__Contact_Language__c" VALUES('a0G1Q00000kQ54BUAS','Fluent','true','0033600000DkVdFAAV','a0H1Q00000eJ2GDUA0');
CREATE TABLE "hed__Course_Enrollment__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"RecordTypeId" VARCHAR(255), 
	"hed__Credits_Attempted__c" VARCHAR(255), 
	"hed__Credits_Earned__c" VARCHAR(255), 
	"hed__Grade__c" VARCHAR(255), 
	hed__account__c VARCHAR(255), 
	hed__affiliation__c VARCHAR(255), 
	hed__contact__c VARCHAR(255), 
	hed__course_offering__c VARCHAR(255), 
	hed__program_enrollment__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Course_Enrollment__c" VALUES('a0336000004XkoOAAS','01236000000OIx4AAG','3.0','','','0013600000L8dxaAAB','','0033600000DkW5oAAF','a0436000003gpZfAAI','a0836000005H9tyAAC');
INSERT INTO "hed__Course_Enrollment__c" VALUES('a0336000004XkpMAAS','01236000000OIx4AAG','3.0','','','0013600000L8dxaAAB','','0033600000DkW5oAAF','a0436000003gpZkAAI','a0836000005H9tyAAC');
INSERT INTO "hed__Course_Enrollment__c" VALUES('a0336000004XkqZAAS','01236000000OIx4AAG','3.0','','','0013600000L8dxaAAB','','0033600000DkW5oAAF','a0436000003gpZVAAY','a0836000005H9tyAAC');
INSERT INTO "hed__Course_Enrollment__c" VALUES('a0336000004XkxpAAC','01236000000OIx4AAG','3.0','','','0013600000L8dxaAAB','','0033600000DkW5oAAF','a0436000003gpZuAAI','a0836000005H9tyAAC');
INSERT INTO "hed__Course_Enrollment__c" VALUES('a033600001cpP4IAAU','01236000000OIx9AAG','','','','0013600000L8dxYAAR','a013600000nbM08AAE','0033600001knoH0AAI','a0436000003gpZVAAY','');
INSERT INTO "hed__Course_Enrollment__c" VALUES('a031Q00001uNjxxQAC','01236000000OIx4AAG','','','','0013600000L8dxaAAB','','0033600000DkW5wAAF','a041Q00000nRJPFQA4','a081Q00001GcfsEQAR');
INSERT INTO "hed__Course_Enrollment__c" VALUES('a031Q00001uNjxsQAC','01236000000OIx9AAG','','','','0013600000L8dxYAAR','a011Q00000xdgLSQAY','0033600000DkW5oAAF','a041Q00000nRJPFQA4','');
CREATE TABLE "hed__Course_Enrollment__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "hed__Course_Enrollment__c_rt_mapping" VALUES('0121Q000001M5CdQAK','Default');
INSERT INTO "hed__Course_Enrollment__c_rt_mapping" VALUES('01236000000OIx9AAG','Faculty');
INSERT INTO "hed__Course_Enrollment__c_rt_mapping" VALUES('01236000000OIx4AAG','Student');
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
INSERT INTO "hed__Course_Offering_Schedule__c" VALUES('a0J1Q00000UF9yUUAT','','true','true','false','','false','false','false','true','a0436000003gpZVAAY','a0I1Q00000SCsqIUAT','a0L1Q00000Kr9IFUAZ');
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
INSERT INTO "hed__Course_Offering__c" VALUES('a0436000003gpitAAA','ENG 260 Fall 2012','','2012-12-14','1','2012-09-03','a0536000004UOz0AAG','','','a0C36000001hWo4EAE','');
INSERT INTO "hed__Course_Offering__c" VALUES('a0436000003gpZkAAI','APMA 420 Spring 2018','','2016-05-20','1','2016-01-04','a0536000004UOyqAAG','','','a0C36000001hWmAEAU','');
INSERT INTO "hed__Course_Offering__c" VALUES('a0436000003gpebAAA','ENG 230 Fall 2012','','2012-12-14','1','2012-09-03','a0536000004UOygAAG','','','a0C36000001hWo4EAE','');
INSERT INTO "hed__Course_Offering__c" VALUES('a0436000003gpZVAAY','APMA 401 Spring 2018','','2016-05-20','1','2016-01-04','a0536000004UTpQAAW','','0033600001knoH0AAI','a0C36000001hWmAEAU','');
INSERT INTO "hed__Course_Offering__c" VALUES('a0436000003gpegAAA','ENG 260 Fall 2006','','2006-12-15','1','2006-09-04','a0536000004UOz0AAG','','','a0C36000001hWkgEAE','');
INSERT INTO "hed__Course_Offering__c" VALUES('a0436000003gpZfAAI','APMA 410 Spring 2018','','2016-05-20','1','2016-01-04','a0536000004UTp6AAG','','','a0C36000001hWmAEAU','');
INSERT INTO "hed__Course_Offering__c" VALUES('a0436000003gpeRAAQ','ENG 220 Fall 2012','','2012-12-14','1','2012-09-03','a0536000004UTpGAAW','','','a0C36000001hWo4EAE','');
INSERT INTO "hed__Course_Offering__c" VALUES('a0436000003gpZuAAI','APMA 430 Spring 2018','','2016-05-20','1','2016-01-04','a0536000004UTpLAAW','','','a0C36000001hWmAEAU','');
INSERT INTO "hed__Course_Offering__c" VALUES('a0436000003gpeWAAQ','ENG 230 Fall 2006','','2006-12-15','1','2006-09-04','a0536000004UOygAAG','','','a0C36000001hWkgEAE','');
INSERT INTO "hed__Course_Offering__c" VALUES('a0436000003gpeMAAQ','ENG 220 Fall 2006','','2006-12-15','1','2006-09-04','a0536000004UTpGAAW','','','a0C36000001hWkgEAE','');
INSERT INTO "hed__Course_Offering__c" VALUES('a041Q00000nRJPFQA4','APMA 430 Fall 2019','25.0','2020-03-09','','2019-11-11','a0536000004UTp6AAG','a0I1Q00000SCsqNUAT','0033600000DkW5oAAF','a0C1Q00000IlVTDUA3','');
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
INSERT INTO "hed__Course__c" VALUES('a0536000004UOz0AAG','Great Books of the Western World','ENG 260','3.0','','','0013600000L8dxVAAR');
INSERT INTO "hed__Course__c" VALUES('a0536000004UOyqAAG','Applied functional analysis','APMA 420','3.0','','','0013600000L8dxYAAR');
INSERT INTO "hed__Course__c" VALUES('a0536000004UOygAAG','American Literature','ENG 230','3.0','','','0013600000L8dxVAAR');
INSERT INTO "hed__Course__c" VALUES('a0536000004UTpGAAW','Introduction to Literary Studies','ENG 220','3.0','','','0013600000L8dxVAAR');
INSERT INTO "hed__Course__c" VALUES('a0536000004UTpQAAW','Principles of applied mathematics','APMA 401','3.0','','','0013600000L8dxYAAR');
INSERT INTO "hed__Course__c" VALUES('a0536000004UTpLAAW','Partial differential equations','APMA 430','3.0','','','0013600000L8dxYAAR');
INSERT INTO "hed__Course__c" VALUES('a0536000004UTp6AAG','Introduction to dynamical systems','APMA 410','3.0','','','0013600000L8dxYAAR');
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
INSERT INTO "hed__Facility__c" VALUES('a0I1Q00000SCsqNUAT','Room 201','','','Classroom','0013600000L8ezJAAR','a0I1Q00000SCsqIUAT');
INSERT INTO "hed__Facility__c" VALUES('a0I1Q00000SCsqIUAT','Thomas Edison Building','','','Building','0013600000L8ezJAAR','');
CREATE TABLE "hed__Language__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Language__c" VALUES('a0H1Q00000eJ2GNUA0','German');
INSERT INTO "hed__Language__c" VALUES('a0H1Q00000eJ2GDUA0','English');
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
INSERT INTO "hed__Plan_Requirement__c" VALUES('a0E3600000VsCr5EAF','Electives','Optional','','','','','','a0F3600000KeFOUEA3');
INSERT INTO "hed__Plan_Requirement__c" VALUES('a0E3600000VsCrFEAV','Principles of Applied Mathematics','Required','5.0','','','a0536000004UTpQAAW','a0E3600000VsCqpEAF','');
INSERT INTO "hed__Plan_Requirement__c" VALUES('a0E3600000VsCqpEAF','Core Courses','Required','15.0','','1.0','','','a0F3600000KeFOUEA3');
INSERT INTO "hed__Plan_Requirement__c" VALUES('a0E3600000VsCrZEAV','Partial Differential Equations','Required','5.0','','','a0536000004UTpLAAW','a0E3600000VsCqpEAF','');
INSERT INTO "hed__Plan_Requirement__c" VALUES('a0E3600000VsCrPEAV','Applied Functional Analysis','Required','5.0','','','a0536000004UOyqAAG','a0E3600000VsCqpEAF','');
INSERT INTO "hed__Plan_Requirement__c" VALUES('a0E3600000VsCreEAF','Independent Research','Optional','4.0','','','','','a0F3600000KeFOUEA3');
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
INSERT INTO "hed__Program_Enrollment__c" VALUES('a0836000005H9tyAAC','2017-11-04','','','30.0','','false','','Full-time','','2020','2018-01-04','0013600000L8dxaAAB','a0136000004P4oRAAS','0033600000DkW5oAAF','a0F3600000KeFOUEA3');
INSERT INTO "hed__Program_Enrollment__c" VALUES('a081Q00001GcfsEQAR','','','','','','false','','','','','','0013600000L8dxaAAB','a011Q00000xdgLhQAI','0033600000DkW5wAAF','a0F3600000KeFOUEA3');
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
INSERT INTO "hed__Program_Plan__c" VALUES('a0F3600000KeFOUEA3','MS Applied Mathematics 2018','','','true','','Current','120.0','2018','0013600000L8dxaAAB');
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
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002OngiEAC','','false','false','Current','Husband','0033600000DlAa9AAF','a0B36000002OngjEAC','0033600000DlAc1AAF');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002OngjEAC','','false','true','Current','Wife','0033600000DlAc1AAF','a0B36000002OngiEAC','0033600000DlAa9AAF');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002Onq6EAC','','false','false','Current','Son','0033600000DkW5xAAF','a0B36000002Onq7EAC','0033600000DkW5oAAF');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002Onq7EAC','','false','true','Current','Mother','0033600000DkW5oAAF','a0B36000002Onq6EAC','0033600000DkW5xAAF');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002On59EAC','','false','false','Former','Advisee','0033600000DkW5wAAF','a0B36000002On5AEAS','0033600000DkW5sAAF');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002On5AEAS','','false','true','Former','Advisor','0033600000DkW5sAAF','a0B36000002On59EAC','0033600000DkW5wAAF');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002OnbbEAC','','false','false','Current','Advisor','0033600000DkW5sAAF','a0B36000002OnbcEAC','0033600000DkW5qAAF');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002OnbcEAC','','false','true','Current','Advisee','0033600000DkW5qAAF','a0B36000002OnbbEAC','0033600000DkW5sAAF');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002OnhvEAC','','false','false','Former','Wife','0033600000DkVdHAAV','a0B36000002OnhwEAC','0033600000DkW5xAAF');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002OnhwEAC','','false','true','Former','Husband','0033600000DkW5xAAF','a0B36000002OnhvEAC','0033600000DkVdHAAV');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002Oni5EAC','','true','false','Current','Father','0033600000DkVdFAAV','a0B36000002Oni6EAC','0033600000DlAc1AAF');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002Oni6EAC','','false','true','Current','Son','0033600000DlAc1AAF','a0B36000002Oni5EAC','0033600000DkVdFAAV');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002OnhqEAC','','false','false','Current','Son','0033600000DkVdHAAV','a0B36000002OnhrEAC','0033600000DkW5oAAF');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002OnhrEAC','','false','true','Current','Father','0033600000DkW5oAAF','a0B36000002OnhqEAC','0033600000DkVdHAAV');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002OniyEAC','','false','false','Current','Son','0033600000DkVdFAAV','a0B36000002OnizEAC','0033600000DlhrRAAR');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002OnizEAC','','false','true','Current','Father','0033600000DlhrRAAR','a0B36000002OniyEAC','0033600000DkVdFAAV');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002Onh2EAC','','false','false','Current','Son','0033600000DlAa9AAF','a0B36000002Onh3EAC','0033600000DkVdFAAV');
INSERT INTO "hed__Relationship__c" VALUES('a0B36000002Onh3EAC','','false','true','Current','Mother','0033600000DkVdFAAV','a0B36000002Onh2EAC','0033600000DlAa9AAF');
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
INSERT INTO "hed__Term_Grade__c" VALUES('a0K1Q00000XJBGXUA5','','','','','','Pass','Exam Grade','','a031Q00001uNjxxQAC','','a0C1Q00000IlVTDUA3');
INSERT INTO "hed__Term_Grade__c" VALUES('a0K1Q00000Wc1DuUAJ','','','A+','100.0','100.0','Pass','Mid-Term Grade','','a033600001cpP4IAAU','','a0C36000001hWmAEAU');
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
INSERT INTO "hed__Term__c" VALUES('a0C36000001hWkgEAE','Fall 2006','2006-12-15','','','2006-09-04','School Year','0013600000L8ezJAAR','');
INSERT INTO "hed__Term__c" VALUES('a0C36000001hWo4EAE','Fall 2012','2012-12-14','','','2012-09-03','School Year','0013600000L8ezJAAR','');
INSERT INTO "hed__Term__c" VALUES('a0C36000001hWmAEAU','Spring 2018','2018-05-20','','','2018-01-04','School Year','0013600000L8ezJAAR','');
INSERT INTO "hed__Term__c" VALUES('a0C1Q00000IlVTDUA3','Fall 2019','2020-03-09','','','2019-11-11','Semester','0013600000L8ezJAAR','');
CREATE TABLE "hed__Test_Score__c" (
	id INTEGER NOT NULL, 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Test__c" (
	id INTEGER NOT NULL, 
	PRIMARY KEY (id)
);
CREATE TABLE "hed__Time_Block__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__End_Time__c" VARCHAR(255), 
	"hed__Start_Time__c" VARCHAR(255), 
	hed__educational_institution__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Time_Block__c" VALUES('a0L1Q00000Kr9IFUAZ','APMA 401 Spring 2018','08:45:00.000Z','07:30:00.000Z','0013600000L8ezJAAR');
INSERT INTO "hed__Time_Block__c" VALUES('a0L1Q00000Kr9IAUAZ','General Hours','22:00:00.000Z','08:00:00.000Z','0013600000L8ezJAAR');
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
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000aTfeXUAS','a0D1Q00000aTfeX','true','false','CCON_PreventUpdate_TDTM','','','1.0','Course_Enrollment__c','hed','BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000aUScCUAW','a0D1Q00000aUScC','true','false','TERM_CannotDelete_TDTM','','','1.0','Term__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000Yr2MzUAJ','a0D1Q00000Yr2Mz','true','false','CLAN_PrimaryLanguage_TDTM','','','1.0','Contact_Language__c','hed','AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof7tEAB','a0D3600000Lof7t','true','false','AFFL_AccChange_TDTM','','','2.0','Affiliation__c','hed','AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof7uEAB','a0D3600000Lof7u','true','false','AFFL_ContactChange_TDTM','','','2.0','Affiliation__c','hed','AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof7vEAB','a0D3600000Lof7v','true','false','AFFL_MultiRecordType_TDTM','','','3.0','Affiliation__c','hed','BeforeInsert;AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof7wEAB','a0D3600000Lof7w','true','false','AFFL_AccRecordType_TDTM','','','1.0','Account','hed','AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof7xEAB','a0D3600000Lof7x','true','false','REL_Relationships_Cm_TDTM','','','1.0','CampaignMember','hed','AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof7yEAB','a0D3600000Lof7y','true','false','REL_Relationships_Con_TDTM','','','3.0','Contact','hed','AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof7zEAB','a0D3600000Lof7z','true','false','REL_Relationships_TDTM','','','1.0','Relationship__c','hed','AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof80EAB','a0D3600000Lof80','true','false','ADDR_Addresses_TDTM','','','1.0','Address__c','hed','BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof81EAB','a0D3600000Lof81','true','false','ADDR_Contact_TDTM','','','2.0','Contact','hed','BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof82EAB','a0D3600000Lof82','true','false','ADDR_Account_TDTM','','','1.0','Account','hed','BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof7sEAB','a0D3600000Lof7s','true','false','ACCT_IndividualAccounts_TDTM','','','1.0','Contact','hed','AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof83EAB','a0D3600000Lof83','true','false','CON_DoNotContact_TDTM','','','2.0','Contact','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof8BEAR','a0D3600000Lof8B','true','false','ACCT_CannotDelete_TDTM','','','1.0','Account','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof8CEAR','a0D3600000Lof8C','true','false','CENR_AcademicProgram_TDTM','','','1.0','Course_Enrollment__c','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof8DEAR','a0D3600000Lof8D','true','false','CCON_Faculty_TDTM','','','1.0','Course_Enrollment__c','hed','BeforeInsert;AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof84EAB','a0D3600000Lof84','true','false','CON_Preferred_TDTM','','','3.0','Contact','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof85EAB','a0D3600000Lof85','true','false','CON_PrimaryAffls_TDTM','','','4.0','Contact','hed','AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof86EAB','a0D3600000Lof86','true','false','PREN_Affiliation_TDTM','','','1.0','Program_Enrollment__c','hed','BeforeInsert;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof87EAB','a0D3600000Lof87','true','false','COFF_Affiliation_TDTM','','','1.0','Course_Offering__c','hed','BeforeDelete;AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof88EAB','a0D3600000Lof88','true','false','THAN_Filter_TDTM','','','1.0','Trigger_Handler__c','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof89EAB','a0D3600000Lof89','true','false','TERM_CourseOff_TDTM','','','1.0','Term__c','hed','AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000Lof8AEAR','a0D3600000Lof8A','true','false','CON_CannotDelete_TDTM','','','1.0','Contact','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000Yti42UAB','a0D1Q00000Yti42','true','false','CON_PreferredPhone_TDTM','','','4.0','Contact','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000YrD5uUAF','a0D1Q00000YrD5u','true','false','CON_PrimaryLanguage_TDTM','','','5.0','Contact','hed','AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000aUdHvUAK','a0D1Q00000aUdHv','true','false','CCON_CannotDelete_TDTM','','','1.0','Course_Enrollment__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000aWf2dUAC','a0D1Q00000aWf2d','true','false','CASE_CannotDelete_TDTM','','','1.0','Case','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000anNpPUAU','a0D1Q00000anNpP','true','false','BEH_CannotDelete_TDTM','','','1.0','Behavior_Involvement__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000aoAF6UAM','a0D1Q00000aoAF6','true','false','ADDR_CannotDelete_TDTM','','','1.0','Address__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000aoAF7UAM','a0D1Q00000aoAF7','true','false','COUR_CannotDelete_TDTM','','','1.0','Course__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000YuZT8UAN','a0D1Q00000YuZT8','true','false','TGRD_ValidateData_TDTM','','','1.0','Term_Grade__c','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000aVDnGUAW','a0D1Q00000aVDnG','true','false','COFF_CannotDelete_TDTM','','','1.0','Course_Offering__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000X9YWJUA3','a0D1Q00000X9YWJ','true','false','PREN_ProgramPlan_TDTM','','','1.0','Program_Enrollment__c','hed','BeforeInsert','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000SbdQhEAJ','a0D3600000SbdQh','true','false','PPlan_Primary_TDTM','','','1.0','Program_Plan__c','hed','AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000SbdQiEAJ','a0D3600000SbdQi','true','false','PPlan_CannotDelete_TDTM','','','1.0','Program_Plan__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000SbdQjEAJ','a0D3600000SbdQj','true','false','PReq_CannotDelete_TDTM','','','1.0','Plan_Requirement__c','hed','BeforeDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D3600000PXks2EAD','a0D3600000PXks2','true','false','THAN_ClearCache_TDTM','','','2.0','Trigger_Handler__c','hed','AfterInsert;AfterUpdate;AfterDelete','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000YsxCGUAZ','a0D1Q00000YsxCG','true','false','COS_StartEndTime_TDTM','','','1.0','Course_Offering_Schedule__c','hed','BeforeInsert;BeforeUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000YsxCHUAZ','a0D1Q00000YsxCH','true','false','TB_StartEndTime_TDTM','','','1.0','Time_Block__c','hed','AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000YsxCIUAZ','a0D1Q00000YsxCI','true','false','PREQ_PreventPPlanParent_TDTM','','','1.0','Plan_Requirement__c','hed','AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0D1Q00000Yt6ytUAB','a0D1Q00000Yt6yt','true','false','ATTD_CourseConnectionContact_TDTM','','','1.0','Attendance_Event__c','hed','AfterInsert;AfterUpdate','false','');
COMMIT;
