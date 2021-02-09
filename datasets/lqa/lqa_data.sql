BEGIN TRANSACTION;
CREATE TABLE "Account" (
	id INTEGER NOT NULL, 
	"Billing_County__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"School_Code__c" VARCHAR(255), 
	"Shipping_County__c" VARCHAR(255), 
	"ParentId" VARCHAR(255), 
	"Current_Address__c" VARCHAR(255), 
	"Primary_Contact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Account" VALUES(1,'','Student Administrative Account','0120R000002hBqHQAU','','','','','21');
INSERT INTO "Account" VALUES(2,'','test educational','0120R000002hBqJQAU','','','','','');
INSERT INTO "Account" VALUES(3,'','Business Organization','0120R000002hBqIQAU','','','','','');
INSERT INTO "Account" VALUES(4,'','test Administrative Account','0120R000002hBqHQAU','','','','','22');
INSERT INTO "Account" VALUES(5,'','Columbia University','0120R000002hBqJQAU','','','','','');
INSERT INTO "Account" VALUES(6,'','Barnard College','0120R000002hBqJQAU','','','','','');
INSERT INTO "Account" VALUES(7,'','Masters in Social Work','0120R000002hBqGQAU','','','5','','');
INSERT INTO "Account" VALUES(8,'','Bachelors in Social Work','0120R000002hBqGQAU','','','5','','');
INSERT INTO "Account" VALUES(9,'','Psychology Department','0120R000002hBqMQAU','','','','','');
INSERT INTO "Account" VALUES(10,'','Social Work Department','0120R000002hBqMQAU','','','','','');
INSERT INTO "Account" VALUES(11,'','Soccer Club','0120R000002hBqLQAU','','','','','');
INSERT INTO "Account" VALUES(12,'','Fencing Club','0120R000002hBqLQAU','','','','','');
INSERT INTO "Account" VALUES(13,'','Bernie''s Café','0120R000002hBqIQAU','','','','','');
INSERT INTO "Account" VALUES(14,'','Ambiance Boutique','0120R000002hBqIQAU','','','','','');
INSERT INTO "Account" VALUES(15,'','School of Hard Knox','0120R000002hBqJQAU','','','','','');
INSERT INTO "Account" VALUES(16,'','Brakebills Academy','0120R000002hBqJQAU','','','','','');
INSERT INTO "Account" VALUES(17,'','Physical Magic','0120R000002hBqMQAU','','','16','','');
INSERT INTO "Account" VALUES(18,'','Psychic (Mental) Magic','0120R000002hBqMQAU','','','16','','');
INSERT INTO "Account" VALUES(19,'','Natural Magic','0120R000002hBqMQAU','','','16','','');
INSERT INTO "Account" VALUES(20,'','Illusions','0120R000002hBqMQAU','','','16','','');
INSERT INTO "Account" VALUES(21,'','Healing','0120R000002hBqMQAU','','','16','','');
INSERT INTO "Account" VALUES(22,'','Department of Paranormal Activity','0120R000002hBqMQAU','','','15','','');
INSERT INTO "Account" VALUES(23,'','Ghost Hunting Program','0120R000002hBqGQAU','','','22','','');
INSERT INTO "Account" VALUES(24,'','X-Files Program','0120R000002hBqGQAU','','','22','','');
INSERT INTO "Account" VALUES(25,'','Coldwater Administrative Account','0120R000002hBqHQAU','','','','','2');
INSERT INTO "Account" VALUES(26,'','Wicker Administrative Account','0120R000002hBqHQAU','','','','','3');
INSERT INTO "Account" VALUES(27,'','der Weghe Administrative Account','0120R000002hBqHQAU','','','','','14');
INSERT INTO "Account" VALUES(28,'','Mulder Administrative Account','0120R000002hBqHQAU','','','','','15');
INSERT INTO "Account" VALUES(29,'','Quinn Administrative Account','0120R000002hBqHQAU','','','','','4');
INSERT INTO "Account" VALUES(30,'','Waugh Administrative Account','0120R000002hBqHQAU','','','','','5');
INSERT INTO "Account" VALUES(31,'','Hoberman Administrative Account','0120R000002hBqHQAU','','','','','6');
INSERT INTO "Account" VALUES(32,'','Schroeder Administrative Account','0120R000002hBqHQAU','','','','','7');
INSERT INTO "Account" VALUES(33,'','Orloff-Diaz Administrative Account','0120R000002hBqHQAU','','','','','8');
INSERT INTO "Account" VALUES(34,'','Quinn Administrative Account','0120R000002hBqHQAU','','','','','9');
INSERT INTO "Account" VALUES(35,'','Quinn Administrative Account','0120R000002hBqHQAU','','','','','10');
INSERT INTO "Account" VALUES(36,'','Diaz Administrative Account','0120R000002hBqHQAU','','','','','11');
INSERT INTO "Account" VALUES(37,'','Fogg Administrative Account','0120R000002hBqHQAU','','','','','12');
INSERT INTO "Account" VALUES(38,'','Mayakovsky Administrative Account','0120R000002hBqHQAU','','','','','13');
INSERT INTO "Account" VALUES(39,'','Scully Administrative Account','0120R000002hBqHQAU','','','','','16');
INSERT INTO "Account" VALUES(40,'','Doggett Administrative Account','0120R000002hBqHQAU','','','','','17');
INSERT INTO "Account" VALUES(41,'','Reyes Administrative Account','0120R000002hBqHQAU','','','','','18');
INSERT INTO "Account" VALUES(42,'','Skinner Administrative Account','0120R000002hBqHQAU','','','','','19');
INSERT INTO "Account" VALUES(43,'','Krycek Administrative Account','0120R000002hBqHQAU','','','','','20');
INSERT INTO "Account" VALUES(44,'','Injury Treatment Program','0120R000002hBqGQAU','','','21','','');
INSERT INTO "Account" VALUES(45,'','Endocronology Program','0120R000002hBqGQAU','','','21','','');
INSERT INTO "Account" VALUES(46,'','Quaeromancy Program','0120R000002hBqGQAU','','','20','','');
INSERT INTO "Account" VALUES(47,'','Probability Magic Program','0120R000002hBqGQAU','','','20','','');
INSERT INTO "Account" VALUES(48,'','Sense Magic Program','0120R000002hBqGQAU','','','20','','');
INSERT INTO "Account" VALUES(49,'','Horomancy Program','0120R000002hBqGQAU','','','20','','');
INSERT INTO "Account" VALUES(50,'','Herbalism Program','0120R000002hBqGQAU','','','19','','');
INSERT INTO "Account" VALUES(51,'','Plant Manipulation Program','0120R000002hBqGQAU','','','19','','');
INSERT INTO "Account" VALUES(52,'','Weather Manipulation Program','0120R000002hBqGQAU','','','19','','');
INSERT INTO "Account" VALUES(53,'','Telepathy Program','0120R000002hBqGQAU','','','18','','');
INSERT INTO "Account" VALUES(54,'','Mind Control Program','0120R000002hBqGQAU','','','18','','');
INSERT INTO "Account" VALUES(55,'','Memory Magic Program','0120R000002hBqGQAU','','','18','','');
INSERT INTO "Account" VALUES(56,'','Dream Manipulation Program','0120R000002hBqGQAU','','','18','','');
INSERT INTO "Account" VALUES(57,'','Traveling Programg','0120R000002hBqGQAU','','','18','','');
INSERT INTO "Account" VALUES(58,'','Precognition Program','0120R000002hBqGQAU','','','18','','');
INSERT INTO "Account" VALUES(59,'','Premonition Program','0120R000002hBqGQAU','','','18','','');
INSERT INTO "Account" VALUES(60,'','Telekenisis Program','0120R000002hBqGQAU','','','17','','');
INSERT INTO "Account" VALUES(61,'','Temperature Manipulation Program','0120R000002hBqGQAU','','','17','','');
INSERT INTO "Account" VALUES(62,'','Phosphoromancy Program','0120R000002hBqGQAU','','','17','','');
INSERT INTO "Account" VALUES(63,'','Mending Program','0120R000002hBqGQAU','','','17','','');
INSERT INTO "Account" VALUES(64,'','Portal Creation Program','0120R000002hBqGQAU','','','17','','');
INSERT INTO "Account" VALUES(65,'','Mixology Program','0120R000002hBqGQAU','','','17','','');
INSERT INTO "Account" VALUES(66,'','Flight Program','0120R000002hBqGQAU','','','17','','');
INSERT INTO "Account" VALUES(67,'','Student Administrative Account','0120R000002hBqHQAU','','','','','1');
INSERT INTO "Account" VALUES(68,'','Sports Organization','0120R000002hBqLQAU','','','','','');
CREATE TABLE "Account_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Account_rt_mapping" VALUES('0120R000002hBqGQAU','Academic_Program');
INSERT INTO "Account_rt_mapping" VALUES('0120R000002hBqHQAU','Administrative');
INSERT INTO "Account_rt_mapping" VALUES('0120R000002hBqIQAU','Business_Organization');
INSERT INTO "Account_rt_mapping" VALUES('0120R000002hBqJQAU','Educational_Institution');
INSERT INTO "Account_rt_mapping" VALUES('0120R000002hBqKQAU','HH_Account');
INSERT INTO "Account_rt_mapping" VALUES('0120R000002hBqLQAU','Sports_Organization');
INSERT INTO "Account_rt_mapping" VALUES('0120R000002hBqMQAU','University_Department');
CREATE TABLE "Address__c" (
	id INTEGER NOT NULL, 
	"Address_Type__c" VARCHAR(255), 
	"Default_Address__c" VARCHAR(255), 
	"Latest_End_Date__c" VARCHAR(255), 
	"Latest_Start_Date__c" VARCHAR(255), 
	"MailingCity__c" VARCHAR(255), 
	"MailingCountry__c" VARCHAR(255), 
	"MailingCounty__c" VARCHAR(255), 
	"MailingPostalCode__c" VARCHAR(255), 
	"MailingState__c" VARCHAR(255), 
	"MailingStreet2__c" VARCHAR(255), 
	"MailingStreet__c" VARCHAR(255), 
	"Seasonal_End_Day__c" VARCHAR(255), 
	"Seasonal_End_Month__c" VARCHAR(255), 
	"Seasonal_End_Year__c" VARCHAR(255), 
	"Seasonal_Start_Day__c" VARCHAR(255), 
	"Seasonal_Start_Month__c" VARCHAR(255), 
	"Seasonal_Start_Year__c" VARCHAR(255), 
	"Parent_Account__c" VARCHAR(255), 
	"Parent_Contact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Address__c" VALUES(1,'Home','False','','','','','','','','','123 Street','','','','','','','','21');
CREATE TABLE "Affiliation__c" (
	id INTEGER NOT NULL, 
	"Description__c" VARCHAR(255), 
	"EndDate__c" VARCHAR(255), 
	"Primary__c" VARCHAR(255), 
	"Role__c" VARCHAR(255), 
	"StartDate__c" VARCHAR(255), 
	"Status__c" VARCHAR(255), 
	"Account__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Affiliation__c" VALUES(1,'','','False','Student','','Former','2','22');
INSERT INTO "Affiliation__c" VALUES(2,'','','False','Student','','Current','3','22');
INSERT INTO "Affiliation__c" VALUES(3,'','','False','Student','','Current','3','1');
INSERT INTO "Affiliation__c" VALUES(4,'','','False','','','Current','2','1');
INSERT INTO "Affiliation__c" VALUES(5,'','','False','Faculty','','Current','22','15');
INSERT INTO "Affiliation__c" VALUES(6,'','','False','Faculty','','Current','22','16');
INSERT INTO "Affiliation__c" VALUES(7,'','','False','Faculty','','Current','22','19');
INSERT INTO "Affiliation__c" VALUES(8,'','','False','Faculty','','Current','22','15');
INSERT INTO "Affiliation__c" VALUES(9,'','','False','Faculty','','Current','22','16');
INSERT INTO "Affiliation__c" VALUES(10,'','','False','Faculty','','Current','22','19');
CREATE TABLE "Application__c" (
	id INTEGER NOT NULL, 
	"Applicant_Decision_Date__c" VARCHAR(255), 
	"Application_Date__c" VARCHAR(255), 
	"Application_Decision_Date__c" VARCHAR(255), 
	"Application_JSON__c" VARCHAR(255), 
	"Application_Status__c" VARCHAR(255), 
	"Application_Type__c" VARCHAR(255), 
	"Initial_Creation_Date__c" VARCHAR(255), 
	"Applicant__c" VARCHAR(255), 
	"Applying_To__c" VARCHAR(255), 
	"Preparer__c" VARCHAR(255), 
	"Term__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Application__c" VALUES(1,'','','','','','','','1','2','','');
CREATE TABLE "Attendance_Event__c" (
	id INTEGER NOT NULL, 
	"Arrival_Time__c" VARCHAR(255), 
	"Attendance_Type__c" VARCHAR(255), 
	"Date__c" VARCHAR(255), 
	"End_Time__c" VARCHAR(255), 
	"Reason_Description__c" VARCHAR(255), 
	"Reason__c" VARCHAR(255), 
	"Start_Time__c" VARCHAR(255), 
	"Unexcused__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	"Course_Connection__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Attendance_Event__c" VALUES(1,'','','2021-01-19','','','','','False','1','');
CREATE TABLE "Attribute__c" (
	id INTEGER NOT NULL, 
	"Attribute_Type__c" VARCHAR(255), 
	"Description__c" VARCHAR(255), 
	"End_Date__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"Start_Date__c" VARCHAR(255), 
	"Subject_Area__c" VARCHAR(255), 
	"Agency__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Attribute__c" VALUES(1,'','','','Student Characteristic','0120R000002hBqRQAU','','','','1');
INSERT INTO "Attribute__c" VALUES(2,'','','','Credential','0120R000002hBqQQAU','','','','1');
CREATE TABLE "Behavior_Involvement__c" (
	id INTEGER NOT NULL, 
	"Description__c" VARCHAR(255), 
	"Role__c" VARCHAR(255), 
	"Case__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Behavior_Involvement__c" VALUES(1,'','Reporter','1','1');
CREATE TABLE "Behavior_Response__c" (
	id INTEGER NOT NULL, 
	"Description__c" VARCHAR(255), 
	"End_Date__c" VARCHAR(255), 
	"Start_Date__c" VARCHAR(255), 
	"Status__c" VARCHAR(255), 
	"Type__c" VARCHAR(255), 
	"Behavior_Involvement__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Behavior_Response__c" VALUES(1,'','','','','Expulsion','1');
CREATE TABLE "Case" (
	id INTEGER NOT NULL, 
	"Category__c" VARCHAR(255), 
	"IsEscalated" VARCHAR(255), 
	"IsSelfServiceClosed" VARCHAR(255), 
	"IsStopped" VARCHAR(255), 
	"IsVisibleInSelfService" VARCHAR(255), 
	"Location__c" VARCHAR(255), 
	"Occurrence_Date__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"AccountId" VARCHAR(255), 
	"ContactId" VARCHAR(255), 
	"ParentId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Case" VALUES(1,'','False','False','False','True','','','','67','1','');
CREATE TABLE "Case_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Case_rt_mapping" VALUES('0120R000002hBqVQAU','Incident');
CREATE TABLE "Contact" (
	id INTEGER NOT NULL, 
	"AlternateEmail__c" VARCHAR(255), 
	"CanAllowPortalSelfReg" VARCHAR(255), 
	"Chosen_Full_Name__c" VARCHAR(255), 
	"Citizenship_Status__c" VARCHAR(255), 
	"Citizenship__c" VARCHAR(255), 
	"Contact_JSON__c" VARCHAR(255), 
	"Country_of_Origin__c" VARCHAR(255), 
	"Date_Deceased__c" VARCHAR(255), 
	"Deceased__c" VARCHAR(255), 
	"DoNotCall" VARCHAR(255), 
	"Do_Not_Contact__c" VARCHAR(255), 
	"Dual_Citizenship__c" VARCHAR(255), 
	"Ethnicity__c" VARCHAR(255), 
	"Exclude_from_Household_Formal_Greeting__c" VARCHAR(255), 
	"Exclude_from_Household_Informal_Greeting__c" VARCHAR(255), 
	"Exclude_from_Household_Name__c" VARCHAR(255), 
	"FERPA__c" VARCHAR(255), 
	"Financial_Aid_Applicant__c" VARCHAR(255), 
	"FirstName" VARCHAR(255), 
	"Former_First_Name__c" VARCHAR(255), 
	"Former_Last_Name__c" VARCHAR(255), 
	"Former_Middle_Name__c" VARCHAR(255), 
	"Gender__c" VARCHAR(255), 
	"HIPAA_Detail__c" VARCHAR(255), 
	"HIPAA__c" VARCHAR(255), 
	"HasOptedOutOfEmail" VARCHAR(255), 
	"HasOptedOutOfFax" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"Mailing_County__c" VARCHAR(255), 
	"Military_Background__c" VARCHAR(255), 
	"Military_Service__c" VARCHAR(255), 
	"Naming_Exclusions__c" VARCHAR(255), 
	"Other_County__c" VARCHAR(255), 
	"PreferredPhone__c" VARCHAR(255), 
	"Preferred_Email__c" VARCHAR(255), 
	"Primary_Address_Type__c" VARCHAR(255), 
	"Race__c" VARCHAR(255), 
	"Religion__c" VARCHAR(255), 
	"Secondary_Address_Type__c" VARCHAR(255), 
	"Social_Security_Number__c" VARCHAR(255), 
	"UniversityEmail__c" VARCHAR(255), 
	"WorkEmail__c" VARCHAR(255), 
	"WorkPhone__c" VARCHAR(255), 
	"is_Address_Override__c" VARCHAR(255), 
	"AccountId" VARCHAR(255), 
	"Primary_Academic_Program__c" VARCHAR(255), 
	"Primary_Department__c" VARCHAR(255), 
	"Primary_Educational_Institution__c" VARCHAR(255), 
	"Primary_Sports_Organization__c" VARCHAR(255), 
	"ReportsToId" VARCHAR(255), 
	"Current_Address__c" VARCHAR(255), 
	"Primary_Household__c" VARCHAR(255), 
	"Primary_Language__c" VARCHAR(255), 
	"Primary_Organization__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Contact" VALUES(1,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Suzie','','','','','','False','False','False','Student','','','False','','','','','','','','','','','','','False','67','','','','','','','','','');
INSERT INTO "Contact" VALUES(2,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Quentin','','','','','','False','False','False','Coldwater','','','False','','','','','','','','','','','','','False','25','','','','','','','','','');
INSERT INTO "Contact" VALUES(3,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Julia','','','','','','False','False','False','Wicker','','','False','','','','','','','','','','','','','False','26','','','','','','','','','');
INSERT INTO "Contact" VALUES(4,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Alice','','','','','','False','False','False','Quinn','','','False','','','','','','','','','','','','','False','29','','','','','','','','','');
INSERT INTO "Contact" VALUES(5,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Eliot','','','','','','False','False','False','Waugh','','','False','','','','','','','','','','','','','False','30','','','','','','','','','');
INSERT INTO "Contact" VALUES(6,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Josh','','','','','','False','False','False','Hoberman','','','False','','','','','','','','','','','','','False','31','','','','','','','','','');
INSERT INTO "Contact" VALUES(7,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Penny','','','','','','False','False','False','Schroeder','','','False','','','','','','','','','','','','','False','32','','','','','','','','','');
INSERT INTO "Contact" VALUES(8,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Kady','','','','','','False','False','False','Orloff-Diaz','','','False','','','','','','','','','','','','','False','33','','','','','','','','','');
INSERT INTO "Contact" VALUES(9,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Daniel','','','','','','False','False','False','Quinn','','','False','','','','','','','','','','','','','False','34','','','','','','','','','');
INSERT INTO "Contact" VALUES(10,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Stephanie','','','','','','False','False','False','Quinn','','','False','','','','','','','','','','','','','False','35','','','','','','','','','');
INSERT INTO "Contact" VALUES(11,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Hannah','','','','','','False','False','False','Diaz','','','False','','','','','','','','','','','','','False','36','','','','','','','','','');
INSERT INTO "Contact" VALUES(12,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Henry','','','','','','False','False','False','Fogg','','','False','','','','','','','','','','','','','False','37','','','','','','','','','');
INSERT INTO "Contact" VALUES(13,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Mayakovsky','','','','','','False','False','False','Mayakovsky','','','False','','','','','','','','','','','','','False','38','','','','','','','','','');
INSERT INTO "Contact" VALUES(14,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Melanie','','','','','','False','False','False','der Weghe','','','False','','','','','','','','','','','','','False','27','','','','','','','','','');
INSERT INTO "Contact" VALUES(15,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Fox','','','','','','False','False','False','Mulder','','','False','','','','','','','','','','','','','False','28','','','','','','','','','');
INSERT INTO "Contact" VALUES(16,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Dana','','','','','','False','False','False','Scully','','','False','','','','','','','','','','','','','False','39','','','','','','','','','');
INSERT INTO "Contact" VALUES(17,'','False','','','','','','','False','False','False','','','False','False','False','False','False','John','','','','','','False','False','False','Doggett','','','False','','','','','','','','','','','','','False','40','','','','','','','','','');
INSERT INTO "Contact" VALUES(18,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Monica','','','','','','False','False','False','Reyes','','','False','','','','','','','','','','','','','False','41','','','','','','','','','');
INSERT INTO "Contact" VALUES(19,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Walter','','','','','','False','False','False','Skinner','','','False','','','','','','','','','','','','','False','42','','','','','','','','','');
INSERT INTO "Contact" VALUES(20,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Alex','','','','','','False','False','False','Krycek','','','False','','','','','','','','','','','','','False','43','','','','','','','','','');
INSERT INTO "Contact" VALUES(21,'','False','','','','','','','False','False','False','','','False','False','False','False','False','Sandy','','','','','','False','False','False','Student','','','False','','','','','','','','','','','','','False','1','','','','','','','','','');
INSERT INTO "Contact" VALUES(22,'','False','','','','','','','False','False','False','','','False','False','False','False','False','test','','','','','','False','False','False','test','','','False','','','','','','','','','','','','','False','4','','','','','','','','','');
CREATE TABLE "Contact_Language__c" (
	id INTEGER NOT NULL, 
	"Fluency__c" VARCHAR(255), 
	"Language_Details__c" VARCHAR(255), 
	"Primary_Language__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	"Language__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Contact_Language__c" VALUES(1,'','','False','1','1');
CREATE TABLE "Course_Enrollment__c" (
	id INTEGER NOT NULL, 
	"Credits_Attempted__c" VARCHAR(255), 
	"Credits_Earned__c" VARCHAR(255), 
	"Grade__c" VARCHAR(255), 
	"Primary__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"Status__c" VARCHAR(255), 
	"Account__c" VARCHAR(255), 
	"Affiliation__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	"Course_Offering__c" VARCHAR(255), 
	"Program_Enrollment__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Course_Enrollment__c" VALUES(1,'','','','False','0120R000002hBqaQAE','Current','','','22','1','');
INSERT INTO "Course_Enrollment__c" VALUES(2,'','','','False','0120R000002hBqcQAE','Current','','','1','2','');
INSERT INTO "Course_Enrollment__c" VALUES(3,'','','','True','0120R000002hBqbQAE','Current','22','9','15','5','');
INSERT INTO "Course_Enrollment__c" VALUES(4,'','','','True','0120R000002hBqbQAE','Current','22','9','16','4','');
INSERT INTO "Course_Enrollment__c" VALUES(5,'','','','True','0120R000002hBqbQAE','Current','22','9','16','6','');
INSERT INTO "Course_Enrollment__c" VALUES(6,'','','','True','0120R000002hBqbQAE','Current','22','9','19','7','');
INSERT INTO "Course_Enrollment__c" VALUES(7,'','','','True','0120R000002hBqbQAE','Current','22','9','15','3','');
INSERT INTO "Course_Enrollment__c" VALUES(8,'','','','True','0120R000002hBqbQAE','Current','22','10','15','3','');
INSERT INTO "Course_Enrollment__c" VALUES(9,'','','','True','0120R000002hBqbQAE','Current','22','10','16','4','');
INSERT INTO "Course_Enrollment__c" VALUES(10,'','','','True','0120R000002hBqbQAE','Current','22','10','15','5','');
INSERT INTO "Course_Enrollment__c" VALUES(11,'','','','True','0120R000002hBqbQAE','Current','22','10','16','6','');
INSERT INTO "Course_Enrollment__c" VALUES(12,'','','','True','0120R000002hBqbQAE','Current','22','10','19','7','');
INSERT INTO "Course_Enrollment__c" VALUES(13,'','','','True','0120R000002hBqbQAE','Current','22','10','15','3','');
INSERT INTO "Course_Enrollment__c" VALUES(14,'','','','True','0120R000002hBqbQAE','Current','22','10','16','4','');
INSERT INTO "Course_Enrollment__c" VALUES(15,'','','','True','0120R000002hBqbQAE','Current','22','10','15','5','');
INSERT INTO "Course_Enrollment__c" VALUES(16,'','','','True','0120R000002hBqbQAE','Current','22','10','16','6','');
INSERT INTO "Course_Enrollment__c" VALUES(17,'','','','True','0120R000002hBqbQAE','Current','22','10','19','7','');
CREATE TABLE "Course_Offering_Schedule__c" (
	id INTEGER NOT NULL, 
	"End_Time__c" VARCHAR(255), 
	"Friday__c" VARCHAR(255), 
	"Monday__c" VARCHAR(255), 
	"Saturday__c" VARCHAR(255), 
	"Start_Time__c" VARCHAR(255), 
	"Sunday__c" VARCHAR(255), 
	"Thursday__c" VARCHAR(255), 
	"Tuesday__c" VARCHAR(255), 
	"Wednesday__c" VARCHAR(255), 
	"Course_Offering__c" VARCHAR(255), 
	"Facility__c" VARCHAR(255), 
	"Time_Block__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Course_Offering_Schedule__c" VALUES(1,'','False','False','False','','False','False','False','False','','','');
INSERT INTO "Course_Offering_Schedule__c" VALUES(2,'','False','False','False','','False','False','False','False','','','');
INSERT INTO "Course_Offering_Schedule__c" VALUES(3,'','False','False','False','','False','False','False','False','','','');
CREATE TABLE "Course_Offering__c" (
	id INTEGER NOT NULL, 
	"Capacity__c" VARCHAR(255), 
	"End_Date__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Section_ID__c" VARCHAR(255), 
	"Start_Date__c" VARCHAR(255), 
	"Course__c" VARCHAR(255), 
	"Facility__c" VARCHAR(255), 
	"Faculty__c" VARCHAR(255), 
	"Term__c" VARCHAR(255), 
	"Time_Block__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Course_Offering__c" VALUES(1,'','','123','','','2','','','1','');
INSERT INTO "Course_Offering__c" VALUES(2,'','','Test Test','','','1','','','1','');
INSERT INTO "Course_Offering__c" VALUES(3,'','2020-06-30','X-Files 101 — The Truth is Out There!','','2020-04-01','3','10','15','8','4');
INSERT INTO "Course_Offering__c" VALUES(4,'','2020-06-30','X-Files 102 — Deny Everything.','','2020-04-01','4','2','16','8','6');
INSERT INTO "Course_Offering__c" VALUES(5,'','2020-09-30','X-Files 203 — Believe the Lie.','','2020-07-01','5','10','15','9','4');
INSERT INTO "Course_Offering__c" VALUES(6,'','2020-09-30','X-Files 204 — All Lies Lead to the Truth.','','2020-07-01','6','4','16','9','6');
INSERT INTO "Course_Offering__c" VALUES(7,'','2020-09-30','GHB 202 - Advanced Ghostbusting','','2020-07-01','7','9','19','9','3');
CREATE TABLE "Course__c" (
	id INTEGER NOT NULL, 
	"Course_ID__c" VARCHAR(255), 
	"Credit_Hours__c" VARCHAR(255), 
	"Description__c" VARCHAR(255), 
	"Extended_Description__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Account__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Course__c" VALUES(1,'','','','','Course','2');
INSERT INTO "Course__c" VALUES(2,'','','','','test course','4');
INSERT INTO "Course__c" VALUES(3,'X-Files 101','','','','X-Files 101 — The Truth is Out There!','22');
INSERT INTO "Course__c" VALUES(4,'X-Files 102','','','','X-Files 102 — Deny Everything.','22');
INSERT INTO "Course__c" VALUES(5,'X-Files 203','','','','X-Files 203 — Believe the Lie.','22');
INSERT INTO "Course__c" VALUES(6,'X-Files 204','','','','X-Files 204 — All Lies Lead to the Truth.','22');
INSERT INTO "Course__c" VALUES(7,'GHB (Adv) 202','','','','GHB 202 - Advanced Ghostbusting','22');
CREATE TABLE "Education_History__c" (
	id INTEGER NOT NULL, 
	"Class_Percentile__c" VARCHAR(255), 
	"Class_Rank_Scale__c" VARCHAR(255), 
	"Class_Rank_Type__c" VARCHAR(255), 
	"Class_Rank__c" VARCHAR(255), 
	"Class_Size__c" VARCHAR(255), 
	"Degree_Earned__c" VARCHAR(255), 
	"Details__c" VARCHAR(255), 
	"Education_History_JSON__c" VARCHAR(255), 
	"Educational_Institution_Name__c" VARCHAR(255), 
	"End_Date__c" VARCHAR(255), 
	"GPA_Scale_Reporting__c" VARCHAR(255), 
	"GPA_Scale_Type__c" VARCHAR(255), 
	"GPA__c" VARCHAR(255), 
	"Graduation_Date__c" VARCHAR(255), 
	"Start_Date__c" VARCHAR(255), 
	"Account__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Education_History__c" VALUES(1,'','','','','','','','','','','','','','','','','1');
CREATE TABLE "Error__c" (
	id INTEGER NOT NULL, 
	"Context_Type__c" VARCHAR(255), 
	"Datetime__c" VARCHAR(255), 
	"Email_Sent__c" VARCHAR(255), 
	"Error_Type__c" VARCHAR(255), 
	"Full_Message__c" VARCHAR(255), 
	"Object_Type__c" VARCHAR(255), 
	"Posted_in_Chatter__c" VARCHAR(255), 
	"Record_URL__c" VARCHAR(255), 
	"Stack_Trace__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Error__c" VALUES(1,'','2021-01-20T00:25:56.000+0000','False','','','','False','','');
INSERT INTO "Error__c" VALUES(2,'','2021-01-20T04:21:29.000+0000','False','','','','False','','');
CREATE TABLE "Facility__c" (
	id INTEGER NOT NULL, 
	"Capacity__c" VARCHAR(255), 
	"Description__c" VARCHAR(255), 
	"Facility_Type__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Account__c" VARCHAR(255), 
	"Parent_Facility__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Facility__c" VALUES(1,'70.0','','Lecture Hall','Altschul Atrium','','3');
INSERT INTO "Facility__c" VALUES(2,'','','Library','Neitherlands Library','','');
INSERT INTO "Facility__c" VALUES(3,'','','Building','ALTSCHUL HALL','','');
INSERT INTO "Facility__c" VALUES(4,'','','','Fillory','','');
INSERT INTO "Facility__c" VALUES(5,'','','Library','Tunnel Gallery','','3');
INSERT INTO "Facility__c" VALUES(6,'','','','Brakebills South','','');
INSERT INTO "Facility__c" VALUES(7,'','','Cafeteria/Food Hall','Millicent Carey McIntosh Student Dining Room','','');
INSERT INTO "Facility__c" VALUES(8,'','','Building','ELLIOTT HALL','','');
INSERT INTO "Facility__c" VALUES(9,'20.0','','Classroom','Futter Parlor','','8');
INSERT INTO "Facility__c" VALUES(10,'20.0','','Classroom','Bella & Elsa S. Mehler Parlor','','8');
INSERT INTO "Facility__c" VALUES(11,'60.0','','Cafeteria/Food Hall','McIntosh Student Dining Room - Buffet (60)','','7');
INSERT INTO "Facility__c" VALUES(12,'100.0','','Cafeteria/Food Hall','McIntosh Student Dining Room - Standard (100)','','7');
INSERT INTO "Facility__c" VALUES(13,'500.0','','Lecture Hall','James Room','6','14');
INSERT INTO "Facility__c" VALUES(14,'','','Building','Barnard Hall','6','');
CREATE TABLE "Language__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Language__c" VALUES(1,'English');
INSERT INTO "Language__c" VALUES(2,'English');
INSERT INTO "Language__c" VALUES(3,'Estonian');
INSERT INTO "Language__c" VALUES(4,'Espanol');
INSERT INTO "Language__c" VALUES(5,'Fante');
INSERT INTO "Language__c" VALUES(6,'Farsi');
INSERT INTO "Language__c" VALUES(7,'Finnish');
INSERT INTO "Language__c" VALUES(8,'Flemish');
INSERT INTO "Language__c" VALUES(9,'French');
INSERT INTO "Language__c" VALUES(10,'Fukienese');
INSERT INTO "Language__c" VALUES(11,'Fula');
INSERT INTO "Language__c" VALUES(12,'Fulani');
INSERT INTO "Language__c" VALUES(13,'Fuzhou');
INSERT INTO "Language__c" VALUES(14,'Gaddang');
INSERT INTO "Language__c" VALUES(15,'Gaelic');
INSERT INTO "Language__c" VALUES(16,'Gaelic-irish');
INSERT INTO "Language__c" VALUES(17,'Gaelic-scottish');
INSERT INTO "Language__c" VALUES(18,'Georgian');
INSERT INTO "Language__c" VALUES(19,'German');
INSERT INTO "Language__c" VALUES(20,'Gorani');
INSERT INTO "Language__c" VALUES(21,'Greek');
INSERT INTO "Language__c" VALUES(22,'Gujarati');
INSERT INTO "Language__c" VALUES(23,'Haitian Creole');
INSERT INTO "Language__c" VALUES(24,'Hakka');
INSERT INTO "Language__c" VALUES(25,'Hakka-chinese');
INSERT INTO "Language__c" VALUES(26,'Hausa');
INSERT INTO "Language__c" VALUES(27,'Hebrew');
INSERT INTO "Language__c" VALUES(28,'Hindi');
INSERT INTO "Language__c" VALUES(29,'Hmong');
INSERT INTO "Language__c" VALUES(30,'Hungarian');
INSERT INTO "Language__c" VALUES(31,'Ibanag');
INSERT INTO "Language__c" VALUES(32,'Icelandic');
INSERT INTO "Language__c" VALUES(33,'Igbo');
INSERT INTO "Language__c" VALUES(34,'Ilocano');
INSERT INTO "Language__c" VALUES(35,'Indonesian');
INSERT INTO "Language__c" VALUES(36,'Inuktitut');
INSERT INTO "Language__c" VALUES(37,'Italian');
INSERT INTO "Language__c" VALUES(38,'Jakartanese');
INSERT INTO "Language__c" VALUES(39,'Japanese');
INSERT INTO "Language__c" VALUES(40,'Javanese');
INSERT INTO "Language__c" VALUES(41,'Kanjobal');
INSERT INTO "Language__c" VALUES(42,'Karen');
INSERT INTO "Language__c" VALUES(43,'Karenni');
INSERT INTO "Language__c" VALUES(44,'Kashmiri');
INSERT INTO "Language__c" VALUES(45,'Kazakh');
INSERT INTO "Language__c" VALUES(46,'Kikuyu');
INSERT INTO "Language__c" VALUES(47,'Kinyarwanda');
INSERT INTO "Language__c" VALUES(48,'Kirundi');
INSERT INTO "Language__c" VALUES(49,'Korean');
INSERT INTO "Language__c" VALUES(50,'Kosovan');
INSERT INTO "Language__c" VALUES(51,'Kotokoli');
INSERT INTO "Language__c" VALUES(52,'Krio');
INSERT INTO "Language__c" VALUES(53,'Kurdish');
INSERT INTO "Language__c" VALUES(54,'Kurmanji');
INSERT INTO "Language__c" VALUES(55,'Kyrgyz');
INSERT INTO "Language__c" VALUES(56,'Lakota');
INSERT INTO "Language__c" VALUES(57,'Laotian');
INSERT INTO "Language__c" VALUES(58,'Latvian');
INSERT INTO "Language__c" VALUES(59,'Lingala');
INSERT INTO "Language__c" VALUES(60,'Lithuanian');
INSERT INTO "Language__c" VALUES(61,'Luganda');
INSERT INTO "Language__c" VALUES(62,'Maay');
INSERT INTO "Language__c" VALUES(63,'Macedonian');
INSERT INTO "Language__c" VALUES(64,'Malay');
INSERT INTO "Language__c" VALUES(65,'Malayalam');
INSERT INTO "Language__c" VALUES(66,'Maltese');
INSERT INTO "Language__c" VALUES(67,'Mandarin');
INSERT INTO "Language__c" VALUES(68,'Mandingo');
INSERT INTO "Language__c" VALUES(69,'Mandinka');
INSERT INTO "Language__c" VALUES(70,'Marathi');
INSERT INTO "Language__c" VALUES(71,'Marshallese');
INSERT INTO "Language__c" VALUES(72,'Mirpuri');
INSERT INTO "Language__c" VALUES(73,'Mongolian');
INSERT INTO "Language__c" VALUES(74,'Montenegrin');
INSERT INTO "Language__c" VALUES(75,'Navajo');
INSERT INTO "Language__c" VALUES(76,'Neapolitan');
INSERT INTO "Language__c" VALUES(77,'Nepali');
INSERT INTO "Language__c" VALUES(78,'Nigerian Pidgin');
INSERT INTO "Language__c" VALUES(79,'Norwegian');
INSERT INTO "Language__c" VALUES(80,'Oromo');
INSERT INTO "Language__c" VALUES(81,'Pahari');
INSERT INTO "Language__c" VALUES(82,'Papago');
INSERT INTO "Language__c" VALUES(83,'Papiamento');
INSERT INTO "Language__c" VALUES(84,'Pashto');
INSERT INTO "Language__c" VALUES(85,'Patois');
INSERT INTO "Language__c" VALUES(86,'Pidgin English');
INSERT INTO "Language__c" VALUES(87,'Polish');
INSERT INTO "Language__c" VALUES(88,'Mixteco');
INSERT INTO "Language__c" VALUES(89,'Moldavan');
INSERT INTO "Language__c" VALUES(90,'Portug.creole');
INSERT INTO "Language__c" VALUES(91,'Portuguese');
INSERT INTO "Language__c" VALUES(92,'Pothwari');
INSERT INTO "Language__c" VALUES(93,'Pulaar');
INSERT INTO "Language__c" VALUES(94,'Punjabi');
INSERT INTO "Language__c" VALUES(95,'Putian');
INSERT INTO "Language__c" VALUES(96,'Quichua');
INSERT INTO "Language__c" VALUES(97,'Romanian');
INSERT INTO "Language__c" VALUES(98,'Russian');
INSERT INTO "Language__c" VALUES(99,'Samoan');
INSERT INTO "Language__c" VALUES(100,'Serbian');
INSERT INTO "Language__c" VALUES(101,'Shanghainese');
INSERT INTO "Language__c" VALUES(102,'Shona');
INSERT INTO "Language__c" VALUES(103,'Sichuan');
INSERT INTO "Language__c" VALUES(104,'Sicilian');
INSERT INTO "Language__c" VALUES(105,'Sinhalese');
INSERT INTO "Language__c" VALUES(106,'Slovak');
INSERT INTO "Language__c" VALUES(107,'Somali');
INSERT INTO "Language__c" VALUES(108,'Sorani');
INSERT INTO "Language__c" VALUES(109,'Spanish');
INSERT INTO "Language__c" VALUES(110,'Sudanese Arabic');
INSERT INTO "Language__c" VALUES(111,'Sundanese');
INSERT INTO "Language__c" VALUES(112,'Susu');
INSERT INTO "Language__c" VALUES(113,'Swahili');
INSERT INTO "Language__c" VALUES(114,'Swedish');
INSERT INTO "Language__c" VALUES(115,'Sylhetti');
INSERT INTO "Language__c" VALUES(116,'Tagalog');
INSERT INTO "Language__c" VALUES(117,'Taiwanese');
INSERT INTO "Language__c" VALUES(118,'Tajik');
INSERT INTO "Language__c" VALUES(119,'Tamil');
INSERT INTO "Language__c" VALUES(120,'Telugu');
INSERT INTO "Language__c" VALUES(121,'Thai');
INSERT INTO "Language__c" VALUES(122,'Tibetan');
INSERT INTO "Language__c" VALUES(123,'Tigre');
INSERT INTO "Language__c" VALUES(124,'Tigrinya');
INSERT INTO "Language__c" VALUES(125,'Toishanese');
INSERT INTO "Language__c" VALUES(126,'Tongan');
INSERT INTO "Language__c" VALUES(127,'Toucouleur');
INSERT INTO "Language__c" VALUES(128,'Trique');
INSERT INTO "Language__c" VALUES(129,'Tshiluba');
INSERT INTO "Language__c" VALUES(130,'Turkish');
INSERT INTO "Language__c" VALUES(131,'Ukrainian');
INSERT INTO "Language__c" VALUES(132,'Urdu');
INSERT INTO "Language__c" VALUES(133,'Uyghur');
INSERT INTO "Language__c" VALUES(134,'Uzbek');
INSERT INTO "Language__c" VALUES(135,'Vietnamese');
INSERT INTO "Language__c" VALUES(136,'Visayan');
INSERT INTO "Language__c" VALUES(137,'Welsh');
INSERT INTO "Language__c" VALUES(138,'Wolof');
INSERT INTO "Language__c" VALUES(139,'Yiddish');
INSERT INTO "Language__c" VALUES(140,'Yoruba');
INSERT INTO "Language__c" VALUES(141,'Yupik');
INSERT INTO "Language__c" VALUES(142,'Acholi');
INSERT INTO "Language__c" VALUES(143,'Afrikaans');
INSERT INTO "Language__c" VALUES(144,'Albanian');
INSERT INTO "Language__c" VALUES(145,'Amharic');
INSERT INTO "Language__c" VALUES(146,'Arabic');
INSERT INTO "Language__c" VALUES(147,'Ashante');
INSERT INTO "Language__c" VALUES(148,'Assyrian');
INSERT INTO "Language__c" VALUES(149,'Azerbaijani');
INSERT INTO "Language__c" VALUES(150,'Azeri');
INSERT INTO "Language__c" VALUES(151,'Bajuni');
INSERT INTO "Language__c" VALUES(152,'Basque');
INSERT INTO "Language__c" VALUES(153,'Behdini');
INSERT INTO "Language__c" VALUES(154,'Belorussian');
INSERT INTO "Language__c" VALUES(155,'Bengali');
INSERT INTO "Language__c" VALUES(156,'Berber');
INSERT INTO "Language__c" VALUES(157,'Bosnian');
INSERT INTO "Language__c" VALUES(158,'Bravanese');
INSERT INTO "Language__c" VALUES(159,'Bulgarian');
INSERT INTO "Language__c" VALUES(160,'Burmese');
INSERT INTO "Language__c" VALUES(161,'Cakchiquel');
INSERT INTO "Language__c" VALUES(162,'Cambodian');
INSERT INTO "Language__c" VALUES(163,'Cantonese');
INSERT INTO "Language__c" VALUES(164,'Catalan');
INSERT INTO "Language__c" VALUES(165,'Chaldean');
INSERT INTO "Language__c" VALUES(166,'Chamorro');
INSERT INTO "Language__c" VALUES(167,'Chao-chow');
INSERT INTO "Language__c" VALUES(168,'Chavacano');
INSERT INTO "Language__c" VALUES(169,'Chuukese');
INSERT INTO "Language__c" VALUES(170,'Croatian');
INSERT INTO "Language__c" VALUES(171,'Czech');
INSERT INTO "Language__c" VALUES(172,'Danish');
INSERT INTO "Language__c" VALUES(173,'Dari');
INSERT INTO "Language__c" VALUES(174,'Dinka');
INSERT INTO "Language__c" VALUES(175,'Diula');
INSERT INTO "Language__c" VALUES(176,'Dutch');
CREATE TABLE "Plan_Requirement__c" (
	id INTEGER NOT NULL, 
	"Category__c" VARCHAR(255), 
	"Credits__c" VARCHAR(255), 
	"Description__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Sequence__c" VARCHAR(255), 
	"Course__c" VARCHAR(255), 
	"Plan_Requirement__c" VARCHAR(255), 
	"Program_Plan__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Plan_Requirement__c" VALUES(1,'','','','Plan Requirement','','','','');
CREATE TABLE "Program_Enrollment__c" (
	id INTEGER NOT NULL, 
	"Admission_Date__c" VARCHAR(255), 
	"Application_Submitted_Date__c" VARCHAR(255), 
	"Class_Standing__c" VARCHAR(255), 
	"Credits_Attempted__c" VARCHAR(255), 
	"Credits_Earned__c" VARCHAR(255), 
	"Eligible_to_Enroll__c" VARCHAR(255), 
	"End_Date__c" VARCHAR(255), 
	"Enrollment_Status__c" VARCHAR(255), 
	"GPA__c" VARCHAR(255), 
	"Graduation_Year__c" VARCHAR(255), 
	"Start_Date__c" VARCHAR(255), 
	"Account__c" VARCHAR(255), 
	"Affiliation__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	"Program_Plan__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Program_Enrollment__c" VALUES(1,'','','','','','False','','','','','','68','2','22','');
INSERT INTO "Program_Enrollment__c" VALUES(2,'','','','','','False','','','','','','3','3','1','');
CREATE TABLE "Program_Plan__c" (
	id INTEGER NOT NULL, 
	"Description__c" VARCHAR(255), 
	"End_Date__c" VARCHAR(255), 
	"Is_Primary__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Start_Date__c" VARCHAR(255), 
	"Status__c" VARCHAR(255), 
	"Total_Required_Credits__c" VARCHAR(255), 
	"Version__c" VARCHAR(255), 
	"Account__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Program_Plan__c" VALUES(1,'','','False','program Plan','','Current','','','');
INSERT INTO "Program_Plan__c" VALUES(2,'','','False','Test Name','','Current','','','43');
CREATE TABLE "Relationship__c" (
	id INTEGER NOT NULL, 
	"Description__c" VARCHAR(255), 
	"Emergency_Contact__c" VARCHAR(255), 
	"SYSTEM_SystemCreated__c" VARCHAR(255), 
	"Status__c" VARCHAR(255), 
	"Type__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	"ReciprocalRelationship__c" VARCHAR(255), 
	"RelatedContact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Relationship__c" VALUES(1,'','False','False','Current','','1','2','21');
INSERT INTO "Relationship__c" VALUES(2,'','False','True','Current','','21','1','1');
CREATE TABLE "Term_Grade__c" (
	id INTEGER NOT NULL, 
	"Credits_Attempted__c" VARCHAR(255), 
	"Credits_Earned__c" VARCHAR(255), 
	"Letter_Grade__c" VARCHAR(255), 
	"Numerical_Grade__c" VARCHAR(255), 
	"Percent_Grade__c" VARCHAR(255), 
	"Result__c" VARCHAR(255), 
	"Term_Grade_Type__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	"Course_Connection__c" VARCHAR(255), 
	"Course_Offering__c" VARCHAR(255), 
	"Term__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Term_Grade__c" VALUES(1,'','','','','','','Exam Grade','22','1','1','1');
INSERT INTO "Term_Grade__c" VALUES(2,'','','','','','','','1','2','2','');
CREATE TABLE "Term__c" (
	id INTEGER NOT NULL, 
	"End_Date__c" VARCHAR(255), 
	"Grading_Period_Sequence__c" VARCHAR(255), 
	"Instructional_Days__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Start_Date__c" VARCHAR(255), 
	"Type__c" VARCHAR(255), 
	"Account__c" VARCHAR(255), 
	"Parent_Term__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Term__c" VALUES(1,'','','','test term','','','4','');
INSERT INTO "Term__c" VALUES(2,'','','','Spring 21','','','2','');
INSERT INTO "Term__c" VALUES(3,'2020-03-31','','','March 2020','2020-03-01','Part of Term','5','');
INSERT INTO "Term__c" VALUES(4,'2020-06-30','','','First Semester 2020','2020-01-01','Semester','5','6');
INSERT INTO "Term__c" VALUES(5,'2020-12-31','','','Second Semester 2020','2020-07-01','Semester','5','6');
INSERT INTO "Term__c" VALUES(6,'','','','2020 - Year','','School Year','15','');
INSERT INTO "Term__c" VALUES(7,'2020-03-30','','','2020 Winter','2020-01-01','Quarter','15','6');
INSERT INTO "Term__c" VALUES(8,'2020-06-30','','','2020 Spring','2020-04-01','Quarter','15','6');
INSERT INTO "Term__c" VALUES(9,'2020-09-30','','','2020 Summer','2020-07-01','Quarter','15','6');
INSERT INTO "Term__c" VALUES(10,'2020-12-31','','','2020 Fall','2020-10-01','Quarter','15','6');
INSERT INTO "Term__c" VALUES(11,'2021-03-03','','','First Quarter 2021','2021-01-01','Quarter','16','15');
INSERT INTO "Term__c" VALUES(12,'2021-06-30','','','Second Quarter 2021','2021-04-01','Quarter','16','15');
INSERT INTO "Term__c" VALUES(13,'2021-09-30','','','Third Quarter 2021','2021-07-01','Quarter','16','15');
INSERT INTO "Term__c" VALUES(14,'2021-12-01','','','Fourth Quarter 2021','2021-10-01','Quarter','16','15');
INSERT INTO "Term__c" VALUES(15,'','','','2021 - Year','','School Year','16','');
CREATE TABLE "Test_Score__c" (
	id INTEGER NOT NULL, 
	"Percentile__c" VARCHAR(255), 
	"Score__c" VARCHAR(255), 
	"Subject_Area__c" VARCHAR(255), 
	"Test__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Test_Score__c" VALUES(1,'11.0','123.0','Language','1');
INSERT INTO "Test_Score__c" VALUES(2,'','','Mathematics','2');
CREATE TABLE "Test__c" (
	id INTEGER NOT NULL, 
	"Date_Received__c" VARCHAR(255), 
	"Source__c" VARCHAR(255), 
	"Test_Date__c" VARCHAR(255), 
	"Test_Type__c" VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Test__c" VALUES(1,'','','2025-01-19','SAT','22');
INSERT INTO "Test__c" VALUES(2,'','','2021-01-20','SAT','1');
CREATE TABLE "Time_Block__c" (
	id INTEGER NOT NULL, 
	"End_Time__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Start_Time__c" VARCHAR(255), 
	"Educational_Institution__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Time_Block__c" VALUES(1,'12:50:00.000Z','Lunch','12:00:00.000Z','');
INSERT INTO "Time_Block__c" VALUES(2,'13:50:00.000Z','Fourth Period','13:00:00.000Z','');
INSERT INTO "Time_Block__c" VALUES(3,'15:50:00.000Z','Sixth Period','15:00:00.000Z','');
INSERT INTO "Time_Block__c" VALUES(4,'10:00:00.000Z','First Period','09:00:00.000Z','');
INSERT INTO "Time_Block__c" VALUES(5,'11:50:00.000Z','Third Period','11:00:00.000Z','');
INSERT INTO "Time_Block__c" VALUES(6,'10:50:00.000Z','Second Period','10:00:00.000Z','');
INSERT INTO "Time_Block__c" VALUES(7,'14:50:00.000Z','Fifth Period','14:00:00.000Z','');
CREATE TABLE "Trigger_Handler__c" (
	id INTEGER NOT NULL, 
	"Active__c" VARCHAR(255), 
	"Asynchronous__c" VARCHAR(255), 
	"Class__c" VARCHAR(255), 
	"Filter_Field__c" VARCHAR(255), 
	"Filter_Value__c" VARCHAR(255), 
	"Load_Order__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Object__c" VARCHAR(255), 
	"Owned_by_Namespace__c" VARCHAR(255), 
	"Trigger_Action__c" VARCHAR(255), 
	"User_Managed__c" VARCHAR(255), 
	"Usernames_to_Exclude__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Trigger_Handler__c" VALUES(1,'True','False','ACCT_IndividualAccounts_TDTM','','','1.0','a0T0R0000070z8O','Contact','hed','AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(2,'True','False','AFFL_AccChange_TDTM','','','2.0','a0T0R0000070z8P','Affiliation__c','hed','AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(3,'True','False','AFFL_ContactChange_TDTM','','','2.0','a0T0R0000070z8Q','Affiliation__c','hed','AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(4,'True','False','AFFL_MultiRecordType_TDTM','','','3.0','a0T0R0000070z8R','Affiliation__c','hed','BeforeInsert;AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(5,'True','False','AFFL_AccRecordType_TDTM','','','1.0','a0T0R0000070z8S','Account','hed','AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(6,'True','False','REL_Relationships_Cm_TDTM','','','1.0','a0T0R0000070z8T','CampaignMember','hed','AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(7,'True','False','REL_Relationships_Con_TDTM','','','3.0','a0T0R0000070z8U','Contact','hed','AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(8,'True','False','REL_Relationships_TDTM','','','1.0','a0T0R0000070z8V','Relationship__c','hed','AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(9,'True','False','ADDR_Addresses_TDTM','','','1.0','a0T0R0000070z8W','Address__c','hed','BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(10,'True','False','ADDR_Contact_TDTM','','','2.0','a0T0R0000070z8X','Contact','hed','BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(11,'True','False','ADDR_Account_TDTM','','','1.0','a0T0R0000070z8Y','Account','hed','BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(12,'True','False','CON_Preferred_TDTM','','','3.0','a0T0R0000070z8a','Contact','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(13,'True','False','CON_PreferredPhone_TDTM','','','4.0','a0T0R0000070z8b','Contact','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(14,'True','False','CON_PrimaryAffls_TDTM','','','4.0','a0T0R0000070z8c','Contact','hed','AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(15,'True','False','PREN_Affiliation_TDTM','','','1.0','a0T0R0000070z8d','Program_Enrollment__c','hed','BeforeInsert;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(16,'True','False','COFF_Affiliation_TDTM','','','1.0','a0T0R0000070z8e','Course_Offering__c','hed','BeforeDelete;AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(17,'True','False','THAN_Filter_TDTM','','','1.0','a0T0R0000070z8f','Trigger_Handler__c','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(18,'True','False','THAN_ClearCache_TDTM','','','2.0','a0T0R0000070z8g','Trigger_Handler__c','hed','AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(19,'True','False','TERM_CourseOff_TDTM','','','1.0','a0T0R0000070z8h','Term__c','hed','AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(20,'True','False','CON_CannotDelete_TDTM','','','1.0','a0T0R0000070z8i','Contact','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(21,'True','False','ACCT_CannotDelete_TDTM','','','1.0','a0T0R0000070z8j','Account','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(22,'True','False','ADDR_CannotDelete_TDTM','','','1.0','a0T0R0000070z8k','Address__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(23,'True','False','CENR_AcademicProgram_TDTM','','','1.0','a0T0R0000070z8l','Course_Enrollment__c','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(24,'True','False','CCON_Faculty_TDTM','','','1.0','a0T0R0000070z8m','Course_Enrollment__c','hed','BeforeInsert;AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(25,'True','False','PPlan_Primary_TDTM','','','1.0','a0T0R0000070z8n','Program_Plan__c','hed','AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(26,'True','False','PPlan_CannotDelete_TDTM','','','1.0','a0T0R0000070z8o','Program_Plan__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(27,'True','False','PReq_CannotDelete_TDTM','','','1.0','a0T0R0000070z8p','Plan_Requirement__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(28,'True','False','PREN_ProgramPlan_TDTM','','','1.0','a0T0R0000070z8q','Program_Enrollment__c','hed','BeforeInsert','False','');
INSERT INTO "Trigger_Handler__c" VALUES(29,'True','False','CLAN_PrimaryLanguage_TDTM','','','1.0','a0T0R0000070z8r','Contact_Language__c','hed','AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(30,'True','False','CON_PrimaryLanguage_TDTM','','','5.0','a0T0R0000070z8s','Contact','hed','AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(31,'True','False','COS_StartEndTime_TDTM','','','1.0','a0T0R0000070z8t','Course_Offering_Schedule__c','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(32,'True','False','TB_StartEndTime_TDTM','','','1.0','a0T0R0000070z8u','Time_Block__c','hed','AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(33,'True','False','PREQ_PreventPPlanParent_TDTM','','','1.0','a0T0R0000070z8v','Plan_Requirement__c','hed','AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(34,'True','False','ATTD_CourseConnectionContact_TDTM','','','1.0','a0T0R0000070z8w','Attendance_Event__c','hed','AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(35,'True','False','TGRD_ValidateData_TDTM','','','1.0','a0T0R0000070z8x','Term_Grade__c','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(36,'True','False','TERM_CannotDelete_TDTM','','','1.0','a0T0R0000070z8y','Term__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(37,'True','False','CON_DoNotContact_TDTM','','','2.0','a0T0R0000070z8Z','Contact','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(38,'True','False','AFFL_CannotDelete_TDTM','','','1.0','a0T0R0000070z8z','Affiliation__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(39,'True','False','TST_CannotDelete_TDTM','','','1.0','a0T0R0000070z90','Test__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(40,'True','False','CCON_PreventUpdate_TDTM','','','1.0','a0T0R0000070z91','Course_Enrollment__c','hed','BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(41,'True','False','COFF_CannotDelete_TDTM','','','1.0','a0T0R0000070z92','Course_Offering__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(42,'True','False','CCON_CannotDelete_TDTM','','','1.0','a0T0R0000070z93','Course_Enrollment__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(43,'True','False','CASE_CannotDelete_TDTM','','','1.0','a0T0R0000070z94','Case','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(44,'True','False','BEH_CannotDelete_TDTM','','','1.0','a0T0R0000070z95','Behavior_Involvement__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(45,'True','False','FACI_CannotDelete_TDTM','','','1.0','a0T0R0000070z96','Facility__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(46,'True','False','PREN_CannotDelete_TDTM','','','1.0','a0T0R0000070z97','Program_Enrollment__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(47,'True','False','COUR_CannotDelete_TDTM','','','1.0','a0T0R0000070z98','Course__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(48,'True','False','TB_CannotDelete_TDTM','','','1.0','a0T0R0000070z99','Time_Block__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(49,'True','False','test','','','','test','test','','','False','');
INSERT INTO "Trigger_Handler__c" VALUES(50,'True','False','CCON_CannotDelete_TDTM','','','1.0','a0S17000004jpop','Course_Enrollment__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(51,'True','False','REL_Relationships_Con_TDTM','','','3.0','a0S17000004jpoJ','Contact','hed','AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(52,'True','False','REL_Relationships_TDTM','','','1.0','a0S17000004jpoK','Relationship__c','hed','AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(53,'True','False','ADDR_Addresses_TDTM','','','1.0','a0S17000004jpoL','Address__c','hed','BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(54,'True','False','ADDR_Contact_TDTM','','','2.0','a0S17000004jpoM','Contact','hed','BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(55,'True','False','ADDR_Account_TDTM','','','1.0','a0S17000004jpoN','Account','hed','BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(56,'True','False','CON_DoNotContact_TDTM','','','2.0','a0S17000004jpoO','Contact','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(57,'True','False','CON_Preferred_TDTM','','','3.0','a0S17000004jpoP','Contact','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(58,'True','False','CON_PreferredPhone_TDTM','','','4.0','a0S17000004jpoQ','Contact','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(59,'True','False','CON_PrimaryAffls_TDTM','','','4.0','a0S17000004jpoR','Contact','hed','AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(60,'True','False','PREN_Affiliation_TDTM','','','1.0','a0S17000004jpoS','Program_Enrollment__c','hed','BeforeInsert;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(61,'True','False','COFF_Affiliation_TDTM','','','1.0','a0S17000004jpoT','Course_Offering__c','hed','BeforeDelete;AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(62,'True','False','THAN_Filter_TDTM','','','1.0','a0S17000004jpoU','Trigger_Handler__c','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(63,'True','False','THAN_ClearCache_TDTM','','','2.0','a0S17000004jpoV','Trigger_Handler__c','hed','AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(64,'True','False','TERM_CourseOff_TDTM','','','1.0','a0S17000004jpoW','Term__c','hed','AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(65,'True','False','CON_CannotDelete_TDTM','','','1.0','a0S17000004jpoX','Contact','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(66,'True','False','ACCT_CannotDelete_TDTM','','','1.0','a0S17000004jpoY','Account','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(67,'True','False','CENR_AcademicProgram_TDTM','','','1.0','a0S17000004jpoZ','Course_Enrollment__c','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(68,'True','False','CCON_Faculty_TDTM','','','1.0','a0S17000004jpoa','Course_Enrollment__c','hed','BeforeInsert;AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(69,'True','False','PPlan_Primary_TDTM','','','1.0','a0S17000004jpob','Program_Plan__c','hed','AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(70,'True','False','PPlan_CannotDelete_TDTM','','','1.0','a0S17000004jpoc','Program_Plan__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(71,'True','False','PReq_CannotDelete_TDTM','','','1.0','a0S17000004jpod','Plan_Requirement__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(72,'True','False','PREN_ProgramPlan_TDTM','','','1.0','a0S17000004jpoe','Program_Enrollment__c','hed','BeforeInsert','False','');
INSERT INTO "Trigger_Handler__c" VALUES(73,'True','False','CLAN_PrimaryLanguage_TDTM','','','1.0','a0S17000004jpof','Contact_Language__c','hed','AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(74,'True','False','CON_PrimaryLanguage_TDTM','','','5.0','a0S17000004jpog','Contact','hed','AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(75,'True','False','COS_StartEndTime_TDTM','','','1.0','a0S17000004jpoh','Course_Offering_Schedule__c','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(76,'True','False','TB_StartEndTime_TDTM','','','1.0','a0S17000004jpoi','Time_Block__c','hed','AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(77,'True','False','PREQ_PreventPPlanParent_TDTM','','','1.0','a0S17000004jpoj','Plan_Requirement__c','hed','AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(78,'True','False','ATTD_CourseConnectionContact_TDTM','','','1.0','a0S17000004jpok','Attendance_Event__c','hed','AfterInsert;AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(79,'True','False','TGRD_ValidateData_TDTM','','','1.0','a0S17000004jpol','Term_Grade__c','hed','BeforeInsert;BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(80,'True','False','TERM_CannotDelete_TDTM','','','1.0','a0S17000004jpom','Term__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(81,'True','False','CCON_PreventUpdate_TDTM','','','1.0','a0S17000004jpon','Course_Enrollment__c','hed','BeforeUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(82,'True','False','COFF_CannotDelete_TDTM','','','1.0','a0S17000004jpoo','Course_Offering__c','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(83,'True','False','CASE_CannotDelete_TDTM','','','1.0','a0S17000004jpoq','Case','hed','BeforeDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(84,'True','False','ACCT_IndividualAccounts_TDTM','','','1.0','a0S17000004jpoD','Contact','hed','AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(85,'True','False','AFFL_AccChange_TDTM','','','2.0','a0S17000004jpoE','Affiliation__c','hed','AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(86,'True','False','AFFL_ContactChange_TDTM','','','2.0','a0S17000004jpoF','Affiliation__c','hed','AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(87,'True','False','AFFL_MultiRecordType_TDTM','','','3.0','a0S17000004jpoG','Affiliation__c','hed','BeforeInsert;AfterInsert;AfterUpdate;AfterDelete','False','');
INSERT INTO "Trigger_Handler__c" VALUES(88,'True','False','AFFL_AccRecordType_TDTM','','','1.0','a0S17000004jpoH','Account','hed','AfterUpdate','False','');
INSERT INTO "Trigger_Handler__c" VALUES(89,'True','False','REL_Relationships_Cm_TDTM','','','1.0','a0S17000004jpoI','CampaignMember','hed','AfterInsert;AfterUpdate','False','');
CREATE TABLE "Attribute__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Attribute__c_rt_mapping" VALUES('0120R000002hBqQQAU','Credential');
INSERT INTO "Attribute__c_rt_mapping" VALUES('0120R000002hBqRQAU','Student_Characteristic');
CREATE TABLE "Course_Enrollment__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Course_Enrollment__c_rt_mapping" VALUES('0120R000002hBqaQAE','Default');
INSERT INTO "Course_Enrollment__c_rt_mapping" VALUES('0120R000002hBqbQAE','Faculty');
INSERT INTO "Course_Enrollment__c_rt_mapping" VALUES('0120R000002hBqcQAE','Student');
COMMIT;
